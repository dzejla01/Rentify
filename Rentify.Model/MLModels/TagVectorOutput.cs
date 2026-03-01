

using System;
using Microsoft.ML.Data;

namespace Rentify.Model.RequestObjects
{
    public class TagVectorOutput
    {
        [VectorType]
        public float[] Features { get; set; } = Array.Empty<float>();
    }
}