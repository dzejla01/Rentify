using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class AnswerService 
        : BaseCRUDService<AnswerResponse, AnswerSearchObject, Answer, AnswerUpsertRequest, AnswerUpsertRequest>, IAnswerService
    {
        public AnswerService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Answer> ApplyFilter(IQueryable<Answer> query, AnswerSearchObject search)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.Question);

            if (search.QuestionId.HasValue)
                query = query.Where(x => x.QuestionId == search.QuestionId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query.Where(x => x.Content.Contains(search.FTS));

            return base.ApplyFilter(query, search);
        }


        protected override async Task BeforeInsert(Answer entity, AnswerUpsertRequest request)
        {
            entity.CreatedAt = DateTime.UtcNow;

            var question = await _context.Questions.FindAsync(new object[] { request.QuestionId });
            if (question != null)
            {
                question.IsAnswered = true;
            }
            await base.BeforeInsert(entity, request);
        }
    }
}