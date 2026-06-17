using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.Services.Services
{
    public class QuestionService
        : BaseCRUDService<QuestionResponse, QuestionSearchObject, Question, QuestionUpsertRequest, QuestionUpsertRequest>, IQuestionService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public QuestionService(RentifyDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private int? GetLoggedInUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }

        private bool IsAdmin()
            => _httpContextAccessor.HttpContext?.User.IsInRole("Admin") ?? false;

        protected override IQueryable<Question> ApplyFilter(IQueryable<Question> query, QuestionSearchObject search)
        {

            if(search.OwnerId.HasValue)
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (search.IsAnswered.HasValue)
                query = query.Where(x => x.IsAnswered == search.IsAnswered.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = string.Join(" ", search.FTS.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(x =>
                    x.Content.ToLower().Contains(fts)
                    || x.Property.Name.ToLower().Contains(fts)
                    || x.User.FirstName.ToLower().Contains(fts)
                    || x.User.LastName.ToLower().Contains(fts)
                    || (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(fts)
                    || (x.User.LastName + " " + x.User.FirstName).ToLower().Contains(fts));
            }

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
            entity.IsAnswered = false;
            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Question entity, QuestionUpsertRequest request)
        {
            if (!IsAdmin())
            {
                var loggedInId = GetLoggedInUserId()
                    ?? throw new ForbiddenException("Korisnik nije autentificiran.");

                if (entity.UserId == loggedInId)
                {
                    request.UserId = entity.UserId;
                    request.PropertyId = entity.PropertyId;
                }
                else
                {
                    var propertyOwnerId = await _context.Properties
                        .Where(p => p.Id == entity.PropertyId)
                        .Select(p => p.UserId)
                        .FirstOrDefaultAsync();

                    if (propertyOwnerId != loggedInId)
                        throw new ForbiddenException("Nemate pravo mijenjati ovo pitanje.");

                    request.UserId = entity.UserId;
                    request.PropertyId = entity.PropertyId;
                    request.Content = entity.Content;
                }
            }

            // IsAnswered se racuna isključivo preko postojanja odgovora (AnswerService),
            // nikad direktno kroz Question update — sprjecava neusklađenost sa stvarnim odgovorom.
            request.IsAnswered = entity.IsAnswered;

            await base.BeforeUpdate(entity, request);
        }
    }
}
