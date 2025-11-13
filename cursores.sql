-- ============================================
-- STORED PROCEDURES WITH CURSORS
-- ============================================

-- 1. PROCEDURE: CALCULATE INTEREST FOR ALL ACTIVE ACCOUNTS (usando cursor)
DELIMITER //
CREATE PROCEDURE sp_calculate_monthly_interest(
    IN p_interest_rate DECIMAL(5,4),
    OUT p_accounts_processed INT,
    OUT p_total_interest DECIMAL(15,2)
)
BEGIN
    DECLARE v_account_id INT;
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_user_id INT;
    DECLARE v_interest DECIMAL(15,2);
    DECLARE v_done INT DEFAULT FALSE;
    
    -- Cursor para recorrer todas las cuentas activas
    DECLARE cur_accounts CURSOR FOR
        SELECT account_id, user_id, balance
        FROM account
        WHERE status = 'active' AND balance > 0;
    
    -- Handler para cuando no hay más registros
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_accounts_processed = 0;
        SET p_total_interest = 0;
    END;
    
    SET p_accounts_processed = 0;
    SET p_total_interest = 0;
    
    START TRANSACTION;
    
    OPEN cur_accounts;
    
    read_loop: LOOP
        FETCH cur_accounts INTO v_account_id, v_user_id, v_balance;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calcular interés mensual
        SET v_interest = v_balance * p_interest_rate;
        
        -- Actualizar balance
        UPDATE account 
        SET balance = balance + v_interest
        WHERE account_id = v_account_id;
        
        -- Registrar transacción de interés
        INSERT INTO transaction (account_id, type, amount, status, description)
        VALUES (v_account_id, 'topup', v_interest, 'completed', 
                CONCAT('Monthly interest: ', p_interest_rate * 100, '%'));
        
        -- Registrar en audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (v_user_id, 'INTEREST', 'account', v_account_id, 
                CONCAT('Interest applied: $', v_interest));
        
        SET p_accounts_processed = p_accounts_processed + 1;
        SET p_total_interest = p_total_interest + v_interest;
    END LOOP;
    
    CLOSE cur_accounts;
    
    COMMIT;
END //
DELIMITER ;

