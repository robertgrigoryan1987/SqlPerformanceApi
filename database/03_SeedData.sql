
USE PerformanceDemo;
GO

SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM dbo.Customers)
   OR EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    THROW 50001,
        'Seed script requires empty Customers and Orders tables.',
        1;
END;
GO

DECLARE @BatchSize INT = 10000;
DECLARE @Start INT = 1;

-- Generate 100,000 customers
WHILE @Start <= 100000
BEGIN
    ;WITH Digits(n) AS
    (
        SELECT n
        FROM (VALUES
            (0),(1),(2),(3),(4),
            (5),(6),(7),(8),(9)
        ) v(n)
    ),
    Numbers AS
    (
        SELECT TOP (@BatchSize)
            @Start + ROW_NUMBER() OVER (
                ORDER BY (SELECT NULL)
            ) - 1 AS N
        FROM Digits a
        CROSS JOIN Digits b
        CROSS JOIN Digits c
        CROSS JOIN Digits d
    )
    INSERT INTO dbo.Customers
        (Name, Email, City)
    SELECT
        CONCAT('Customer ', N),
        CONCAT('customer', N, '@example.com'),
        CASE N % 5
            WHEN 0 THEN 'Yerevan'
            WHEN 1 THEN 'Vanadzor'
            WHEN 2 THEN 'Gyumri'
            WHEN 3 THEN 'Dilijan'
            ELSE 'Armavir'
        END
    FROM Numbers;

    SET @Start += @BatchSize;
END;
GO

-- Generate 1,000,000 orders
DECLARE @BatchSize INT = 10000;
DECLARE @Start INT = 1;

WHILE @Start <= 1000000
BEGIN
    ;WITH Digits(n) AS
    (
        SELECT n
        FROM (VALUES
            (0),(1),(2),(3),(4),
            (5),(6),(7),(8),(9)
        ) v(n)
    ),
    Numbers AS
    (
        SELECT TOP (@BatchSize)
            @Start + ROW_NUMBER() OVER (
                ORDER BY (SELECT NULL)
            ) - 1 AS N
        FROM Digits a
        CROSS JOIN Digits b
        CROSS JOIN Digits c
        CROSS JOIN Digits d
    )
    INSERT INTO dbo.Orders
        (CustomerId, OrderDate, TotalAmount)
    SELECT
        ((N - 1) % 100000) + 1,
        DATEADD(
            DAY,
            -CONVERT(INT, (CONVERT(BIGINT, N) * 37) % 1825),
            CONVERT(DATETIME2, '2026-01-01')
        ),
        CAST(
            10.00 +
            ((CONVERT(BIGINT, N) * 7919) % 100000) / 100.0
            AS DECIMAL(18,2)
        )
    FROM Numbers;

    SET @Start += @BatchSize;
END;
GO

-- Verify generated data
SELECT COUNT(*) AS CustomerCount
FROM dbo.Customers;

SELECT COUNT(*) AS OrderCount
FROM dbo.Orders;
GO

