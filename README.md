# SqlPerformanceApi
ASP.NET Core and SQL Server performance optimization demonstration.
# SQL Performance Optimization with ASP.NET Core and EF Core

A practical demonstration of identifying and fixing inefficient Entity Framework Core data access in an ASP.NET Core Web API using SQL Server.

## The Problem

Retrieving only 50 records from a database containing 1,000,000 orders should not require loading the entire table into application memory.

The original implementation retrieves all orders and performs sorting and filtering in application memory. This creates unnecessary database reads, memory usage, and processing overhead.

## The Solution

I implemented two endpoints to compare inefficient and optimized data access:

| Endpoint | Approach |
|---|---|
| `GET /api/orders/slow` | Loads the full dataset before sorting and selecting 50 records |
| `GET /api/orders/optimized` | Uses SQL Server to sort, limit, and return only 50 records |

The optimized implementation uses:

- `AsNoTracking()` to avoid unnecessary EF Core change tracking.
- Database-side sorting and projection.
- `Take(50)` to limit the number of returned records.
- A suitable SQL Server index to support the ordering.

## Database and Index

Test database: `PerformanceDemo`

Dataset:
- 100,000 customers
- 1,000,000 orders

Relevant index:

`IX_Orders_OrderDate_Id`

This index supports the ordering by `OrderDate` and `Id`.

## SQL Execution Plan Analysis

The optimized query generates SQL equivalent to:

```sql
SELECT TOP (50)
    [o].[Id],
    [o].[CustomerId],
    [o].[OrderDate],
    [o].[TotalAmount]
FROM [Orders] AS [o]
ORDER BY [o].[OrderDate] DESC, [o].[Id] DESC;
```

Actual execution plan observations:

- Index Scan on `IX_Orders_OrderDate_Id`
- Actual rows: 50
- Actual rows read: 50
- Logical reads: 3
- Physical reads: 0
- No Sort operator
- Memory grant: 0 KB

**Important:** An Index Scan is not automatically inefficient. In this case, SQL Server reads only 50 index entries and avoids an additional Sort operation.

## Performance Measurements

Observed controller-side execution times during local testing:

| Implementation | Observed time |
|---|---:|
| Slow | 39,686 ms |
| Optimized — run 1 | 168 ms |
| Optimized — run 2 | 17 ms |
| Optimized — run 3 | 12 ms |
| Optimized — run 4 | 10 ms |
| Optimized — run 5 | 6 ms |

These are individual local observations, not results from a controlled benchmark. The first optimized run may include warm-up effects.

The stopwatch measures controller-side elapsed time and excludes response serialization.

## Technologies

- C#
- ASP.NET Core Web API
- Entity Framework Core
- SQL Server
- LINQ
- SQL execution plans
- Git and GitHub

## Running the Project

1. Clone the repository.
2. Open the project in Visual Studio or your preferred .NET IDE.
3. Create or configure a SQL Server database named `PerformanceDemo` with the required `Customers` and `Orders` tables, data, and index.
4. Configure the connection string using .NET User Secrets:

```powershell
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "YOUR_CONNECTION_STRING"
```

5. Run the API:

```powershell
dotnet run
```

6. Test the endpoints:

```text
GET /api/orders/slow
GET /api/orders/optimized
```

## What This Project Demonstrates

This project demonstrates practical skills in:

- Diagnosing inefficient EF Core queries.
- Understanding LINQ execution and query translation.
- Moving data processing from application memory to SQL Server.
- Analyzing actual SQL execution plans.
- Using indexes to improve query performance.
- Measuring and explaining optimization results.

**Focus:** SQL Server and EF Core performance investigation and optimization.
