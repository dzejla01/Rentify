using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System.Linq;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class StatusService
        : BaseCRUDService<StatusResponse, StatusSearchObject, Status, StatusUpsertRequest, StatusUpsertRequest>,
          IStatusService
    {
        public StatusService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Status> ApplyFilter(IQueryable<Status> query, StatusSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.FTS.Trim().ToLower()));

            return base.ApplyFilter(query, search);
        }

        protected override async Task BeforeDelete(Status entity)
        {
            var isUsed =
                await _context.Reservations.AnyAsync(x => x.StatusId == entity.Id) ||
                await _context.Appointments.AnyAsync(x => x.StatusId == entity.Id) ||
                await _context.Payments.AnyAsync(x => x.StatusId == entity.Id) ||
                await _context.ReservationHistories.AnyAsync(x =>
                    x.StatusId == entity.Id ||
                    x.OldStatusId == entity.Id ||
                    x.NewStatusId == entity.Id);

            if (isUsed)
                throw new UserException("Status nije moguće obrisati jer se koristi u rezervacijama, terminima, plaćanjima ili historiji.");

            await base.BeforeDelete(entity);
        }
    }
}
