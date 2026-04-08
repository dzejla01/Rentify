//using System;
//using System.Linq;
//using Microsoft.EntityFrameworkCore;
//using MapsterMapper;
//using Rentify.Model.SearchObjects;
//using Rentify.Model.RequestObjects;
//using Rentify.Model.ResponseObjects;
//using Rentify.Services.Database;
//using Rentify.Services.Interfaces;

//namespace Rentify.Services.Services
//{
//    public class ReservationService
//        : BaseCRUDService<ReservationResponse, ReservationSearchObject, Reservation, ReservationUpsertRequest, ReservationUpsertRequest>,
//          IReservationService
//    {
//        public ReservationService(RentifyDbContext context, IMapper mapper)
//            : base(context, mapper)
//        {
//        }

//        protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
//        {
//            if (search.OwnerId.HasValue)
//            {
//                query = query.Where(x => x.Property.UserId == search.OwnerId);
//            }

//            if (!string.IsNullOrWhiteSpace(search.FTS))
//            {
//                var fts = search.FTS.Trim().ToLower();

//                query = query.Where(r =>

//                    (r.Property != null && r.Property.Name.ToLower().Contains(fts))

//                    || (r.User != null && r.User.FirstName.ToLower().Contains(fts))

//                    || (r.User != null && r.User.LastName.ToLower().Contains(fts))

//                    || ("najamnina".Contains(fts) && r.IsMonthly == true)
//                    || ("kratki boravak".Contains(fts) && r.IsMonthly == false)

//                    || ("odobreno".Contains(fts) && r.IsApproved == true)
//                    || ("odbijeno".Contains(fts) && r.IsApproved == false)
//                    || ("na čekanju".Contains(fts) && r.IsApproved == null)
//                );
//            }


//            if (search.UserId.HasValue)
//            {
//                query = query.Where(r => r.UserId == search.UserId.Value);
//            }

//            if (search.PropertyId.HasValue)
//            {
//                query = query.Where(r => r.PropertyId == search.PropertyId.Value);
//            }

//            if (search.IsMonthly.HasValue)
//            {
//                query = query.Where(r => r.IsMonthly == search.IsMonthly.Value);
//            }

//            if (search.IsApproved.HasValue)
//            {
//                query = query.Where(r => r.IsApproved == search.IsApproved.Value);
//            }

//            return base.ApplyFilter(query, search);
//        }

//        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject search)
//        {
//            if (search.IncludeUser.HasValue)
//            {
//                query = query.Include(p => p.User);
//            }

//            if (search.IncludeProperty.HasValue)
//            {
//                query = query.Include(p => p.Property);
//            }
//            return base.AddInclude(query, search);
//        }

//        private static DateTime ToUtcDate(DateTime d)
//        {
//            // uzmi samo datum i označi kao UTC
//            return DateTime.SpecifyKind(d.Date, DateTimeKind.Utc);
//        }

//        public async Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
//            int propertyId,
//            DateTime? from = null,
//            DateTime? to = null)
//        {
//            // ✅ UTC date-only prozor
//            var fromUtc = DateTime.SpecifyKind(
//                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
//                DateTimeKind.Utc);

//            var toUtc = DateTime.SpecifyKind(
//                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
//                DateTimeKind.Utc);

//            var dateTimes = await _context.Appointments
//                .AsNoTracking()
//                .Where(a => a.PropertyId == propertyId)
//                .Where(a => a.IsApproved != false) // approved ili pending
//                .Where(a => a.DateAppointment != null)
//                .Where(a => a.DateAppointment!.Value >= fromUtc &&
//                            a.DateAppointment!.Value < toUtc)
//                .Select(a => a.DateAppointment!.Value) // ✅ BITNO — ne .Date
//                .Distinct()
//                .OrderBy(x => x)
//                .ToListAsync();

