CREATE DATABASE risk_detection_engine;
USE risk_detection_engine;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    segment VARCHAR(20), -- Retail, Corporate, SME
    registration_date DATE NOT NULL
);

INSERT INTO Customers VALUES
(1,'Ali Khan','Lahore','Retail','2023-01-10'),
(2,'Sara Ahmed','Karachi','Corporate','2023-02-15'),
(3,'Bilal Sheikh','Islamabad','Retail','2023-03-01'),
(4,'Ayesha Malik','Lahore','SME','2023-04-12'),
(5,'Hassan Raza','Karachi','Retail','2023-05-18'),
(6,'Fatima Noor','Islamabad','Corporate','2023-06-20'),
(7,'Usman Tariq','Lahore','SME','2023-07-05'),
(8,'Zainab Ali','Karachi','Retail','2023-08-11'),
(9,'Omar Farooq','Islamabad','Corporate','2023-09-22'),
(10,'Mariam Saeed','Lahore','Retail','2023-10-30'),
(11,'Ahmad Javed','Karachi','SME','2023-11-12'),
(12,'Hira Shah','Islamabad','Retail','2023-12-01'),
(13,'Imran Iqbal','Lahore','Corporate','2024-01-15'),
(14,'Sana Tariq','Karachi','Retail','2024-02-20'),
(15,'Tariq Mehmood','Islamabad','SME','2024-03-10'),
(16,'Nadia Khan','Lahore','Retail','2024-04-05'),
(17,'Hamza Ali','Karachi','Corporate','2024-05-12'),
(18,'Kiran Malik','Islamabad','Retail','2024-06-18'),
(19,'Adnan Shah','Lahore','SME','2024-07-09'),
(20,'Mehak Raza','Karachi','Retail','2024-08-25');

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20), -- Savings, Current, Investment
    opening_balance DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    open_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Accounts VALUES
