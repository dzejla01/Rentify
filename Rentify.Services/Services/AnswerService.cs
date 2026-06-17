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
    public class AnswerService
        : BaseCRUDService<AnswerResponse, AnswerSearchObject, Answer, AnswerUpsertRequest, AnswerUpsertRequest>, IAnswerService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AnswerService(RentifyDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
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

        protected override IQueryable<Answer> ApplyFilter(IQueryable<Answer> query, AnswerSearchObject search)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.Question);

            if (search.QuestionId.HasValue)
                query = query.Where(x => x.QuestionId == search.QuestionId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = string.Join(" ", search.FTS.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(x =>
                    x.Content.ToLower().Contains(fts)
                    || x.User.FirstName.ToLower().Contains(fts)
                    || x.User.LastName.ToLower().Contains(fts)
                    || (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(fts)
                    || (x.User.LastName + " " + x.User.FirstName).ToLower().Contains(fts)
                    || x.Question.Content.ToLower().Contains(fts));
            }

            return base.ApplyFilter(query, search);
        }


        protected override async Task BeforeInsert(Answer entity, AnswerUpsertRequest request)
        {
            entity.CreatedAt = DateTime.UtcNow;

            var question = await _context.Questions
                .Include(q => q.Property)
                .FirstOrDefaultAsync(q => q.Id == request.QuestionId);

            if (question == null)
                throw new NotFoundException("Pitanje ne postoji.");

            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            if (question.Property == null || question.Property.UserId != loggedInId)
                throw new ForbiddenException("Možete odgovarati samo na pitanja za vaše nekretnine.");

            var existingAnswer = await _context.Answers
                .AnyAsync(a => a.QuestionId == request.QuestionId);

            if (existingAnswer)
                throw new InvalidOperationException("Pitanje već ima odgovor. Koristite update za izmjenu.");

            question.IsAnswered = true;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeDelete(Answer entity)
        {
            var question = await _context.Questions.FindAsync(entity.QuestionId);
            if (question != null)
                question.IsAnswered = false;

            await base.BeforeDelete(entity);
        }

        protected override async Task BeforeUpdate(Answer entity, AnswerUpsertRequest request)
        {
            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            var isAdmin = _httpContextAccessor.HttpContext?.User.IsInRole("Admin") ?? false;

            if (!isAdmin && entity.UserId != loggedInId)
                throw new ForbiddenException("Samo autor odgovora ili admin može mijenjati odgovor.");

            request.UserId = entity.UserId;
            request.QuestionId = entity.QuestionId;

            await base.BeforeUpdate(entity, request);
        }
    }
}