//            return new UnavailableAppointmentsResponse
//            {
//                PropertyId = propertyId,
//                DateTimes = dateTimes
//            };
//        }
//    }
//}

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
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = search.FTS.Trim().ToLower();

                query = query.Where(r =>
                    (r.Property != null && r.Property.Name.ToLower().Contains(fts))
                    || (r.User != null && r.User.FirstName.ToLower().Contains(fts))
                    || (r.User != null && r.User.LastName.ToLower().Contains(fts))
                    || (fts.Contains("najamnina") && r.IsMonthly)
                    || (fts.Contains("kratki boravak") && !r.IsMonthly)
                    || (r.Status != null && r.Status.ToLower().Contains(fts))
                    || (fts.Contains("odobreno") && r.Status == "Odobreno")
                    || ((fts.Contains("zavrseno") || fts.Contains("završeno")) && r.Status == "Završeno")
                    || ((fts.Contains("na cekanju") || fts.Contains("na čekanju")) && r.Status == "Na čekanju")
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

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                var status = search.Status.Trim().ToLower();

                query = query.Where(r =>
                    r.Status != null &&
                    r.Status.ToLower() == status);
            }

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.IncludeUser == true)
            {
                query = query.Include(p => p.User);
            }

            if (search.IncludeProperty == true)
            {
                query = query.Include(p => p.Property);
            }

            return base.AddInclude(query, search);
        }

        protected override async Task BeforeUpdate(Reservation entity, ReservationUpsertRequest request)
        {
            var oldStatus = (entity.Status ?? string.Empty).Trim();
            var newStatus = (request.Status ?? entity.Status ?? string.Empty).Trim();

            var propertyId = request.PropertyId != 0
                ? request.PropertyId
                : entity.PropertyId;

            var isMonthly = request.IsMonthly != entity.IsMonthly
                ? request.IsMonthly
                : entity.IsMonthly;

            var start = request.StartDateOfRenting ?? entity.StartDateOfRenting;
            var end = request.EndDateOfRenting ?? entity.EndDateOfRenting;


            if (oldStatus == "Na čekanju" &&
                newStatus == "Odobreno" &&
                isMonthly)
            {
                //if (!start.HasValue || !end.HasValue)
                //    throw new Exception("Najamnina mora imati definisan početni i završni datum.");

                //if (end.Value <= start.Value)
                //    throw new Exception("Datum završetka mora biti nakon datuma početka.");


                var hasApprovedShortStayConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.Id != entity.Id)
                    .Where(r => r.PropertyId == propertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.Status == "Odobreno")
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start.Value < r.EndDateOfRenting!.Value &&
                        end.Value > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedShortStayConflict)
                {
                    throw new InvalidOperationException(
                        "Mjesečna najamnina se ne može odobriti jer ova nekretnina već ima odobren kratki boravak u tom periodu."
                    );
                }

                var property = await _context.Properties
                    .FirstOrDefaultAsync(p => p.Id == propertyId);

                if (property == null)
                    throw new NotFoundException("Nekretnina nije pronađena.");

                property.IsAvailable = false;
            }


            if (oldStatus == "Odobreno" &&
                newStatus != "Odobreno" &&
                isMonthly)
            {
                var property = await _context.Properties
                    .FirstOrDefaultAsync(p => p.Id == propertyId);

                if (property == null)
                    throw new NotFoundException("Nekretnina nije pronađena.");

                property.IsAvailable = true;
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeInsert(Reservation entity, ReservationUpsertRequest request)
        {
            if (request.PropertyId <= 0)
                throw new UserException("Nekretnina je obavezna.");

            if (!request.StartDateOfRenting.HasValue || !request.EndDateOfRenting.HasValue)
                throw new UserException("Početni i završni datum su obavezni.");

            var start = request.StartDateOfRenting.Value;
            var end = request.EndDateOfRenting.Value;

            if (end <= start)
                throw new UserException("Datum završetka mora biti nakon datuma početka.");

            if (!request.IsMonthly)
            {
                var hasApprovedConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.PropertyId == request.PropertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.Status == "Odobreno")
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedConflict)
                {
                    throw new InvalidOperationException(
                        "Rezervacija se ne može kreirati jer ova nekretnina već ima odobren kratki boravak u tom periodu."
                    );
                }
            }

            await base.BeforeInsert(entity, request);
        }

        private static DateTime ToUtcDate(DateTime d)
        {
            return DateTime.SpecifyKind(d.Date, DateTimeKind.Utc);
        }

        public async Task<UnavailableDatesResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var dateTimes = await _context.Appointments
                .AsNoTracking()
                .Where(a => a.PropertyId == propertyId)
                .Where(a => a.IsApproved != false) // approved ili pending appointment
                .Where(a => a.DateAppointment != null)
                .Where(a => a.DateAppointment!.Value >= fromUtc &&
                            a.DateAppointment!.Value < toUtc)
                .Select(a => a.DateAppointment!.Value)
                .Distinct()
                .OrderBy(x => x)
                .ToListAsync();

            return new UnavailableDatesResponse
            {
                PropertyId = propertyId,
                Dates = dateTimes
            };
        }

        public async Task<UnavailableDatesResponse> GetUnavailableReservationDatesAsync(
    int propertyId,
    DateTime? from = null,
    DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var reservations = await _context.Reservations
                .AsNoTracking()
                .Where(r => r.PropertyId == propertyId)
                .Where(r => r.IsMonthly == false)
                .Where(r => r.Status == "Odobreno")
                .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                .Where(r =>
                    r.StartDateOfRenting!.Value.Date <= toUtc &&
                    r.EndDateOfRenting!.Value.Date >= fromUtc)
                .Select(r => new
                {
                    Start = r.StartDateOfRenting!.Value,
                    End = r.EndDateOfRenting!.Value
                })
                .ToListAsync();

            var unavailableDates = new List<DateTime>();

            foreach (var reservation in reservations)
            {
                var start = reservation.Start.ToUniversalTime().Date;
                var end = reservation.End.ToUniversalTime().Date;

                if (start < fromUtc)
                    start = fromUtc;

                if (end > toUtc)
                    end = toUtc;

                for (var day = start; day <= end; day = day.AddDays(1))
                {
                    unavailableDates.Add(DateTime.SpecifyKind(day, DateTimeKind.Utc));
                }
            }

            var distinctDates = unavailableDates
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            return new UnavailableDatesResponse
            {
                PropertyId = propertyId,
                Dates = distinctDates
            };
        }
    }
}
