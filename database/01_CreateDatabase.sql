
IF DB_ID(N'PerformanceDemo') IS NULL
BEGIN
    CREATE DATABASE PerformanceDemo;
END;
GO

USE PerformanceDemo;
GO

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers
    (
        Id INT IDENTITY(1,1) NOT NULL,
        Name NVARCHAR(100) NULL,
        Email NVARCHAR(150) NULL,
        City NVARCHAR(100) NULL,

        CONSTRAINT PK_Customers PRIMARY KEY (Id)
    );
END;
GO

IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        Id INT IDENTITY(1,1) NOT NULL,
        CustomerId INT NOT NULL,
        OrderDate DATETIME2 NOT NULL,
        TotalAmount DECIMAL(18,2) NOT NULL,

        CONSTRAINT PK_Orders PRIMARY KEY (Id),
        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES dbo.Customers(Id)
    );
END;
GO
