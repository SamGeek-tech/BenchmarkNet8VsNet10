using BenchmarkDotNet.Attributes;
using System.Numerics;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class BigIntegerBenchmarks
    {
        private BigInteger _a;
        private BigInteger _b;

        [GlobalSetup]
        public void Setup()
        {
            var random = new Random(42);
            byte[] bytesA = new byte[512]; // 4096 bits
            byte[] bytesB = new byte[512];
            random.NextBytes(bytesA);
            random.NextBytes(bytesB);
            _a = new BigInteger(bytesA);
            _b = new BigInteger(bytesB);
            _a = BigInteger.Abs(_a);
            _b = BigInteger.Abs(_b);
        }

        [Benchmark]
        public BigInteger Multiplication() => _a * _b;

        [Benchmark]
        public BigInteger Division() => _a / _b;

        [Benchmark]
        public BigInteger ModPow() => BigInteger.ModPow(_a, _b, _a + _b);
    }
}
