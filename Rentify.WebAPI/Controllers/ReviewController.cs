using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class ReviewController
        : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewUpsertRequest, ReviewUpsertRequest>
    {
        public ReviewController(IReviewService service) : base(service)
        {
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<ReviewResponse> Create([FromBody] ReviewUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Korisnik,Admin")]
        public override Task<ReviewResponse?> Update(int id, [FromBody] ReviewUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Korisnik,Admin")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
