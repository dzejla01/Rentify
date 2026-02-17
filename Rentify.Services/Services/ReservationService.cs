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
            if (search.IsUser.HasValue)
            {
                query = query.Include(p => p.User);
            }

            if (search.IsProperty.HasValue)
            {
                query = query.Include(p => p.Property);
            }
            return base.AddInclude(query, search);
        }

    }
}
