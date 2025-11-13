-- ============================================
-- TRIGGERS
-- ============================================

-- 1. TRIGGER: Auto-register movement after transaction (AFTER INSERT)
DELIMITER //
CREATE TRIGGER trg_after_transaction_insert
AFTER INSERT ON transaction
FOR EACH ROW
BEGIN
    DECLARE v_previous_balance DECIMAL(15,2);
    DECLARE v_new_balance DECIMAL(15,2);
    DECLARE v_movement_type ENUM('debit', 'credit');
    
    -- Obtener el saldo actual de la cuenta
    SELECT balance INTO v_previous_balance
    FROM account
    WHERE account_id = NEW.account_id;
    
    -- Determinar tipo de movimiento y calcular nuevo saldo
    IF NEW.type = 'topup' THEN
        SET v_movement_type = 'credit';
        SET v_new_balance = v_previous_balance;  -- Ya fue actualizado por el SP
    ELSE
        SET v_movement_type = 'debit';
        SET v_new_balance = v_previous_balance;  -- Ya fue actualizado por el SP
    END IF;
    
    -- Registrar el movimiento automáticamente
    IF NEW.status = 'completed' THEN
        INSERT INTO movement (
            account_id, 
            transaction_id, 
            movement_type, 
            amount, 
            previous_balance, 
            new_balance
        )
        VALUES (
            NEW.account_id,
            NEW.transaction_id,
            v_movement_type,
            NEW.amount,
            CASE 
                WHEN NEW.type = 'topup' THEN v_previous_balance - NEW.amount
                ELSE v_previous_balance + NEW.amount
            END,
            v_previous_balance
        );
    END IF;
END //
DELIMITER ;

-- 2. TRIGGER: Log user changes (AFTER UPDATE)
DELIMITER //
CREATE TRIGGER trg_after_user_update
AFTER UPDATE ON user
FOR EACH ROW
BEGIN
    DECLARE v_changes TEXT DEFAULT '';
    
    -- Detectar qué campos cambiaron
    IF OLD.email != NEW.email THEN
        SET v_changes = CONCAT(v_changes, 'Email changed from ', OLD.email, ' to ', NEW.email, '. ');
    END IF;
    
    IF OLD.phone != NEW.phone THEN
        SET v_changes = CONCAT(v_changes, 'Phone changed from ', OLD.phone, ' to ', NEW.phone, '. ');
    END IF;
    
    IF OLD.status != NEW.status THEN
        SET v_changes = CONCAT(v_changes, 'Status changed from ', OLD.status, ' to ', NEW.status, '. ');
    END IF;
    
    IF OLD.first_name != NEW.first_name OR OLD.last_name != NEW.last_name THEN
        SET v_changes = CONCAT(v_changes, 'Name changed. ');
    END IF;
    
    -- Registrar en audit_log solo si hubo cambios
    IF v_changes != '' THEN
        INSERT INTO audit_log (
            user_id, 
            action, 
            affected_table, 
            record_id, 
            description
        )
        VALUES (
            NEW.user_id,
            'UPDATE',
            'user',
            NEW.user_id,
            v_changes
        );
    END IF;
END //
DELIMITER ;

-- 3. TRIGGER: Prevent negative balance (BEFORE UPDATE)
DELIMITER //
CREATE TRIGGER trg_before_account_update
BEFORE UPDATE ON account
FOR EACH ROW
BEGIN
    -- Prevenir saldos negativos
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Account balance cannot be negative';
    END IF;
    
    -- Si la cuenta se está suspendiendo o cerrando, registrar en log
    IF OLD.status != NEW.status AND NEW.status IN ('suspended', 'closed') THEN
        INSERT INTO audit_log (
            user_id, 
            action, 
            affected_table, 
            record_id, 
            description
        )
        VALUES (
            NEW.user_id,
            'STATUS_CHANGE',
            'account',
            NEW.account_id,
            CONCAT('Account status changed from ', OLD.status, ' to ', NEW.status, '. Balance: $', NEW.balance)
        );
    END IF;
END //
DELIMITER ;