(101,1,'Savings',50000,5.5,'2023-01-15'),
(102,2,'Current',120000,0,'2023-02-20'),
(103,3,'Investment',200000,8.5,'2023-03-05'),
(104,4,'Savings',75000,5.5,'2023-04-18'),
(105,5,'Savings',60000,5.5,'2023-05-25'),
(106,6,'Investment',300000,9.0,'2023-06-25'),
(107,7,'Current',90000,0,'2023-07-12'),
(108,8,'Savings',45000,5.5,'2023-08-15'),
(109,9,'Investment',400000,8.0,'2023-09-30'),
(110,10,'Savings',55000,5.5,'2023-10-31'),
(111,11,'Current',110000,0,'2023-11-20'),
(112,12,'Savings',65000,5.5,'2023-12-10'),
(113,13,'Investment',250000,8.5,'2024-01-20'),
(114,14,'Savings',70000,5.5,'2024-02-25'),
(115,15,'Current',130000,0,'2024-03-15'),
(116,16,'Savings',48000,5.5,'2024-04-12'),
(117,17,'Investment',350000,9.2,'2024-05-20'),
(118,18,'Savings',52000,5.5,'2024-06-22'),
(119,19,'Current',80000,0,'2024-07-15'),
(120,20,'Savings',62000,5.5,'2024-08-28');

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10), -- Deposit, Withdrawal
    amount DECIMAL(12,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

INSERT INTO Transactions VALUES
(1001,101,'Deposit',10000,'2024-01-05'),
(1002,101,'Withdrawal',5000,'2024-02-10'),
(1003,103,'Deposit',25000,'2024-03-15'),
(1004,104,'Deposit',12000,'2024-04-01'),
(1005,105,'Withdrawal',8000,'2024-04-10'),
(1006,106,'Deposit',50000,'2024-05-05'),
(1007,108,'Deposit',7000,'2024-05-12'),
(1008,109,'Withdrawal',20000,'2024-06-02'),
(1009,110,'Deposit',9000,'2024-06-20'),
(1010,112,'Deposit',15000,'2024-07-01'),
(1011,113,'Withdrawal',30000,'2024-07-10'),
(1012,114,'Deposit',11000,'2024-07-18'),
(1013,115,'Withdrawal',10000,'2024-08-05'),
(1014,116,'Deposit',6000,'2024-08-15'),
(1015,117,'Deposit',40000,'2024-08-22'),
(1016,118,'Withdrawal',7000,'2024-09-01'),
(1017,119,'Deposit',8000,'2024-09-10'),
(1018,120,'Deposit',10000,'2024-09-15'),
(1019,103,'Withdrawal',12000,'2024-09-20'),
(1020,106,'Withdrawal',15000,'2024-09-25');

WITH AccountActivity AS (
    -- Calculate transaction metrics per account
    SELECT 
        a.account_id,
        a.customer_id,
        a.account_type,
        a.opening_balance,
        a.open_date,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END) AS total_deposits,
        SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals,
        MAX(t.transaction_date) AS last_transaction_date,
        DATEDIFF(CURDATE(), a.open_date) AS days_since_opened,
        DATEDIFF(CURDATE(), COALESCE(MAX(t.transaction_date), a.open_date)) AS days_inactive
    FROM Accounts a
    LEFT JOIN Transactions t ON a.account_id = t.account_id
    GROUP BY a.account_id, a.customer_id, a.account_type, a.opening_balance, a.open_date
),
HighValueThreshold AS (
    -- Define high-value threshold (80% of average opening balance)
    SELECT AVG(opening_balance) * 0.8 AS high_value_threshold
    FROM Accounts
),
CustomerBehavior AS (
    -- Analyze customer behavior patterns
    SELECT 
        c.customer_id,
        c.customer_name,
        c.segment,
        COUNT(DISTINCT a.account_id) AS account_count,
        SUM(a.opening_balance) AS total_balance,
        AVG(aa.transaction_count) AS avg_transactions_per_account,
        SUM(aa.total_deposits) AS total_deposits,
        SUM(aa.total_withdrawals) AS total_withdrawals,
        SUM(aa.total_deposits - aa.total_withdrawals) AS net_flow
    FROM Customers c
    INNER JOIN Accounts a ON c.customer_id = a.customer_id
    LEFT JOIN AccountActivity aa ON a.account_id = aa.account_id
    GROUP BY c.customer_id, c.customer_name, c.segment
),
SimilarBehavior AS (
    -- Identify customers with similar transaction patterns (SELF JOIN)
    SELECT 
        cb1.customer_id AS customer1_id,
        cb1.customer_name AS customer1_name,
        cb2.customer_id AS customer2_id,
        cb2.customer_name AS customer2_name,
        ABS(cb1.total_deposits - cb2.total_deposits) AS deposit_diff,
        ABS(cb1.total_withdrawals - cb2.total_withdrawals) AS withdrawal_diff,
        ABS(cb1.net_flow - cb2.net_flow) AS net_flow_diff
    FROM CustomerBehavior cb1
    INNER JOIN CustomerBehavior cb2 ON cb1.customer_id < cb2.customer_id
    WHERE ABS(cb1.total_deposits - cb2.total_deposits) < 5000
      AND ABS(cb1.total_withdrawals - cb2.total_withdrawals) < 5000
      AND cb1.customer_id != cb2.customer_id
),
HiddenRelationships AS (
    -- Find potential hidden relationships (customers from same city, segment with similar patterns)
    SELECT 
        c1.customer_id AS customer_id_1,
        c2.customer_id AS customer_id_2,
        c1.city AS shared_city,
        c1.segment AS shared_segment
    FROM Customers c1
    INNER JOIN Customers c2 ON c1.city = c2.city AND c1.segment = c2.segment AND c1.customer_id < c2.customer_id
)

