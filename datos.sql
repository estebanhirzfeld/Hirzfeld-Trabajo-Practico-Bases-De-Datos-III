-- ============================================
-- DATA LOADING - ELECTRONIC WALLET
-- ============================================

-- 1. INSERT USER (20+ records)
INSERT INTO user (last_name, first_name, dni, phone, email, password, status) VALUES
('García', 'Juan', '12345678', '+5491112345678', 'juan.garcia@email.com', 'hash123', 'active'),
('Rodríguez', 'María', '23456789', '+5491123456789', 'maria.rodriguez@email.com', 'hash456', 'active'),
('López', 'Carlos', '34567890', '+5491134567890', 'carlos.lopez@email.com', 'hash789', 'active'),
('Martínez', 'Ana', '45678901', '+5491145678901', 'ana.martinez@email.com', 'hash012', 'active'),
('González', 'Luis', '56789012', '+5491156789012', 'luis.gonzalez@email.com', 'hash345', 'active'),
('Fernández', 'Laura', '67890123', '+5491167890123', 'laura.fernandez@email.com', 'hash678', 'active'),
('Pérez', 'Diego', '78901234', '+5491178901234', 'diego.perez@email.com', 'hash901', 'active'),
('Sánchez', 'Sofía', '89012345', '+5491189012345', 'sofia.sanchez@email.com', 'hash234', 'active'),
('Romero', 'Miguel', '90123456', '+5491190123456', 'miguel.romero@email.com', 'hash567', 'active'),
('Torres', 'Valentina', '01234567', '+5491101234567', 'valentina.torres@email.com', 'hash890', 'active'),
('Díaz', 'Martín', '11234568', '+5491111234568', 'martin.diaz@email.com', 'hash111', 'active'),
('Álvarez', 'Camila', '22345679', '+5491122345679', 'camila.alvarez@email.com', 'hash222', 'active'),
('Ruiz', 'Federico', '33456780', '+5491133456780', 'federico.ruiz@email.com', 'hash333', 'active'),
('Moreno', 'Lucía', '44567891', '+5491144567891', 'lucia.moreno@email.com', 'hash444', 'active'),
('Flores', 'Santiago', '55678902', '+5491155678902', 'santiago.flores@email.com', 'hash555', 'active'),
('Silva', 'Catalina', '66789013', '+5491166789013', 'catalina.silva@email.com', 'hash666', 'active'),
('Castro', 'Joaquín', '77890124', '+5491177890124', 'joaquin.castro@email.com', 'hash777', 'active'),
('Rojas', 'Martina', '88901235', '+5491188901235', 'martina.rojas@email.com', 'hash888', 'active'),
('Herrera', 'Nicolás', '99012346', '+5491199012346', 'nicolas.herrera@email.com', 'hash999', 'inactive'),
('Mendoza', 'Isabella', '10123457', '+5491110123457', 'isabella.mendoza@email.com', 'hash000', 'active'),
('Vega', 'Mateo', '21234568', '+5491121234568', 'mateo.vega@email.com', 'hash1111', 'active'),
('Ortiz', 'Emma', '32345679', '+5491132345679', 'emma.ortiz@email.com', 'hash2222', 'blocked');