-- 2. PROCEDURE: GENERATE MONTHLY STATEMENT FOR ALL USERS (usando cursor)
DELIMITER //
CREATE PROCEDURE sp_generate_monthly_statements(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_account_id INT;
    DECLARE v_email VARCHAR(150);
    DECLARE v_first_name VARCHAR(100);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_total_income DECIMAL(15,2);
    DECLARE v_total_expenses DECIMAL(15,2);
    DECLARE v_transaction_count INT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    
    -- Cursor para recorrer todos los usuarios activos con cuentas
    DECLARE cur_users CURSOR FOR
        SELECT DISTINCT u.user_id, u.email, u.first_name, a.account_id, a.balance
        FROM user u
        INNER JOIN account a ON u.user_id = a.user_id
        WHERE u.status = 'active' AND a.status = 'active';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    SET v_start_date = DATE(CONCAT(p_year, '-', LPAD(p_month, 2, '0'), '-01'));
    SET v_end_date = LAST_DAY(v_start_date);
    
    -- Tabla temporal para almacenar los reportes
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_statements (
        user_id INT,
        account_id INT,
        email VARCHAR(150),
        first_name VARCHAR(100),
        period VARCHAR(20),
        current_balance DECIMAL(15,2),
        total_income DECIMAL(15,2),
        total_expenses DECIMAL(15,2),
        transaction_count INT,
        net_change DECIMAL(15,2)
    );
    
    OPEN cur_users;
    
    read_loop: LOOP
        FETCH cur_users INTO v_user_id, v_email, v_first_name, v_account_id, v_balance;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calcular ingresos del mes
        SELECT COALESCE(SUM(amount), 0) INTO v_total_income
        FROM transaction
        WHERE account_id = v_account_id
            AND type = 'topup'
            AND status = 'completed'
            AND DATE(date_time) BETWEEN v_start_date AND v_end_date;
        
        -- Calcular egresos del mes
        SELECT COALESCE(SUM(amount), 0) INTO v_total_expenses
        FROM transaction
        WHERE account_id = v_account_id
            AND type IN ('payment', 'withdrawal', 'transfer')
            AND status = 'completed'
            AND DATE(date_time) BETWEEN v_start_date AND v_end_date;
        
        -- Contar transacciones
        SELECT COUNT(*) INTO v_transaction_count
        FROM transaction
        WHERE account_id = v_account_id
            AND status = 'completed'
            AND DATE(date_time) BETWEEN v_start_date AND v_end_date;
        
        -- Insertar en tabla temporal
        INSERT INTO temp_statements 
        VALUES (
            v_user_id,
            v_account_id,
            v_email,
            v_first_name,
            DATE_FORMAT(v_start_date, '%M %Y'),
            v_balance,
            v_total_income,
            v_total_expenses,
            v_transaction_count,
            v_total_income - v_total_expenses
        );
        
        -- Registrar en audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (v_user_id, 'STATEMENT', 'account', v_account_id, 
                CONCAT('Monthly statement generated for ', DATE_FORMAT(v_start_date, '%M %Y')));
        
    END LOOP;
    
    CLOSE cur_users;
    
    -- Mostrar todos los reportes generados
    SELECT * FROM temp_statements ORDER BY user_id;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE IF EXISTS temp_statements;
END //
DELIMITER ;

-- 3. PROCEDURE: BLOCK SUSPICIOUS ACCOUNTS (usando cursor)
DELIMITER //
CREATE PROCEDURE sp_block_suspicious_accounts(
    IN p_max_daily_transactions INT,
    IN p_max_daily_amount DECIMAL(15,2),
    OUT p_blocked_accounts INT
)
BEGIN
    DECLARE v_account_id INT;
    DECLARE v_user_id INT;
    DECLARE v_transaction_count INT;
    DECLARE v_total_amount DECIMAL(15,2);
    DECLARE v_email VARCHAR(150);
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_today DATE;
    
    -- Cursor para encontrar cuentas sospechosas
    DECLARE cur_suspicious CURSOR FOR
        SELECT 
            a.account_id,
            a.user_id,
            u.email,
            COUNT(t.transaction_id) as trans_count,
            SUM(t.amount) as total_amount
        FROM account a
        INNER JOIN user u ON a.user_id = u.user_id
        INNER JOIN transaction t ON a.account_id = t.account_id
        WHERE a.status = 'active'
            AND t.status = 'completed'
            AND DATE(t.date_time) = CURDATE()
            AND t.type IN ('payment', 'withdrawal', 'transfer')
        GROUP BY a.account_id, a.user_id, u.email
        HAVING trans_count > p_max_daily_transactions 
            OR total_amount > p_max_daily_amount;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_blocked_accounts = 0;
    END;
    
    SET p_blocked_accounts = 0;
    SET v_today = CURDATE();
    
    START TRANSACTION;
    
    OPEN cur_suspicious;
    
    read_loop: LOOP
        FETCH cur_suspicious INTO v_account_id, v_user_id, v_email, 
                                  v_transaction_count, v_total_amount;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Bloquear cuenta
        UPDATE account 
        SET status = 'suspended'
        WHERE account_id = v_account_id;
        
        -- Bloquear usuario
        UPDATE user
        SET status = 'blocked'
        WHERE user_id = v_user_id;
        
        -- Registrar en audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description, ip_address)
        VALUES (v_user_id, 'BLOCK', 'account', v_account_id, 
                CONCAT('Suspicious activity detected. Transactions: ', v_transaction_count, 
                       ', Total amount: $', v_total_amount), 
                'SYSTEM');
        
        SET p_blocked_accounts = p_blocked_accounts + 1;
    END LOOP;
    
    CLOSE cur_suspicious;
    
    COMMIT;
END //
DELIMITER ;

-- 4. PROCEDURE: UPDATE CARD STATUS BASED ON EXPIRATION (usando cursor)
DELIMITER //
CREATE PROCEDURE sp_update_expired_cards()
BEGIN
    DECLARE v_card_id INT;
    DECLARE v_user_id INT;
    DECLARE v_masked_number VARCHAR(20);
    DECLARE v_expiration_date DATE;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_cards_updated INT DEFAULT 0;
    
    -- Cursor para encontrar tarjetas vencidas
    DECLARE cur_expired_cards CURSOR FOR
        SELECT card_id, user_id, masked_number, expiration_date
        FROM card
        WHERE status = 'active'
            AND expiration_date < CURDATE();
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    OPEN cur_expired_cards;
    
    read_loop: LOOP
        FETCH cur_expired_cards INTO v_card_id, v_user_id, v_masked_number, v_expiration_date;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Actualizar estado a vencida
        UPDATE card 
        SET status = 'expired'
        WHERE card_id = v_card_id;
        
        -- Registrar en audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (v_user_id, 'EXPIRE', 'card', v_card_id, 
                CONCAT('Card expired: ', v_masked_number, ' - Expiration: ', v_expiration_date));
        
        SET v_cards_updated = v_cards_updated + 1;
    END LOOP;
    
    CLOSE cur_expired_cards;
    
    COMMIT;
    
    -- Mostrar resultado
    SELECT v_cards_updated as cards_expired;
END //
DELIMITER ;