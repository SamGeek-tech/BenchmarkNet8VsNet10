using BenchmarkDotNet.Attributes;
using System.Numerics;
using System.Runtime.InteropServices;
using System.Text;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class SimdBenchmarks
    {
        private int[] _arraySort;
        private int[] _spanSort;
        private float[] _vectors;
        private byte[] _utf8Text;
        private string _csvLine;

        [GlobalSetup]
        public void Setup()
        {
            var rand = new Random(42);
            _arraySort = Enumerable.Range(0, 10_000).Select(_ => rand.Next()).ToArray();
            _spanSort = (int[])_arraySort.Clone();

            _vectors = Enumerable.Range(0, 1_000_000).Select(_ => (float)rand.NextDouble()).ToArray();

            _utf8Text = Encoding.UTF8.GetBytes("Hello world this is a test string to scan for a delimiter like ; or something else.");
            _csvLine = "123,456,789,101112,131415,161718,192021";
        }

        [Benchmark]
        public void ArraySort()
        {
            var copy = (int[])_arraySort.Clone();
            Array.Sort(copy);
        }

        [Benchmark]
        public void SpanSort()
        {
            var copy = (int[])_spanSort.Clone();
            copy.AsSpan().Sort();
        }

        [Benchmark]
        public void SimdNormalize()
        {
            int vecSize = Vector<float>.Count;
            var span = _vectors.AsSpan();
            for (int i = 0; i < span.Length - vecSize; i += vecSize)
            {
                var v = new Vector<float>(span.Slice(i));
                var normalized = Vector.SquareRoot(v * v); // Dummy op
            }
        }

        [Benchmark]
        public int Utf8ScanSpan()
        {
            return _utf8Text.AsSpan().IndexOf((byte)';');
        }

        [Benchmark]
        public int Utf8ScanLoop()
        {
            for (int i = 0; i < _utf8Text.Length; i++)
            {
                if (_utf8Text[i] == (byte)';') return i;
            }
            return -1;
        }

        [Benchmark]
        public int CsvParsingSpan()
        {
            int sum = 0;
            ReadOnlySpan<char> span = _csvLine.AsSpan();
            int start = 0;
            for (int i = 0; i <= span.Length; i++)
            {
                if (i == span.Length || span[i] == ',')
                {
                    if (i > start)
                    {
                        sum += int.Parse(span.Slice(start, i - start));
                    }
                    start = i + 1;
                }
            }
            return sum;
        }
    }
}
