
USE PerformanceDemo;
GO

-- Customers: City lookup, with Name and Email included
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Customers')
      AND name = N'IX_Customers_City'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_City
    ON dbo.Customers (City)
    INCLUDE (Name, Email);
END;
GO

-- Orders: CustomerId, TotalAmount, OrderDate
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Orders')
      AND name = N'IX_Orders_CustomerId_Amount_OrderDate'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_Amount_OrderDate
    ON dbo.Orders (CustomerId, TotalAmount, OrderDate);
END;
GO

-- Orders: CustomerId, OrderDate, with TotalAmount included
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Orders')
      AND name = N'IX_Orders_CustomerId_OrderDate'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_OrderDate
    ON dbo.Orders (CustomerId, OrderDate)
    INCLUDE (TotalAmount);
END;
GO

-- Orders: OrderDate, CustomerId, with TotalAmount included
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Orders')
      AND name = N'IX_Orders_OrderDate_CustomerId'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_CustomerId
    ON dbo.Orders (OrderDate, CustomerId)
    INCLUDE (TotalAmount);
END;
GO

-- Covering index for the optimized orders endpoint
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Orders')
      AND name = N'IX_Orders_OrderDate_Id'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_Id
    ON dbo.Orders (OrderDate, Id)
    INCLUDE (CustomerId, TotalAmount);
END;
GO
