using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class ExpenseService
        : BaseCRUDService<ExpenseResponse, ExpenseSearchObject, Expense, ExpenseUpsertRequest, ExpenseUpsertRequest>, IExpenseService
    {
        public ExpenseService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Expense> ApplyFilter(IQueryable<Expense> query, ExpenseSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (!string.IsNullOrWhiteSpace(search.Category))
                query = query.Where(x => x.Category == search.Category);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.Date >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.Date <= search.DateTo.Value);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Expense> AddInclude(IQueryable<Expense> query, ExpenseSearchObject search)
        {
            if (search.IncludeProperty.HasValue)
                query = query.Include(x => x.Property);

            if (search.IncludeUser.HasValue)
                query = query.Include(x => x.User);

            return base.AddInclude(query, search);
        }

        protected override Task BeforeInsert(Expense entity, ExpenseUpsertRequest request)
        {
            entity.CreatedAt = DateTime.UtcNow;
            return base.BeforeInsert(entity, request);
        }
    }
}
