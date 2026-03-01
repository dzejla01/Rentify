using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using Rentify.Model.SearchObjects;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class ReservationService
        : BaseCRUDService<ReservationResponse, ReservationSearchObject, Reservation, ReservationUpsertRequest, ReservationUpsertRequest>,
          IReservationService
    {
        public ReservationService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.OwnerId.HasValue)
            {
                query = query.Where(x => x.Property.UserId == search.OwnerId);
            }

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = search.FTS.Trim().ToLower();

                query = query.Where(r =>

                    (r.Property != null && r.Property.Name.ToLower().Contains(fts))

                    || (r.User != null && r.User.FirstName.ToLower().Contains(fts))

                    || (r.User != null && r.User.LastName.ToLower().Contains(fts))

                    || ("najamnina".Contains(fts) && r.IsMonthly == true)
                    || ("kratki boravak".Contains(fts) && r.IsMonthly == false)

                    || ("odobreno".Contains(fts) && r.IsApproved == true)
                    || ("odbijeno".Contains(fts) && r.IsApproved == false)
                    || ("na čekanju".Contains(fts) && r.IsApproved == null)
                );
            }


            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.PropertyId.HasValue)
            {
                query = query.Where(r => r.PropertyId == search.PropertyId.Value);
            }

            if (search.IsMonthly.HasValue)
            {
                query = query.Where(r => r.IsMonthly == search.IsMonthly.Value);
            }

            if (search.IsApproved.HasValue)
            {
                query = query.Where(r => r.IsApproved == search.IsApproved.Value);
            }

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.IncludeUser.HasValue)
            {
                query = query.Include(p => p.User);
            }

            if (search.IncludeProperty.HasValue)
            {
                query = query.Include(p => p.Property);
            }
            return base.AddInclude(query, search);
        }

        private static DateTime ToUtcDate(DateTime d)
        {
            // uzmi samo datum i označi kao UTC
            return DateTime.SpecifyKind(d.Date, DateTimeKind.Utc);
        }

        public async Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null)
        {
            // ✅ UTC date-only prozor
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var dateTimes = await _context.Appointments
                .AsNoTracking()
                .Where(a => a.PropertyId == propertyId)
                .Where(a => a.IsApproved != false) // approved ili pending
                .Where(a => a.DateAppointment != null)
                .Where(a => a.DateAppointment!.Value >= fromUtc &&
                            a.DateAppointment!.Value < toUtc)
                .Select(a => a.DateAppointment!.Value) // ✅ BITNO — ne .Date
                .Distinct()
                .OrderBy(x => x)
                .ToListAsync();

            return new UnavailableAppointmentsResponse
            {
                PropertyId = propertyId,
                DateTimes = dateTimes
            };
        }

        public async Task<bool> DeleteAll(int id)
        {
            var reservation = await _context.Reservations
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (reservation == null)
                return false;

            var userId = reservation.UserId;
            var propertyId = reservation.PropertyId;

            await using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                await _context.Payments
                    .Where(x => x.UserId == userId && x.PropertyId == propertyId)
                    .ExecuteDeleteAsync();

                await _context.Reviews
                    .Where(x => x.UserId == userId && x.PropertyId == propertyId)
                    .ExecuteDeleteAsync();

                await _context.Appointments
                    .Where(x => x.UserId == userId && x.PropertyId == propertyId)
                    .ExecuteDeleteAsync();

                await _context.Reservations
                    .Where(x => x.UserId == userId && x.PropertyId == propertyId)
                    .ExecuteDeleteAsync();

                await tx.CommitAsync();
                return true;
            }
            catch
            {
                await tx.RollbackAsync();
                throw;
            }
        }
    }
}
