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
    public class AppointmentService
        : BaseCRUDService<AppointmentResponse, AppointmentSearchObject, Appointment, AppointmentUpsertRequest, AppointmentUpsertRequest>,
          IAppointmentService
    {
        public AppointmentService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Appointment> AddInclude(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            if (search.IncludeProperty.HasValue)
            {
                query = query.Include(p => p.Property);
            }

            if (search.IncludeUser.HasValue)
            {
                query = query.Include(p => p.User);
            }
            return base.AddInclude(query, search);
        }

        protected override IQueryable<Appointment> ApplyFilter(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            query = base.ApplyFilter(query, search);

            if (search.OwnerId.HasValue)
            {
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);
            }

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (search.IsApproved.HasValue)
                query = query.Where(x => x.IsApproved == search.IsApproved.Value);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.DateAppointment >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.DateAppointment <= search.DateTo.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = search.FTS.Trim().ToLower();

                query = query.Where(a =>
                    (a.Property != null && a.Property.Name.ToLower().Contains(fts))

                    || (a.User != null && a.User.FirstName.ToLower().Contains(fts))
                    || (a.User != null && a.User.LastName.ToLower().Contains(fts))

                    || ("odobreno".Contains(fts) && a.IsApproved == true)
                    || ("odbijeno".Contains(fts) && a.IsApproved == false)
                    || ("na čekanju".Contains(fts) && a.IsApproved == null)
                );
            }


            return query;
        }

        public async Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
   int propertyId,
   DateTime? from = null,
   DateTime? to = null)
        {

            var fromUtc = DateTime.SpecifyKind((from ?? DateTime.UtcNow).ToUniversalTime().Date, DateTimeKind.Utc);
            var toUtc = DateTime.SpecifyKind((to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date, DateTimeKind.Utc);

            var dates = await _context.Appointments
                .AsNoTracking()
                .Where(a => a.PropertyId == propertyId)
                .Where(a => a.IsApproved != false)
                .Where(a => a.DateAppointment != null)
                .Where(a => a.DateAppointment!.Value >= fromUtc && a.DateAppointment!.Value < toUtc)
                .Select(a => a.DateAppointment!.Value.Date)
                .Distinct()
                .OrderBy(d => d)
                .ToListAsync();

            return new UnavailableAppointmentsResponse
            {
                PropertyId = propertyId,
                DateTimes = dates
            };
        }
    }
}
