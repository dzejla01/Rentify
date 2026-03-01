namespace Rentify.Model.ResponseObjects
{
    public class PropertyIncomeDto
    {
        public int PropertyId { get; set; }
        public string PropertyName { get; set; } = "";
        public decimal Total { get; set; }
    }

}