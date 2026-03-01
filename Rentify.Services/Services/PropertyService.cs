using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;
using Rentify.Services.Recommendations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class PropertyService : BaseCRUDService<PropertyResponse, PropertySearchObject, Database.Property, PropertyInsertRequest, PropertyUpdateRequest>, IPropertyService
    {
        public PropertyService(RentifyDbContext context, IMapper mapper) : base(context, mapper)
        {

        }

        protected override IQueryable<Property> AddInclude(IQueryable<Property> query, PropertySearchObject search)
        {
            if (search.IncludeUser.HasValue)
            {
                query = query.Include(u => u.User);
            }
            return base.AddInclude(query, search);
        }

        protected override IQueryable<Property> ApplyFilter(IQueryable<Property> query, PropertySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                var name = search.Name.Trim().ToLower();
                query = query.Where(x => x.Name.ToLower().Contains(name));
            }

            if (!string.IsNullOrWhiteSpace(search.City))
            {
                var city = search.City.Trim().ToLower();
                query = query.Where(x => x.City.ToLower().Contains(city));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }


            if (search.MinPriceMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth >= search.MinPriceMonth.Value);
            }

            if (search.MaxPriceMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth <= search.MaxPriceMonth.Value);
            }

            if (search.MinPriceDays.HasValue)
            {
                query = query.Where(x => x.PricePerDay >= search.MinPriceDays.Value);
            }

            if (search.MaxPriceDays.HasValue)
            {
                query = query.Where(x => x.PricePerDay <= search.MaxPriceDays.Value);
            }

            return base.ApplyFilter(query, search);
        }

        public async Task<List<PropertyResponse>> GetRecommendedPropertiesAsync(int userId, int take = 5)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new Exception("Korisnik nije pronađen.");

            var reservedPropertyIds = await _context.Reservations
                .Where(r => r.UserId == userId)
                .Select(r => r.PropertyId)
                .Distinct()
                .ToListAsync();

            var candidates = await _context.Properties.Include(p => p.User)
                .Where(p => p.IsActiveOnApp && p.IsAvailable && !reservedPropertyIds.Contains(p.Id))
                .ToListAsync();

            if (candidates.Count == 0)
                return new List<PropertyResponse>();

            static string JoinTags(List<string>? tags) =>
                tags == null ? "" : string.Join(' ', tags.Where(t => !string.IsNullOrWhiteSpace(t)).Select(t => t.Trim()));

            List<Property> reservedProps = new();
            if (reservedPropertyIds.Count > 0)
            {
                reservedProps = await _context.Properties
                    .Where(p => reservedPropertyIds.Contains(p.Id))
                    .ToListAsync();
            }

            var inputs = new List<TagVectorInput>();

            inputs.AddRange(candidates.Select(p => new TagVectorInput
            {
                Id = p.Id,
                TagsText = JoinTags(p.Tags)
            }));

            if (reservedProps.Count > 0)
            {
                inputs.AddRange(reservedProps.Select(p => new TagVectorInput
                {
                    Id = p.Id,
                    TagsText = JoinTags(p.Tags)
                }));
            }

            // Ako su svi tagovi prazni -> fallback
            if (inputs.All(x => string.IsNullOrWhiteSpace(x.TagsText)))
            {
                var fallback = candidates
                    .OrderByDescending(p => p.Id)
                    .Take(take)
                    .ToList();

                return _mapper.Map<List<PropertyResponse>>(fallback);
            }

            var ml = new MLContext(seed: 1);
            var model = RecommendationMath.BuildTagVectorizer(ml, inputs);

            var dv = ml.Data.LoadFromEnumerable(inputs);
            var tv = model.Transform(dv);

            var vecs = ml.Data.CreateEnumerable<TagVectorOutput>(tv, reuseRowObject: false)
                .Select((v, idx) => new
                {
                    Id = inputs[idx].Id,
                    Vec = v.Features ?? Array.Empty<float>()
                })
                .ToDictionary(x => x.Id, x => x.Vec);

            float[] userVector;

            if (reservedPropertyIds.Count > 0)
            {
                var reservedVectors = reservedPropertyIds
                    .Where(id => vecs.ContainsKey(id))
                    .Select(id => vecs[id]);

                userVector = RecommendationMath.AverageVectors(reservedVectors);
            }
            else
            {
                var prefTags = user.PreferedTagsIfNoReservations ?? new List<string>();
                var prefText = string.Join(' ', prefTags.Where(t => !string.IsNullOrWhiteSpace(t)).Select(t => t.Trim()));

                if (string.IsNullOrWhiteSpace(prefText))
                {
                    var fallback = candidates
                        .OrderByDescending(p => p.Id)
                        .Take(take)
                        .ToList();

                    return _mapper.Map<List<PropertyResponse>>(fallback);
                }

                var userInput = new[] { new TagVectorInput { Id = -1, TagsText = prefText } };
                var userDv = ml.Data.LoadFromEnumerable(userInput);
                var userTv = model.Transform(userDv);

                userVector = ml.Data.CreateEnumerable<TagVectorOutput>(userTv, reuseRowObject: false)
                    .First().Features ?? Array.Empty<float>();
            }

            if (userVector.Length == 0)
            {
                var fallback = candidates
                    .OrderByDescending(p => p.Id)
                    .Take(take)
                    .ToList();

                return _mapper.Map<List<PropertyResponse>>(fallback);
            }

            var scored = candidates
                .Select(p => new
                {
                    Property = p,
                    Score = vecs.TryGetValue(p.Id, out var vec)
                        ? RecommendationMath.Cosine(userVector, vec)
                        : 0f
                })
                .OrderByDescending(x => x.Score)
                .ToList();

            if (scored.All(x => x.Score == 0))
            {
                var fallback = candidates
                    .OrderByDescending(p => p.Id)
                    .Take(take)
                    .ToList();

                return _mapper.Map<List<PropertyResponse>>(fallback);
            }

            var recommended = scored
                .Take(take)
                .Select(x => x.Property)
                .ToList();

            return _mapper.Map<List<PropertyResponse>>(recommended);
        }
    }
}
