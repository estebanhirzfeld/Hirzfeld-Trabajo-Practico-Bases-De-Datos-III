-- ============================================
-- VIEWS - USEFUL REPORTS
-- ============================================

-- 1. VIEW: USER ACCOUNT OVERVIEW
-- Resumen completo de usuarios con sus cuentas y saldos
CREATE OR REPLACE VIEW vw_user_account_overview AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.dni,
    u.email,
    u.phone,
    u.status as user_status,
    u.registration_date,
    a.account_id,
    a.cvu,
    a.alias,
    a.balance,
    a.currency,
    a.status as account_status,
    CONCAT(ad.street, ' ', ad.number, 
           CASE WHEN ad.floor IS NOT NULL THEN CONCAT(', Piso ', ad.floor) ELSE '' END) as full_address,
    ad.city,
    ad.country,
    ad.postal_code
FROM user u
INNER JOIN account a ON u.user_id = a.user_id
LEFT JOIN address ad ON u.user_id = ad.user_id;

-- 2. VIEW: TRANSACTION SUMMARY BY USER
-- Resumen de transacciones por usuario con estadísticas
CREATE OR REPLACE VIEW vw_transaction_summary_by_user AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    a.account_id,
    a.alias,
    COUNT(DISTINCT t.transaction_id) as total_transactions,
    COUNT(DISTINCT CASE WHEN t.type = 'topup' THEN t.transaction_id END) as topup_count,
    COUNT(DISTINCT CASE WHEN t.type = 'payment' THEN t.transaction_id END) as payment_count,
    COUNT(DISTINCT CASE WHEN t.type = 'transfer' THEN t.transaction_id END) as transfer_count,
    COUNT(DISTINCT CASE WHEN t.type = 'withdrawal' THEN t.transaction_id END) as withdrawal_count,
    COALESCE(SUM(CASE WHEN t.type = 'topup' AND t.status = 'completed' THEN t.amount ELSE 0 END), 0) as total_income,
    COALESCE(SUM(CASE WHEN t.type IN ('payment', 'withdrawal', 'transfer') AND t.status = 'completed' THEN t.amount ELSE 0 END), 0) as total_expenses,
    a.balance as current_balance,
    MAX(t.date_time) as last_transaction_date,
    DATEDIFF(NOW(), MAX(t.date_time)) as days_since_last_transaction
FROM user u
INNER JOIN account a ON u.user_id = a.user_id
LEFT JOIN transaction t ON a.account_id = t.account_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, a.account_id, a.alias, a.balance;

-- 3. VIEW: CATEGORY SPENDING ANALYSIS
-- Análisis de gastos por categoría con porcentajes
CREATE OR REPLACE VIEW vw_category_spending_analysis AS
SELECT 
    tc.category_id,
    tc.name as category_name,
    tc.icon as category_icon,
    COUNT(t.transaction_id) as transaction_count,
    SUM(t.amount) as total_spent,
    AVG(t.amount) as average_transaction,
    MIN(t.amount) as min_transaction,
    MAX(t.amount) as max_transaction,
    ROUND(
        (SUM(t.amount) / 
         (SELECT SUM(amount) FROM transaction WHERE status = 'completed' AND type IN ('payment', 'withdrawal', 'transfer')) 
         * 100), 2
    ) as percentage_of_total,
    DATE_FORMAT(MIN(t.date_time), '%Y-%m-%d') as first_transaction_date,
    DATE_FORMAT(MAX(t.date_time), '%Y-%m-%d') as last_transaction_date
FROM transaction_category tc
LEFT JOIN transaction t ON tc.category_id = t.category_id 
    AND t.status = 'completed' 
    AND t.type IN ('payment', 'withdrawal', 'transfer')
GROUP BY tc.category_id, tc.name, tc.icon
HAVING transaction_count > 0
ORDER BY total_spent DESC;

