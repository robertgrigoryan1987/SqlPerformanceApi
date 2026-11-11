using Microsoft.AspNetCore.Mvc;
using SqlPerformanceApi.Data;
using Microsoft.EntityFrameworkCore;

namespace SqlPerformanceApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly AppDbContext _context;
        
        public OrdersController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("GetOrders")]
        public async Task<IActionResult> GetOrders()
        {
            var orders = await _context.Orders.CountAsync();
            return Ok(new { Message = "Total number of orders:", Count = orders });
        }

        [HttpGet("slow")]
        public async Task<IActionResult> GetOrdersSlow()
        {
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();

            // Load all orders from SQL Server into memory.
            var query = _context.Orders;

            var generatedSql = query.ToQueryString();

            var allOrders = await query.ToListAsync();

            // Sort and select the first 50 in application memory.
            var orders = allOrders
                .OrderByDescending(o => o.OrderDate)
                .ThenByDescending(o => o.Id)
                .Take(50)
                .Select(o => new
                {
                    o.Id,
                    o.CustomerId,
                    o.OrderDate,
                    o.TotalAmount
                })
                .ToList();

            stopwatch.Stop();

            return Ok(new
            {
                Method = "Slow",
                ReturnedOrders = orders.Count,
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds,
                GeneratedSql = generatedSql,
                Orders = orders
            });
        }

        [HttpGet("optimized")]
        public async Task<IActionResult> GetOrdersOptimized()
        {
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();

            var query = _context.Orders
                .AsNoTracking()
                .OrderByDescending(o => o.OrderDate)
                .ThenByDescending(o => o.Id)
                .Select(o => new
                {
                    o.Id,
                    o.CustomerId,
                    o.OrderDate,
                    o.TotalAmount
                })
                .Take(50);
            var generatedSql = query.ToQueryString();

            var orders = await query.ToListAsync();
            stopwatch.Stop();

            return Ok(new
            {
                Method = "Optimized",
                ReturnedOrders = orders.Count,
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds,
                Orders = orders
            });
        }
    }
}
