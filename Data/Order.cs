namespace SqlPerformanceApi.Data
{
    public class Order
    {
        public int Id { get; set; }
        public int CustomerId { get; set; }

        public DateTime OrderDate { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