-- 4. VIEW: DAILY TRANSACTION REPORT
-- Reporte diario de transacciones con movimientos
CREATE OR REPLACE VIEW vw_daily_transaction_report AS
SELECT 
    DATE(t.date_time) as transaction_date,
    t.type as transaction_type,
    COUNT(t.transaction_id) as total_count,
    SUM(t.amount) as total_amount,
    AVG(t.amount) as average_amount,
    COUNT(DISTINCT t.account_id) as unique_accounts,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN t.status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN t.status = 'rejected' THEN 1 END) as rejected_count,
    COUNT(CASE WHEN t.status = 'cancelled' THEN 1 END) as cancelled_count
FROM transaction t
WHERE t.date_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(t.date_time), t.type
ORDER BY transaction_date DESC, transaction_type;

-- 5. VIEW: ACTIVE USERS WITH CARDS
-- Usuarios activos con sus tarjetas vinculadas
CREATE OR REPLACE VIEW vw_active_users_with_cards AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    u.phone,
    a.account_id,
    a.alias,
    a.balance,
    COUNT(DISTINCT c.card_id) as total_cards,
    COUNT(DISTINCT CASE WHEN c.type = 'debit' THEN c.card_id END) as debit_cards,
    COUNT(DISTINCT CASE WHEN c.type = 'credit' THEN c.card_id END) as credit_cards,
    COUNT(DISTINCT CASE WHEN c.status = 'active' THEN c.card_id END) as active_cards,
    COUNT(DISTINCT CASE WHEN c.status = 'expired' THEN c.card_id END) as expired_cards,
    COUNT(DISTINCT CASE WHEN c.is_primary = TRUE THEN c.card_id END) as primary_cards,
    GROUP_CONCAT(DISTINCT c.brand ORDER BY c.brand SEPARATOR ', ') as card_brands
FROM user u
INNER JOIN account a ON u.user_id = a.user_id
LEFT JOIN card c ON u.user_id = c.user_id
WHERE u.status = 'active' AND a.status = 'active'
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.phone, a.account_id, a.alias, a.balance;

-- 6. VIEW: AUDIT LOG SUMMARY
-- Resumen de actividad del sistema desde el log de auditoría
CREATE OR REPLACE VIEW vw_audit_log_summary AS
SELECT 
    DATE(al.date_time) as log_date,
    al.action,
    al.affected_table,
    COUNT(al.log_id) as event_count,
    COUNT(DISTINCT al.user_id) as unique_users,
    COUNT(DISTINCT al.ip_address) as unique_ips,
    MIN(al.date_time) as first_event_time,
    MAX(al.date_time) as last_event_time,
    GROUP_CONCAT(DISTINCT al.ip_address ORDER BY al.ip_address SEPARATOR ', ') as ip_addresses
FROM audit_log al
WHERE al.date_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(al.date_time), al.action, al.affected_table
ORDER BY log_date DESC, event_count DESC;

-- 7. VIEW: TOP SPENDING USERS (LAST 30 DAYS)
-- Ranking de usuarios con más gastos en los últimos 30 días
CREATE OR REPLACE VIEW vw_top_spending_users AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    a.account_id,
    a.alias,
    COUNT(t.transaction_id) as transaction_count,
    SUM(t.amount) as total_spent,
    AVG(t.amount) as average_transaction,
    a.balance as current_balance,
    ROUND((SUM(t.amount) / a.balance * 100), 2) as spending_vs_balance_percentage,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) as spending_rank
FROM user u
INNER JOIN account a ON u.user_id = a.user_id
INNER JOIN transaction t ON a.account_id = t.account_id
WHERE t.type IN ('payment', 'withdrawal', 'transfer')
    AND t.status = 'completed'
    AND t.date_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.user_id, u.first_name, u.last_name, u.email, a.account_id, a.alias, a.balance
HAVING total_spent > 0
ORDER BY total_spent DESC
LIMIT 20;