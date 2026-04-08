using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class QuestionService 
        : BaseCRUDService<QuestionResponse, QuestionSearchObject, Question, QuestionUpsertRequest, QuestionUpsertRequest>, IQuestionService
    {
        public QuestionService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Question> ApplyFilter(IQueryable<Question> query, QuestionSearchObject search)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.Property);

            if(search.OwnerId.HasValue)
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (search.IsAnswered.HasValue)
                query = query.Where(x => x.IsAnswered == search.IsAnswered.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query.Where(x => x.Content.Contains(search.FTS));

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Question> AddInclude(IQueryable<Question> query, QuestionSearchObject search)
        {
            if (search.IncludeUser.HasValue)
                query = query.Include(x => x.User);
            if (search.IncludeProperty.HasValue)
                query = query.Include(x => x.Property);
            if (search.IncludeAnswer.HasValue)
                query = query.Include(x => x.Answer);

            return base.AddInclude(query, search);
        }

        protected override async Task BeforeInsert(Question entity, QuestionUpsertRequest request)
        {
            entity.CreatedAt = DateTime.UtcNow;
            await base.BeforeInsert(entity, request);
        }
    }
}