-- 2. INSERT ADDRESS (20+ records)
INSERT INTO address (user_id, street, number, floor, postal_code, city, country) VALUES
(1, 'Av. Corrientes', '1234', '5A', 'C1043', 'Buenos Aires', 'Argentina'),
(2, 'Av. Santa Fe', '2345', '10B', 'C1425', 'Buenos Aires', 'Argentina'),
(3, 'Av. Cabildo', '3456', NULL, 'C1426', 'Buenos Aires', 'Argentina'),
(4, 'Av. Rivadavia', '4567', '3C', 'C1406', 'Buenos Aires', 'Argentina'),
(5, 'Av. Las Heras', '5678', '7A', 'C1425', 'Buenos Aires', 'Argentina'),
(6, 'Av. Callao', '6789', '2B', 'C1022', 'Buenos Aires', 'Argentina'),
(7, 'Av. Libertador', '7890', '15D', 'C1425', 'Buenos Aires', 'Argentina'),
(8, 'Av. Belgrano', '8901', NULL, 'C1092', 'Buenos Aires', 'Argentina'),
(9, 'Av. Pueyrredón', '9012', '4A', 'C1425', 'Buenos Aires', 'Argentina'),
(10, 'Av. Independencia', '123', '8C', 'C1099', 'Buenos Aires', 'Argentina'),
(11, 'Av. San Juan', '234', NULL, 'C1148', 'Buenos Aires', 'Argentina'),
(12, 'Av. Córdoba', '345', '6B', 'C1054', 'Buenos Aires', 'Argentina'),
(13, 'Av. Entre Ríos', '456', '2A', 'C1080', 'Buenos Aires', 'Argentina'),
(14, 'Av. Jujuy', '567', NULL, 'C1229', 'Buenos Aires', 'Argentina'),
(15, 'Av. Boedo', '678', '9D', 'C1206', 'Buenos Aires', 'Argentina'),
(16, 'Av. Scalabrini Ortiz', '789', '3B', 'C1414', 'Buenos Aires', 'Argentina'),
(17, 'Av. Juan B. Justo', '890', NULL, 'C1414', 'Buenos Aires', 'Argentina'),
(18, 'Av. Díaz Vélez', '901', '5C', 'C1405', 'Buenos Aires', 'Argentina'),
(19, 'Av. Estado de Israel', '1012', '12A', 'C1101', 'Buenos Aires', 'Argentina'),
(20, 'Av. Figueroa Alcorta', '1123', NULL, 'C1425', 'Buenos Aires', 'Argentina'),
(21, 'Av. del Libertador', '1234', '8B', 'C1426', 'Buenos Aires', 'Argentina'),
(22, 'Av. Monroe', '1345', '4D', 'C1428', 'Buenos Aires', 'Argentina');

-- 3. INSERT ACCOUNT (20+ records)
INSERT INTO account (user_id, cvu, alias, balance, currency, status) VALUES
(1, '0000003100018845123456', 'juan.garcia.wallet', 15000.00, 'ARS', 'active'),
(2, '0000003100018845234567', 'maria.rod.money', 25000.50, 'ARS', 'active'),
(3, '0000003100018845345678', 'carlos.lopez.pay', 5000.75, 'ARS', 'active'),
(4, '0000003100018845456789', 'ana.mart.digital', 30000.00, 'ARS', 'active'),
(5, '0000003100018845567890', 'luis.gonz.wallet', 12500.00, 'ARS', 'active'),
(6, '0000003100018845678901', 'laura.fer.pay', 8000.25, 'ARS', 'active'),
(7, '0000003100018845789012', 'diego.perez.cash', 20000.00, 'ARS', 'active'),
(8, '0000003100018845890123', 'sofia.san.money', 18500.50, 'ARS', 'active'),
(9, '0000003100018845901234', 'miguel.rom.wallet', 9500.00, 'ARS', 'active'),
(10, '0000003100018846012345', 'vale.torres.pay', 35000.75, 'ARS', 'active'),
(11, '0000003100018846123456', 'martin.diaz.digital', 7500.00, 'ARS', 'active'),
(12, '0000003100018846234567', 'cami.alv.wallet', 22000.00, 'ARS', 'active'),
(13, '0000003100018846345678', 'fede.ruiz.pay', 11000.50, 'ARS', 'active'),
(14, '0000003100018846456789', 'lucia.mor.money', 16500.00, 'ARS', 'active'),
(15, '0000003100018846567890', 'santi.flo.wallet', 19000.25, 'ARS', 'active'),
(16, '0000003100018846678901', 'cata.silva.pay', 28000.00, 'ARS', 'active'),
(17, '0000003100018846789012', 'joaco.cast.digital', 6500.00, 'ARS', 'active'),
(18, '0000003100018846890123', 'marti.roj.wallet', 24500.50, 'ARS', 'active'),
(19, '0000003100018846901234', 'nico.her.pay', 3000.00, 'ARS', 'suspended'),
(20, '0000003100018847012345', 'isa.mend.money', 31000.75, 'ARS', 'active'),
(21, '0000003100018847123456', 'mateo.vega.wallet', 14000.00, 'ARS', 'active'),
(22, '0000003100018847234567', 'emma.ortiz.pay', 500.00, 'ARS', 'active');