-- Final output with Account Flag
SELECT 
    aa.account_id,
    c.customer_id,
    c.customer_name,
    c.city,
    c.segment,
    aa.account_type,
    aa.opening_balance,
    aa.transaction_count,
    aa.total_deposits,
    aa.total_withdrawals,
    aa.last_transaction_date,
    aa.days_inactive,
    CASE 
        -- Flag 1: High-value but underutilized (balance above threshold, less than 3 transactions, inactive > 60 days)
        WHEN aa.opening_balance > (SELECT high_value_threshold FROM HighValueThreshold) 
             AND aa.transaction_count < 3 
             AND aa.days_inactive > 60 
        THEN 'HIGH_VALUE_UNDERUTILIZED'
        
        -- Flag 2: High-value with irregular behavior (withdrawals > 150% of deposits)
        WHEN aa.opening_balance > (SELECT high_value_threshold FROM HighValueThreshold)
             AND aa.total_withdrawals > aa.total_deposits * 1.5
             AND aa.transaction_count > 0
        THEN 'HIGH_VALUE_IRREGULAR_WITHDRAWALS'
        
        -- Flag 3: Completely dormant high-value account (no transactions, inactive > 90 days)
        WHEN aa.opening_balance > (SELECT high_value_threshold FROM HighValueThreshold)
             AND aa.transaction_count = 0
             AND aa.days_inactive > 90
        THEN 'HIGH_VALUE_DORMANT'
        
        -- Flag 4: Accounts with potential hidden relationships (multiple accounts same customer)
        WHEN (SELECT COUNT(*) FROM Accounts a2 WHERE a2.customer_id = aa.customer_id) > 1
        THEN 'MULTIPLE_ACCOUNTS_HIDDEN_RELATIONSHIP'
        
        -- Flag 5: Suspicious activity pattern (large single withdrawal > 50% of balance)
        WHEN EXISTS (
            SELECT 1 FROM Transactions t 
            WHERE t.account_id = aa.account_id 
              AND t.amount > aa.opening_balance * 0.5
              AND t.transaction_type = 'Withdrawal'
        ) THEN 'LARGE_SINGLE_WITHDRAWAL'
        
        -- Flag 6: Similar behavior with unlinked customers
        WHEN EXISTS (
            SELECT 1 FROM SimilarBehavior sb 
            WHERE (sb.customer1_id = aa.customer_id OR sb.customer2_id = aa.customer_id)
        ) THEN 'SIMILAR_BEHAVIOR_WITH_UNLINKED_CUSTOMER'
        
        -- Flag 7: Inactive with irregular timing (inactive > 30 days, last activity > 3 months ago)
        WHEN aa.days_inactive > 30 
             AND aa.transaction_count > 0 
             AND aa.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
        THEN 'INACTIVE_IRREGULAR_TIMING'
        
        ELSE 'NORMAL_ACTIVITY'
    END AS Account_Flag,
    
    -- Additional calculated fields for analytical depth
    ROUND((aa.total_withdrawals / NULLIF(aa.opening_balance, 0)) * 100, 2) AS withdrawal_to_balance_ratio,
    ROUND(aa.total_deposits / NULLIF(aa.total_withdrawals, 0), 2) AS deposit_withdrawal_ratio,
    DATEDIFF(COALESCE(aa.last_transaction_date, aa.open_date), aa.open_date) AS days_to_first_activity,
    
    -- Show similar customers if flagged (MySQL's GROUP_CONCAT instead of STRING_AGG)
    (SELECT GROUP_CONCAT(DISTINCT customer2_name SEPARATOR ', ')
     FROM SimilarBehavior sb 
     WHERE sb.customer1_id = aa.customer_id OR sb.customer2_id = aa.customer_id) AS similar_customers

FROM AccountActivity aa
INNER JOIN Customers c ON aa.customer_id = c.customer_id
LEFT JOIN Transactions t ON aa.account_id = t.account_id
RIGHT JOIN Accounts a ON aa.account_id = a.account_id

GROUP BY 
    aa.account_id, c.customer_id, c.customer_name, c.city, c.segment,
    aa.account_type, aa.opening_balance, aa.transaction_count, 
    aa.total_deposits, aa.total_withdrawals, aa.last_transaction_date, 
    aa.days_inactive, aa.open_date, aa.days_since_opened

ORDER BY 
    FIELD(Account_Flag, 
          'HIGH_VALUE_UNDERUTILIZED', 
          'HIGH_VALUE_IRREGULAR_WITHDRAWALS', 
          'HIGH_VALUE_DORMANT',
          'MULTIPLE_ACCOUNTS_HIDDEN_RELATIONSHIP',
          'LARGE_SINGLE_WITHDRAWAL',
          'SIMILAR_BEHAVIOR_WITH_UNLINKED_CUSTOMER',
          'INACTIVE_IRREGULAR_TIMING',
          'NORMAL_ACTIVITY'),
    aa.opening_balance DESC;