using BenchmarkDotNet.Attributes;
using System.Security.Cryptography;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class HashingBenchmarks
    {
        private byte[] _data;

        [Params(1024, 1024 * 1024)] // 1KB, 1MB
        public int Size;

        [GlobalSetup]
        public void Setup()
        {
            _data = new byte[Size];
            new Random(42).NextBytes(_data);
        }

        [Benchmark]
        public byte[] Sha256() => SHA256.HashData(_data);

        [Benchmark]
        public byte[] Sha512() => SHA512.HashData(_data);

        [Benchmark]
        public byte[] HmacSha256() => HMACSHA256.HashData(_data, _data);
    }
}
