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
                var fts = search.FTS.ToLower();

                query = query.Where(x =>
                    x.Comment.ToLower().Contains(fts)
                    ||
                    (x.User != null &&
                        (x.User.FirstName + " " + x.User.LastName)
                        .ToLower()
                        .Contains(fts))
                );
            }

            return query;
        }

        protected override IQueryable<Review> AddInclude(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = base.AddInclude(query, search);

            if (search.IncludeUser.HasValue)
            {
                query = query.Include(x => x.User);
            }

            if (search.IncludeProperty.HasValue)
            {
                query = query.Include(x => x.Property);
            }

            return query;
        }
    }
}