using BenchmarkDotNet.Attributes;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Buffers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;
using JsonSerializer = System.Text.Json.JsonSerializer;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class JsonBenchmarks
    {
        private string _deepNestedJson;
        private byte[] _utf8JsonData;
        private string _largeJsonLog;
        private ComplexDto _complexDto;
        private string _complexDtoJson;

        [GlobalSetup]
        public void Setup()
        {
            // 1. Deep Nesting Setup
            var root = new NestedObject();
            var current = root;
            for (int i = 0; i < 25; i++)
            {
                current.Child = new NestedObject { Value = i };
                current = current.Child;
            }
            _deepNestedJson = System.Text.Json.JsonSerializer.Serialize(root);

            // 2. Streaming Setup
            var sb = new StringBuilder();
            sb.Append("[");
            for (int i = 0; i < 1000; i++)
            {
                sb.Append($"{{\"Id\":{i},\"Message\":\"Log entry {i}\",\"Timestamp\":\"{DateTime.UtcNow:O}\"}}");
                if (i < 999) sb.Append(",");
            }
            sb.Append("]");
            _largeJsonLog = sb.ToString();
            _utf8JsonData = Encoding.UTF8.GetBytes(_largeJsonLog);

            // 3. Custom Converter Setup
            _complexDto = new ComplexDto { Date = DateTime.UtcNow, Price = 123.45m, Status = "Active" };
            _complexDtoJson = System.Text.Json.JsonSerializer.Serialize(_complexDto);
        }

        // 1. Deep Nesting Benchmark
        [Benchmark]
        public NestedObject StjDeepNest() => System.Text.Json.JsonSerializer.Deserialize<NestedObject>(_deepNestedJson);

        [Benchmark]
        public NestedObject NewtonsoftDeepNest() => JsonConvert.DeserializeObject<NestedObject>(_deepNestedJson);

        // 2. Streaming Benchmark
        [Benchmark]
        public int StjStreaming()
        {
            int count = 0;
            var reader = new Utf8JsonReader(_utf8JsonData);
            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.StartObject)
                    count++;
            }
            return count;
        }

        // 3. Custom Converter Benchmark
        [Benchmark]
        public string StjCustomConverter()
        {
            var options = new JsonSerializerOptions();
            options.Converters.Add(new CustomDateConverter());
            return System.Text.Json.JsonSerializer.Serialize(_complexDto, options);
        }

        // 4. Span Deserialization (Zero Allocation)
        [Benchmark]
        public SimpleLog SpanDeserialization()
        {
            ReadOnlySpan<byte> span = _utf8JsonData.AsSpan(1, 100); // Just take first object approx
            // Finding the first object manually for the benchmark to simulate span slicing
            int end = span.IndexOf((byte)'}');
            var slice = span.Slice(0, end + 1);
            return System.Text.Json.JsonSerializer.Deserialize<SimpleLog>(slice);
        }

        // 5. JSON Patch (Modification)
        [Benchmark]
        public string StjJsonNodeMod()
        {
            var node = JsonNode.Parse(_complexDtoJson);
            node["Status"] = "Inactive";
            return node.ToJsonString();
        }

        [Benchmark]
        public string NewtonsoftJObjectMod()
        {
            var obj = JObject.Parse(_complexDtoJson);
            obj["Status"] = "Inactive";
            return obj.ToString(Formatting.None);
        }
    }

    public class NestedObject
    {
        public int Value { get; set; }
        public NestedObject Child { get; set; }
    }

    public class SimpleLog
    {
        public int Id { get; set; }
        public string Message { get; set; }
        public DateTime Timestamp { get; set; }
    }

    public class ComplexDto
    {
        public DateTime Date { get; set; }
        public decimal Price { get; set; }
        public string Status { get; set; }
    }

    public class CustomDateConverter : System.Text.Json.Serialization.JsonConverter<DateTime>
    {
        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return DateTime.Parse(reader.GetString());
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ToString("yyyy-MM-dd"));
        }
    }
}