-- 4. TRIGGER: Auto-create account when user is created (AFTER INSERT)
DELIMITER //
CREATE TRIGGER trg_after_user_insert
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    DECLARE v_cvu VARCHAR(22);
    DECLARE v_alias VARCHAR(50);
    DECLARE v_random INT;
    
    -- Generar CVU único (simulado)
    SET v_random = FLOOR(RAND() * 1000000);
    SET v_cvu = CONCAT('000000310001884', LPAD(NEW.user_id, 7, '0'), LPAD(v_random, 6, '0'));
    
    -- Generar alias basado en nombre
    SET v_alias = LOWER(CONCAT(
        SUBSTRING(NEW.first_name, 1, 4), 
        '.', 
        SUBSTRING(NEW.last_name, 1, 4),
        '.wallet'
    ));
    
    -- Crear cuenta automáticamente
    INSERT INTO account (user_id, cvu, alias, balance, currency, status)
    VALUES (NEW.user_id, v_cvu, v_alias, 0.00, 'ARS', 'active');
    
    -- Registrar en audit log
    INSERT INTO audit_log (
        user_id, 
        action, 
        affected_table, 
        record_id, 
        description
    )
    VALUES (
        NEW.user_id,
        'AUTO_CREATE',
        'account',
        LAST_INSERT_ID(),
        CONCAT('Account automatically created for new user: ', NEW.email)
    );
END //
DELIMITER ;

-- 5. TRIGGER: Validate transaction amount (BEFORE INSERT)
DELIMITER //
CREATE TRIGGER trg_before_transaction_insert
BEFORE INSERT ON transaction
FOR EACH ROW
BEGIN
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_account_status VARCHAR(20);
    
    -- Obtener saldo y estado de la cuenta
    SELECT balance, status INTO v_balance, v_account_status
    FROM account
    WHERE account_id = NEW.account_id;
    
    -- Validar que la cuenta existe y está activa
    IF v_account_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Account does not exist';
    END IF;
    
    IF v_account_status != 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Account is not active';
    END IF;
    
    -- Validar monto positivo
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Transaction amount must be positive';
    END IF;
    
    -- Validar que hay suficiente saldo para débitos
    IF NEW.type IN ('payment', 'withdrawal', 'transfer') AND v_balance < NEW.amount THEN
        -- Cambiar estado a rechazada en lugar de fallar
        SET NEW.status = 'rejected';
        SET NEW.description = CONCAT(IFNULL(NEW.description, ''), ' [REJECTED: Insufficient balance]');
    END IF;
END //
DELIMITER ;

-- 6. TRIGGER: Block card if too many failed attempts (AFTER UPDATE)
DELIMITER //
CREATE TRIGGER trg_after_card_update
AFTER UPDATE ON card
FOR EACH ROW
BEGIN
    -- Si una tarjeta expira, notificar en el log
    IF OLD.status != 'expired' AND NEW.status = 'expired' THEN
        INSERT INTO audit_log (
            user_id, 
            action, 
            affected_table, 
            record_id, 
            description
        )
        VALUES (
            NEW.user_id,
            'CARD_EXPIRED',
            'card',
            NEW.card_id,
            CONCAT('Card expired: ', NEW.masked_number, ' - ', NEW.brand)
        );
    END IF;
    
    -- Si una tarjeta se bloquea, notificar
    IF OLD.status != 'blocked' AND NEW.status = 'blocked' THEN
        INSERT INTO audit_log (
            user_id, 
            action, 
            affected_table, 
            record_id, 
            description,
            ip_address
        )
        VALUES (
            NEW.user_id,
            'CARD_BLOCKED',
            'card',
            NEW.card_id,
            CONCAT('Card blocked: ', NEW.masked_number, ' - ', NEW.brand),
            'SYSTEM'
        );
    END IF;
END //
DELIMITER ;

-- 7. TRIGGER: Delete related data when user is deleted (BEFORE DELETE)
DELIMITER //
CREATE TRIGGER trg_before_user_delete
BEFORE DELETE ON user
FOR EACH ROW
BEGIN
    -- Registrar eliminación en audit log antes de borrar
    INSERT INTO audit_log (
        user_id, 
        action, 
        affected_table, 
        record_id, 
        description
    )
    VALUES (
        OLD.user_id,
        'DELETE',
        'user',
        OLD.user_id,
        CONCAT('User deleted: ', OLD.email, ' - ', OLD.first_name, ' ', OLD.last_name)
    );
    
    -- Las foreign keys con ON DELETE CASCADE se encargarán del resto
END //
DELIMITER ;