-- 4. INSERT CARD (20+ records)
INSERT INTO card (user_id, masked_number, type, brand, expiration_date, holder_name, is_primary, status) VALUES
(1, '**** **** **** 1234', 'debit', 'Visa', '2027-05-31', 'JUAN GARCIA', TRUE, 'active'),
(2, '**** **** **** 2345', 'credit', 'Mastercard', '2026-08-31', 'MARIA RODRIGUEZ', TRUE, 'active'),
(3, '**** **** **** 3456', 'debit', 'Visa', '2027-12-31', 'CARLOS LOPEZ', TRUE, 'active'),
(4, '**** **** **** 4567', 'credit', 'American Express', '2028-03-31', 'ANA MARTINEZ', TRUE, 'active'),
(5, '**** **** **** 5678', 'debit', 'Mastercard', '2027-06-30', 'LUIS GONZALEZ', TRUE, 'active'),
(6, '**** **** **** 6789', 'credit', 'Visa', '2026-11-30', 'LAURA FERNANDEZ', TRUE, 'active'),
(7, '**** **** **** 7890', 'debit', 'Mastercard', '2027-09-30', 'DIEGO PEREZ', TRUE, 'active'),
(8, '**** **** **** 8901', 'credit', 'Visa', '2028-01-31', 'SOFIA SANCHEZ', TRUE, 'active'),
(9, '**** **** **** 9012', 'debit', 'Visa', '2027-07-31', 'MIGUEL ROMERO', TRUE, 'active'),
(10, '**** **** **** 0123', 'credit', 'Mastercard', '2026-10-31', 'VALENTINA TORRES', TRUE, 'active'),
(11, '**** **** **** 1235', 'debit', 'Visa', '2027-04-30', 'MARTIN DIAZ', TRUE, 'active'),
(12, '**** **** **** 2346', 'credit', 'American Express', '2028-02-28', 'CAMILA ALVAREZ', TRUE, 'active'),
(13, '**** **** **** 3457', 'debit', 'Mastercard', '2027-11-30', 'FEDERICO RUIZ', TRUE, 'active'),
(14, '**** **** **** 4568', 'credit', 'Visa', '2026-09-30', 'LUCIA MORENO', TRUE, 'active'),
(15, '**** **** **** 5679', 'debit', 'Visa', '2027-08-31', 'SANTIAGO FLORES', TRUE, 'active'),
(16, '**** **** **** 6780', 'credit', 'Mastercard', '2028-05-31', 'CATALINA SILVA', TRUE, 'active'),
(17, '**** **** **** 7891', 'debit', 'Visa', '2027-03-31', 'JOAQUIN CASTRO', TRUE, 'active'),
(18, '**** **** **** 8902', 'credit', 'Visa', '2026-12-31', 'MARTINA ROJAS', TRUE, 'active'),
(19, '**** **** **** 9013', 'debit', 'Mastercard', '2025-06-30', 'NICOLAS HERRERA', TRUE, 'expired'),
(20, '**** **** **** 0124', 'credit', 'American Express', '2028-04-30', 'ISABELLA MENDOZA', TRUE, 'active'),
(1, '**** **** **** 1236', 'credit', 'Mastercard', '2027-10-31', 'JUAN GARCIA', FALSE, 'active'),
(2, '**** **** **** 2347', 'debit', 'Visa', '2027-07-31', 'MARIA RODRIGUEZ', FALSE, 'active');

