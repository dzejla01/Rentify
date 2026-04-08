using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using Rentify.Model.SearchObjects;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;
using Rentify.Services.Exceptions;

namespace Rentify.Services.Services
{
    public class ReviewService
        : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>,
          IReviewService
    {
        public ReviewService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = base.ApplyFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                var fts = search.FTS.Trim().ToLower();

                query = query.Where(x =>
                    (x.Comment != null && x.Comment.ToLower().Contains(fts))
                    ||
                    (x.User != null &&
                        ((x.User.FirstName + " " + x.User.LastName).ToLower().Contains(fts)))
                );
            }

            return query;
        }

        protected override IQueryable<Review> AddInclude(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = base.AddInclude(query, search);

            if (search.IncludeUser == true)
            {
                query = query.Include(x => x.User);
            }

            if (search.IncludeProperty == true)
            {
                query = query.Include(x => x.Property);
            }

            return query;
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            if (request.UserId <= 0)
                throw new InvalidOperationException("UserId je obavezan.");

            if (request.PropertyId <= 0)
                throw new InvalidOperationException("PropertyId je obavezan.");

            if (request.StarRate < 1 || request.StarRate > 5)
                throw new InvalidOperationException("Ocjena mora biti u rasponu od 1 do 5.");

            var propertyExists = await _context.Properties
                .AsNoTracking()
                .AnyAsync(x => x.Id == request.PropertyId);

            if (!propertyExists)
                throw new NotFoundException("Nekretnina ne postoji.");

            var userExists = await _context.Users
                .AsNoTracking()
                .AnyAsync(x => x.Id == request.UserId);

            if (!userExists)
                throw new NotFoundException("Korisnik ne postoji.");

            var hasReservation = await _context.Reservations
                .AsNoTracking()
                .AnyAsync(r =>
                    r.UserId == request.UserId &&
                    r.PropertyId == request.PropertyId &&
                    (r.Status == "Odobreno" || r.Status == "Završeno"));

            if (!hasReservation)
            {
                throw new InvalidOperationException(
                    "Recenziju može ostaviti samo korisnik koji ima rezervaciju za ovu nekretninu."
                );
            }

            var alreadyReviewed = await _context.Reviews
                .AsNoTracking()
                .AnyAsync(r =>
                    r.UserId == request.UserId &&
                    r.PropertyId == request.PropertyId);

            if (alreadyReviewed)
            {
                throw new InvalidOperationException(
                    "Već ste ostavili recenziju za ovu nekretninu."
                );
            }

            await base.BeforeInsert(entity, request);
        }
    }
}