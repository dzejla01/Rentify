using Microsoft.ML;
using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Rentify.Services.Recommendations
{
    public static class RecommendationMath
    {
        public static ITransformer BuildTagVectorizer<TInput>(
            MLContext ml,
            IEnumerable<TInput> props,
            string inputColumn = "TagsText")
            where TInput : class
        {
            var data = ml.Data.LoadFromEnumerable(props);

            var pipeline = ml.Transforms.Text.FeaturizeText(
                outputColumnName: "Features",
                inputColumnName: inputColumn);

            return pipeline.Fit(data);
        }

        public static float Cosine(float[]? a, float[]? b)
        {
            if (a == null || b == null) return 0f;
            if (a.Length == 0 || b.Length == 0) return 0f;
            if (a.Length != b.Length) return 0f;

            double dot = 0, na = 0, nb = 0;

            for (int i = 0; i < a.Length; i++)
            {
                var av = a[i];
                var bv = b[i];
                dot += av * bv;
                na += av * av;
                nb += bv * bv;
            }

            if (na <= 0 || nb <= 0) return 0f;
            return (float)(dot / (Math.Sqrt(na) * Math.Sqrt(nb)));
        }

        public static float[] AverageVectors(IEnumerable<float[]> vectors)
        {
            var list = vectors.Where(v => v != null && v.Length > 0).ToList();
            if (list.Count == 0) return Array.Empty<float>();

            var dim = list[0].Length;
            list = list.Where(v => v.Length == dim).ToList();
            if (list.Count == 0) return Array.Empty<float>();

            var sum = new double[dim];

            foreach (var v in list)
                for (int i = 0; i < dim; i++)
                    sum[i] += v[i];

            var avg = new float[dim];
            for (int i = 0; i < dim; i++)
                avg[i] = (float)(sum[i] / list.Count);

            return avg;
        }
    }
}