-- 5. INSERT TRANSACTION_CATEGORY (20+ records)
INSERT INTO transaction_category (name, description, icon) VALUES
('Food & Drinks', 'Restaurants, groceries, beverages', '🍔'),
('Transportation', 'Taxi, public transport, fuel', '🚗'),
('Shopping', 'Clothing, electronics, general shopping', '🛍️'),
('Entertainment', 'Movies, concerts, games', '🎬'),
('Bills & Utilities', 'Electricity, water, gas, internet', '💡'),
('Health', 'Medicine, doctor visits, insurance', '⚕️'),
('Education', 'Courses, books, school fees', '📚'),
('Travel', 'Hotels, flights, tours', '✈️'),
('Transfers', 'Money transfers between accounts', '💸'),
('Savings', 'Investments, savings accounts', '💰'),
('Services', 'Professional services, repairs', '🔧'),
('Subscriptions', 'Streaming, software, memberships', '📱'),
('Gifts', 'Presents, donations', '🎁'),
('Personal Care', 'Salon, spa, cosmetics', '💅'),
('Home', 'Furniture, appliances, maintenance', '🏠'),
('Sports', 'Gym, sports equipment, activities', '⚽'),
('Pets', 'Pet food, veterinary, accessories', '🐾'),
('Insurance', 'Life, car, home insurance', '🛡️'),
('Taxes', 'Government taxes, fees', '🏛️'),
('ATM Withdrawal', 'Cash withdrawals', '🏧'),
('Other', 'Uncategorized transactions', '📋');

-- 6. INSERT PAYMENT_METHOD (20+ records)
INSERT INTO payment_method (name, description, active) VALUES
('Account Balance', 'Pay using wallet balance', TRUE),
('Debit Card', 'Direct debit from bank account', TRUE),
('Credit Card', 'Credit card payment', TRUE),
('QR Code', 'Scan and pay with QR', TRUE),
('Bank Transfer', 'Direct bank transfer', TRUE),
('Cash Deposit', 'Deposit cash at authorized locations', TRUE),
('Cryptocurrency', 'Pay with Bitcoin, Ethereum, etc', TRUE),
('PayPal Link', 'Link PayPal account', FALSE),
('Apple Pay', 'Pay using Apple Pay', TRUE),
('Google Pay', 'Pay using Google Pay', TRUE),
('Samsung Pay', 'Pay using Samsung Pay', TRUE),
('Wire Transfer', 'International wire transfer', TRUE),
('Check Deposit', 'Deposit by check', FALSE),
('Direct Debit', 'Automatic recurring payments', TRUE),
('Mercado Pago', 'Mercado Pago integration', TRUE),
('MODO', 'MODO payment system', TRUE),
('Virtual Card', 'Virtual debit card', TRUE),
('Prepaid Card', 'Prepaid card balance', TRUE),
('Gift Card', 'Gift card redemption', TRUE),
('Loyalty Points', 'Pay with reward points', TRUE),
('Invoice Payment', 'Pay by invoice', TRUE);


-- 7. INSERT TRANSACTION (20+ records)
-- Nota: transaction_id se autoincrementará desde 1.
-- Se incluyen transacciones de varios tipos y estados para realismo.
INSERT INTO transaction (account_id, type, amount, status, category_id, method_id, description) VALUES
-- Transacciones completadas que generarán movimientos
(1, 'transfer', 1000.00, 'completed', 9, 1, 'Transferencia a María Rodríguez'),                                 -- transaction_id: 1
(3, 'payment', 500.75, 'completed', 5, 1, 'Pago de factura de luz'),                                         -- transaction_id: 2
(4, 'topup', 2000.00, 'completed', 10, 2, 'Recarga desde tarjeta de débito'),                                -- transaction_id: 3
(5, 'transfer', 1500.00, 'completed', 9, 1, 'Transferencia a CBU externo'),                                  -- transaction_id: 4
(2, 'payment', 3500.00, 'completed', 3, 1, 'Compra en tienda de ropa online'),                              -- transaction_id: 5
(8, 'withdrawal', 2000.00, 'completed', 20, 6, 'Retiro de efectivo en punto autorizado'),                     -- transaction_id: 6
(10, 'topup', 5000.00, 'completed', 10, 3, 'Recarga con tarjeta de crédito'),                                 -- transaction_id: 7
(7, 'transfer', 2500.00, 'completed', 9, 1, 'Transferencia a Sofía Sánchez'),                                 -- transaction_id: 8
(12, 'payment', 1250.50, 'completed', 1, 1, 'Cena en restaurante'),                                          -- transaction_id: 9
(15, 'transfer', 3000.00, 'completed', 9, 1, 'Transferencia a Joaquín Castro'),                               -- transaction_id: 10
(1, 'payment', 850.25, 'completed', 2, 4, 'Pago de taxi con QR'),                                            -- transaction_id: 11
(6, 'topup', 1000.00, 'completed', 10, 15, 'Recarga con saldo Mercado Pago'),                                -- transaction_id: 12
(14, 'withdrawal', 1500.00, 'completed', 20, 6, 'Retiro de efectivo'),                                       -- transaction_id: 13
(18, 'payment', 450.00, 'completed', 12, 1, 'Suscripción a servicio de streaming'),                          -- transaction_id: 14
(20, 'transfer', 10000.00, 'completed', 9, 5, 'Transferencia bancaria a CBU externo'),                       -- transaction_id: 15

