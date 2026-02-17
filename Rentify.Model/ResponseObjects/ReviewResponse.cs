namespace Rentify.Model.ResponseObjects
{
    public class ReviewResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public UserResponse? User { get; set; }
        public int PropertyId { get; set; }
        public PropertyResponse? Property { get; set;}

        public string Comment { get; set; } = null!;
        public int StarRate { get; set; }
    }
}
