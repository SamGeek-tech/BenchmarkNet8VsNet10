using BenchmarkDotNet.Attributes;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class MemoryBenchmarks
    {
        private const int ArraySize = 10000;
        private int[] _array;

        [GlobalSetup]
        public void Setup()
        {
            _array = new int[ArraySize];
            for (int i = 0; i < ArraySize; i++)
            {
                _array[i] = i;
            }
        }

        [Benchmark]
        public int[] AllocateArray()
        {
            return new int[ArraySize];
        }

        [Benchmark]
        public int SpanOperation()
        {
            Span<int> span = _array;
            int sum = 0;
            for (int i = 0; i < span.Length; i++)
            {
                sum += span[i];
            }
            return sum;
        }

        [Benchmark]
        public int ArrayOperation()
        {
            int sum = 0;
            for (int i = 0; i < _array.Length; i++)
            {
                sum += _array[i];
            }
            return sum;
        }
    }
}