-- Transacciones con otros estados (no generarán movimientos)
(11, 'payment', 700.00, 'pending', 4, 1, 'Compra de entradas para el cine'),                                 -- transaction_id: 16
(13, 'transfer', 15000.00, 'rejected', 9, 1, 'Transferencia rechazada por fondos insuficientes'),            -- transaction_id: 17
(16, 'payment', 250.00, 'cancelled', 3, 1, 'Compra cancelada por el usuario'),                               -- transaction_id: 18
(9, 'topup', 500.00, 'pending', 10, 6, 'Recarga en efectivo pendiente de acreditación'),                      -- transaction_id: 19
(17, 'transfer', 500.00, 'pending', 9, 1, 'Transferencia pendiente de confirmación');                        -- transaction_id: 20


-- 8. INSERT TRANSFER (registros para transacciones de tipo 'transfer')
INSERT INTO transfer (transaction_id, source_account_id, destination_account_id, destination_cbu, concept) VALUES
-- Transferencia interna (de cuenta 1 a cuenta 2)
(1, 1, 2, NULL, 'Regalo de cumpleaños'),
-- Transferencia externa (de cuenta 5 a un CBU)
(4, 5, NULL, '1234567890123456789012', 'Pago de alquiler'),
-- Transferencia interna (de cuenta 7 a cuenta 8)
(8, 7, 8, NULL, 'División de gastos'),
-- Transferencia interna (de cuenta 15 a cuenta 17)
(10, 15, 17, NULL, 'Préstamo'),
-- Transferencia externa (de cuenta 20 a un CBU)
(15, 20, NULL, '9876543210987654321098', 'Inversión personal');


-- 9. INSERT MOVEMENT (libro contable de débitos y créditos para transacciones completadas)
-- Los saldos se calculan secuencialmente.
-- Saldo inicial Juan (acc 1): 15000.00
-- Saldo inicial María (acc 2): 25000.50
-- Saldo inicial Carlos (acc 3): 5000.75
-- Saldo inicial Ana (acc 4): 30000.00
-- Saldo inicial Luis (acc 5): 12500.00
-- etc.

INSERT INTO movement (account_id, transaction_id, movement_type, amount, previous_balance, new_balance) VALUES
-- Movimientos para transaction_id: 1 (Transferencia de Juan a María)
(1, 1, 'debit', 1000.00, 15000.00, 14000.00),
(2, 1, 'credit', 1000.00, 25000.50, 26000.50),

-- Movimiento para transaction_id: 2 (Pago de Carlos)
(3, 2, 'debit', 500.75, 5000.75, 4500.00),

-- Movimiento para transaction_id: 3 (Recarga de Ana)
(4, 3, 'credit', 2000.00, 30000.00, 32000.00),

-- Movimiento para transaction_id: 4 (Transferencia externa de Luis)
(5, 4, 'debit', 1500.00, 12500.00, 11000.00),

-- Movimiento para transaction_id: 5 (Pago de María)
(2, 5, 'debit', 3500.00, 26000.50, 22500.50), -- El previous_balance es el new_balance del movimiento anterior de la cuenta 2

-- Movimiento para transaction_id: 6 (Retiro de Sofía)
(8, 6, 'debit', 2000.00, 18500.50, 16500.50),

-- Movimiento para transaction_id: 7 (Recarga de Valentina)
(10, 7, 'credit', 5000.00, 35000.75, 40000.75),

