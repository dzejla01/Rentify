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
    public class PaymentService
        : BaseCRUDService<PaymentResponse, PaymentSearchObject, Payment, PaymentUpsertRequest, PaymentUpsertRequest>,
          IPaymentService
    {
        private readonly IDeviceTokenService _deviceTokenService;
        private readonly PushNotificationService _pushService;

        public PaymentService(
            RentifyDbContext context,
            IMapper mapper,
            IDeviceTokenService deviceTokenService,
            PushNotificationService pushService
        ) : base(context, mapper)
        {
            _deviceTokenService = deviceTokenService;
            _pushService = pushService;
        }

        protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FTS))
            {
                var fts = search.FTS.ToLower();

                query = query.Where(x =>
                    x.Name.ToLower().Contains(fts)
                    ||
                    (x.MonthNumber.ToString().PadLeft(2, '0') + "." + x.YearNumber.ToString())
                        .Contains(fts)
                    ||
                    ("uplaćeno".Contains(search.FTS.ToLower()) && x.IsPayed == true)
                    ||
                    ("na čekanju".Contains(search.FTS.ToLower()) && x.IsPayed == false)
                );
            }


            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (search.IsPayed.HasValue)
                query = query.Where(x => x.IsPayed == search.IsPayed.Value);

            if (search.MonthNumber.HasValue)
                query = query.Where(x => x.MonthNumber == search.MonthNumber.Value);

            if (search.YearNumber.HasValue)
                query = query.Where(x => x.YearNumber == search.YearNumber.Value);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Payment> AddInclude(IQueryable<Payment> query, PaymentSearchObject search)
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

        protected override async Task AfterInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.IsPayed == false)
            {
                try
                {
                    var tokens = await _deviceTokenService
                        .GetActiveTokensAsync(entity.UserId);

                    await _pushService.SendToTokensAsync(
                        tokens,
                        "Rentify",
                        "Imate novi zahtjev za plaćanje.",
                        new Dictionary<string, string>
                        {
                            ["type"] = "payment_request",
                            ["paymentId"] = entity.Id.ToString()
                        }
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Push failed: {ex.Message}");
                }
            }
        }

    }
}
