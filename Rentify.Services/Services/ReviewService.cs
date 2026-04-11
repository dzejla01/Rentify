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
                );
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.Reservation.UserId == search.UserId);
            }

            if (search.OwnersPropertyId.HasValue)
            {
                query = query.Where(x => x.Reservation.Property.UserId == search.OwnersPropertyId);
            }

            if (search.ReservationId.HasValue && search.ReservationId.Value > 0)
            {
                query = query.Where(x => x.ReservationId == search.ReservationId.Value);
            }

            return query;
        }

        protected override IQueryable<Review> AddInclude(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = base.AddInclude(query, search);

            if (search.IncludeReservation == true)
            {
                query = query
                    .Include(x => x.Reservation)
                    .ThenInclude(r => r.User);

                query = query
                    .Include(x => x.Reservation)
                    .ThenInclude(r => r.Property);
            }

            return query;
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            if (request.ReservationId <= 0)
                throw new InvalidOperationException("ReservationId je obavezan.");

            if (string.IsNullOrWhiteSpace(request.Comment))
                throw new InvalidOperationException("Komentar je obavezan.");

            if (request.StarRate < 1 || request.StarRate > 5)
                throw new InvalidOperationException("Ocjena mora biti u rasponu od 1 do 5.");

            var reservation = await _context.Reservations
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == request.ReservationId);

            if (reservation == null)
                throw new NotFoundException("Rezervacija ne postoji.");

            if (reservation.Status != "Odobreno" && reservation.Status != "Završeno")
            {
                throw new InvalidOperationException(
                    "Recenziju je moguće ostaviti samo za odobrenu ili završenu rezervaciju."
                );
            }

            var alreadyReviewed = await _context.Reviews
                .AsNoTracking()
                .AnyAsync(x => x.ReservationId == request.ReservationId);

            if (alreadyReviewed)
            {
                throw new InvalidOperationException(
                    "Već postoji recenzija za ovu rezervaciju."
                );
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            if (request.ReservationId <= 0)
                throw new InvalidOperationException("ReservationId je obavezan.");

            if (string.IsNullOrWhiteSpace(request.Comment))
                throw new InvalidOperationException("Komentar je obavezan.");

            if (request.StarRate < 1 || request.StarRate > 5)
                throw new InvalidOperationException("Ocjena mora biti u rasponu od 1 do 5.");

            var reservationExists = await _context.Reservations
                .AsNoTracking()
                .AnyAsync(x => x.Id == request.ReservationId);

            if (!reservationExists)
                throw new NotFoundException("Rezervacija ne postoji.");

            var duplicateReview = await _context.Reviews
                .AsNoTracking()
                .AnyAsync(x => x.ReservationId == request.ReservationId && x.Id != entity.Id);

            if (duplicateReview)
            {
                throw new InvalidOperationException(
                    "Već postoji recenzija za ovu rezervaciju."
                );
            }

            await base.BeforeUpdate(entity, request);
        }
    }
}