-- Movimientos para transaction_id: 8 (Transferencia de Diego a Sofía)
(7, 8, 'debit', 2500.00, 20000.00, 17500.00),
(8, 8, 'credit', 2500.00, 16500.50, 19000.50), -- El previous_balance es el new_balance del movimiento anterior de la cuenta 8

-- Movimiento para transaction_id: 9 (Pago de Camila)
(12, 9, 'debit', 1250.50, 22000.00, 20749.50),

-- Movimientos para transaction_id: 10 (Transferencia de Santiago a Joaquín)
(15, 10, 'debit', 3000.00, 19000.25, 16000.25),
(17, 10, 'credit', 3000.00, 6500.00, 9500.00),

-- Movimiento para transaction_id: 11 (Pago de Juan)
(1, 11, 'debit', 850.25, 14000.00, 13149.75), -- El previous_balance es el new_balance del movimiento anterior de la cuenta 1

-- Movimiento para transaction_id: 12 (Recarga de Laura)
(6, 12, 'credit', 1000.00, 8000.25, 9000.25),

-- Movimiento para transaction_id: 13 (Retiro de Lucía)
(14, 13, 'debit', 1500.00, 16500.00, 15000.00),

-- Movimiento para transaction_id: 14 (Pago de Martina)
(18, 14, 'debit', 450.00, 24500.50, 24050.50),

-- Movimiento para transaction_id: 15 (Transferencia externa de Isabella)
(20, 15, 'debit', 10000.00, 31000.75, 21000.75);


-- 10. INSERT AUDIT_LOG (20+ records)
-- Registros de auditoría para diversas acciones en el sistema.
INSERT INTO audit_log (user_id, action, affected_table, record_id, description, ip_address) VALUES
(1, 'LOGIN_SUCCESS', 'user', 1, 'User logged in successfully', '192.168.1.10'),
(2, 'LOGIN_SUCCESS', 'user', 2, 'User logged in successfully', '200.50.12.34'),
(3, 'PROFILE_UPDATE', 'user', 3, 'User updated their phone number', '192.168.1.12'),
(4, 'PASSWORD_CHANGE', 'user', 4, 'User changed their password', '180.25.1.99'),
(19, 'ACCOUNT_DEACTIVATION', 'user', 19, 'User deactivated their own account', '210.10.5.23'),
(22, 'ADMIN_ACTION: BLOCK_USER', 'user', 22, 'Admin blocked user due to suspicious activity', '10.0.0.1'),
(5, 'LOGIN_SUCCESS', 'user', 5, 'User logged in successfully', '192.168.1.15'),
(6, 'CARD_LINKED', 'card', 6, 'User linked a new credit card', '201.30.15.45'),
(7, 'LOGIN_FAIL', 'user', 7, 'Failed login attempt (wrong password)', '192.168.1.18'),
(8, 'LOGIN_SUCCESS', 'user', 8, 'User logged in successfully', '188.45.2.88'),
(9, 'ADDRESS_ADDED', 'address', 9, 'User added a new address', '192.168.1.20'),
(10, 'LOGIN_SUCCESS', 'user', 10, 'User logged in successfully', '205.60.25.55'),
(1, 'TRANSACTION_CREATED', 'transaction', 1, 'User initiated a transfer', '192.168.1.10'),
(3, 'TRANSACTION_CREATED', 'transaction', 2, 'User made a payment', '192.168.1.12'),
(4, 'TRANSACTION_CREATED', 'transaction', 3, 'User topped up their account', '180.25.1.99'),
(11, 'LOGIN_SUCCESS', 'user', 11, 'User logged in successfully', '192.168.1.22'),
(12, 'LOGIN_SUCCESS', 'user', 12, 'User logged in successfully', '202.35.18.48'),
(15, 'LOGIN_SUCCESS', 'user', 15, 'User logged in successfully', '192.168.1.30'),
(2, 'CARD_DELETED', 'card', NULL, 'User removed a secondary card', '200.50.12.34'),
(20, 'LOGIN_SUCCESS', 'user', 20, 'User logged in successfully', '185.40.5.77'),
(21, 'LOGIN_FAIL', 'user', 21, 'Failed login attempt (wrong password)', '192.168.1.40'),
(18, 'LOGIN_SUCCESS', 'user', 18, 'User logged in successfully', '190.55.22.66');
