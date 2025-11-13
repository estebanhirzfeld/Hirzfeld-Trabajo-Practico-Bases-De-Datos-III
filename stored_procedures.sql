-- ============================================
-- STORED PROCEDURES - ABM (CREATE, DELETE, UPDATE)
-- ============================================

-- 1. PROCEDURE: CREATE NEW USER (ALTA)
DELIMITER //
CREATE PROCEDURE sp_create_user(
    IN p_last_name VARCHAR(100),
    IN p_first_name VARCHAR(100),
    IN p_dni VARCHAR(20),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(150),
    IN p_password VARCHAR(255),
    OUT p_user_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Could not create user';
        SET p_user_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Validate email doesn't exist
    IF EXISTS (SELECT 1 FROM user WHERE email = p_email) THEN
        SET p_message = 'Error: Email already exists';
        SET p_user_id = NULL;
        ROLLBACK;
    ELSEIF EXISTS (SELECT 1 FROM user WHERE dni = p_dni) THEN
        SET p_message = 'Error: DNI already exists';
        SET p_user_id = NULL;
        ROLLBACK;
    ELSE
        INSERT INTO user (last_name, first_name, dni, phone, email, password)
        VALUES (p_last_name, p_first_name, p_dni, p_phone, p_email, p_password);
        
        SET p_user_id = LAST_INSERT_ID();
        SET p_message = 'User created successfully';
        
        -- Register in audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (p_user_id, 'CREATE', 'user', p_user_id, CONCAT('New user created: ', p_email));
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- 2. PROCEDURE: DELETE USER (BAJA LÓGICA)
DELIMITER //
CREATE PROCEDURE sp_delete_user(
    IN p_user_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Could not delete user';
    END;
    
    START TRANSACTION;
    
    -- Check if user exists
    SELECT status INTO v_status FROM user WHERE user_id = p_user_id;
    
    IF v_status IS NULL THEN
        SET p_message = 'Error: User not found';
        ROLLBACK;
    ELSEIF v_status = 'inactive' THEN
        SET p_message = 'Warning: User already inactive';
        ROLLBACK;
    ELSE
        -- Logical delete
        UPDATE user SET status = 'inactive' WHERE user_id = p_user_id;
        
        -- Suspend all accounts
        UPDATE account SET status = 'suspended' WHERE user_id = p_user_id;
        
        SET p_message = 'User deleted successfully';
        
        -- Register in audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (p_user_id, 'DELETE', 'user', p_user_id, 'User deactivated');
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- 3. PROCEDURE: UPDATE USER INFO (MODIFICACIÓN)
DELIMITER //
CREATE PROCEDURE sp_update_user(
    IN p_user_id INT,
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(150),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_old_email VARCHAR(150);
    DECLARE v_email_exists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Could not update user';
    END;
    
    START TRANSACTION;
    
    -- Get current email
    SELECT email INTO v_old_email FROM user WHERE user_id = p_user_id;
    
    IF v_old_email IS NULL THEN
        SET p_message = 'Error: User not found';
        ROLLBACK;
    ELSE
        -- Check if new email already exists (for another user)
        SELECT COUNT(*) INTO v_email_exists 
        FROM user 
        WHERE email = p_email AND user_id != p_user_id;
        
        IF v_email_exists > 0 THEN
            SET p_message = 'Error: Email already in use';
            ROLLBACK;
        ELSE
            UPDATE user 
            SET phone = p_phone, email = p_email
            WHERE user_id = p_user_id;
            
            SET p_message = 'User updated successfully';
            
            -- Register in audit log
            INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
            VALUES (p_user_id, 'UPDATE', 'user', p_user_id, 
                    CONCAT('User updated. Old email: ', v_old_email, ', New email: ', p_email));
            
            COMMIT;
        END IF;
    END IF;
END //
DELIMITER ;

-- 4. PROCEDURE: CREATE TRANSACTION (ALTA)
DELIMITER //
CREATE PROCEDURE sp_create_transaction(
    IN p_account_id INT,
    IN p_type ENUM('transfer', 'payment', 'topup', 'withdrawal'),
    IN p_amount DECIMAL(15,2),
    IN p_category_id INT,
    IN p_method_id INT,
    IN p_description TEXT,
    OUT p_transaction_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_account_status VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Transaction failed';
        SET p_transaction_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Get account balance and status
    SELECT balance, status INTO v_balance, v_account_status 
    FROM account WHERE account_id = p_account_id;
    
    IF v_account_status IS NULL THEN
        SET p_message = 'Error: Account not found';
        SET p_transaction_id = NULL;
        ROLLBACK;
    ELSEIF v_account_status != 'active' THEN
        SET p_message = 'Error: Account is not active';
        SET p_transaction_id = NULL;
        ROLLBACK;
    ELSEIF p_type IN ('payment', 'withdrawal', 'transfer') AND v_balance < p_amount THEN
        SET p_message = 'Error: Insufficient balance';
        SET p_transaction_id = NULL;
        ROLLBACK;
    ELSE
        -- Create transaction
        INSERT INTO transaction (account_id, type, amount, status, category_id, method_id, description)
        VALUES (p_account_id, p_type, p_amount, 'completed', p_category_id, p_method_id, p_description);
        
        SET p_transaction_id = LAST_INSERT_ID();
        
        -- Update balance
        IF p_type = 'topup' THEN
            UPDATE account SET balance = balance + p_amount WHERE account_id = p_account_id;
        ELSE
            UPDATE account SET balance = balance - p_amount WHERE account_id = p_account_id;
        END IF;
        
        SET p_message = 'Transaction completed successfully';
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- 5. PROCEDURE: CANCEL TRANSACTION (BAJA)
DELIMITER //
CREATE PROCEDURE sp_cancel_transaction(
    IN p_transaction_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_type VARCHAR(20);
    DECLARE v_amount DECIMAL(15,2);
    DECLARE v_account_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Could not cancel transaction';
    END;
    
    START TRANSACTION;
    
    -- Get transaction details
    SELECT status, type, amount, account_id 
    INTO v_status, v_type, v_amount, v_account_id
    FROM transaction WHERE transaction_id = p_transaction_id;
    
    IF v_status IS NULL THEN
        SET p_message = 'Error: Transaction not found';
        ROLLBACK;
    ELSEIF v_status = 'cancelled' THEN
        SET p_message = 'Warning: Transaction already cancelled';
        ROLLBACK;
    ELSEIF v_status != 'completed' THEN
        SET p_message = 'Error: Can only cancel completed transactions';
        ROLLBACK;
    ELSE
        -- Cancel transaction
        UPDATE transaction SET status = 'cancelled' WHERE transaction_id = p_transaction_id;
        
        -- Reverse balance
        IF v_type = 'topup' THEN
            UPDATE account SET balance = balance - v_amount WHERE account_id = v_account_id;
        ELSE
            UPDATE account SET balance = balance + v_amount WHERE account_id = v_account_id;
        END IF;
        
        SET p_message = 'Transaction cancelled successfully';
        
        -- Register in audit log
        INSERT INTO audit_log (user_id, action, affected_table, record_id, description)
        VALUES (NULL, 'CANCEL', 'transaction', p_transaction_id, 
                CONCAT('Transaction cancelled. Amount: ', v_amount));
        
        COMMIT;
    END IF;
END //
DELIMITER ;