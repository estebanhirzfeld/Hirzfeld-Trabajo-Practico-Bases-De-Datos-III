-- ============================================
-- VIRTUAL_WALLET - TABLE CREATION
-- ============================================

-- 1. TABLE USER
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'blocked') DEFAULT 'active',
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%')
);

-- 2. TABLE ADDRESS
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    street VARCHAR(150) NOT NULL,
    number VARCHAR(10) NOT NULL,
    floor VARCHAR(10),
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) 
        REFERENCES user(user_id) ON DELETE CASCADE
);

-- 3. TABLE ACCOUNT
CREATE TABLE account (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    cvu VARCHAR(22) NOT NULL UNIQUE,
    alias VARCHAR(50) NOT NULL UNIQUE,
    balance DECIMAL(15,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'ARS',
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'suspended', 'closed') DEFAULT 'active',
    CONSTRAINT fk_account_user FOREIGN KEY (user_id) 
        REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_balance_positive CHECK (balance >= 0)
);

-- 4. TABLE CARD
CREATE TABLE card (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    masked_number VARCHAR(20) NOT NULL,
    type ENUM('debit', 'credit') NOT NULL,
    brand VARCHAR(50) NOT NULL,
    expiration_date DATE NOT NULL,
    holder_name VARCHAR(200) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    link_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'expired', 'blocked') DEFAULT 'active',
    CONSTRAINT fk_card_user FOREIGN KEY (user_id) 
        REFERENCES user(user_id) ON DELETE CASCADE
);

-- 5. TABLE TRANSACTION_CATEGORY
CREATE TABLE transaction_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50)
);

-- 6. TABLE PAYMENT_METHOD
CREATE TABLE payment_method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN DEFAULT TRUE
);

-- 7. TABLE TRANSACTION
CREATE TABLE transaction (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    type ENUM('transfer', 'payment', 'topup', 'withdrawal') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('completed', 'pending', 'rejected', 'cancelled') DEFAULT 'pending',
    category_id INT,
    method_id INT,
    description TEXT,
    CONSTRAINT fk_transaction_account FOREIGN KEY (account_id) 
        REFERENCES account(account_id),
    CONSTRAINT fk_transaction_category FOREIGN KEY (category_id) 
        REFERENCES transaction_category(category_id),
    CONSTRAINT fk_transaction_method FOREIGN KEY (method_id) 
        REFERENCES payment_method(method_id),
    CONSTRAINT chk_amount_positive CHECK (amount > 0)
);

-- 8. TABLE TRANSFER
CREATE TABLE transfer (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL UNIQUE,
    source_account_id INT NOT NULL,
    destination_account_id INT,
    destination_cbu VARCHAR(22),
    concept VARCHAR(255),
    CONSTRAINT fk_transfer_transaction FOREIGN KEY (transaction_id) 
        REFERENCES transaction(transaction_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_source FOREIGN KEY (source_account_id) 
        REFERENCES account(account_id),
    CONSTRAINT fk_transfer_destination FOREIGN KEY (destination_account_id) 
        REFERENCES account(account_id)
);

-- 9. TABLE MOVEMENT
CREATE TABLE movement (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_id INT NOT NULL,
    movement_type ENUM('debit', 'credit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    previous_balance DECIMAL(15,2) NOT NULL,
    new_balance DECIMAL(15,2) NOT NULL,
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movement_account FOREIGN KEY (account_id) 
        REFERENCES account(account_id),
    CONSTRAINT fk_movement_transaction FOREIGN KEY (transaction_id) 
        REFERENCES transaction(transaction_id) ON DELETE CASCADE
);

-- 10. TABLE AUDIT_LOG
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    affected_table VARCHAR(100),
    record_id INT,
    description TEXT,
    ip_address VARCHAR(45),
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_user FOREIGN KEY (user_id) 
        REFERENCES user(user_id) ON DELETE SET NULL
);