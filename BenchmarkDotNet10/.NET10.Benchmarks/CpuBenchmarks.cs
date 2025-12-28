using BenchmarkDotNet.Attributes;
using System.Security.Cryptography;
using System.Text.Json;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class CpuBenchmarks
    {
        private const int MatrixSize = 256;
        private double[,] _matrixA;
        private double[,] _matrixB;
        private byte[] _dataToHash;
        private TestData _testData;

        [GlobalSetup]
        public void Setup()
        {
            _matrixA = new double[MatrixSize, MatrixSize];
            _matrixB = new double[MatrixSize, MatrixSize];
            var rand = new Random(42);
            for (int i = 0; i < MatrixSize; i++)
            {
                for (int j = 0; j < MatrixSize; j++)
                {
                    _matrixA[i, j] = rand.NextDouble();
                    _matrixB[i, j] = rand.NextDouble();
                }
            }

            _dataToHash = new byte[1024 * 1024]; // 1MB
            rand.NextBytes(_dataToHash);

            _testData = new TestData { Id = 1, Name = "Test", Description = "Description", Values = new List<int> { 1, 2, 3, 4, 5 } };
        }

        [Benchmark]
        public double[,] MatrixMultiplication()
        {
            var result = new double[MatrixSize, MatrixSize];
            for (int i = 0; i < MatrixSize; i++)
            {
                for (int j = 0; j < MatrixSize; j++)
                {
                    double sum = 0;
                    for (int k = 0; k < MatrixSize; k++)
                    {
                        sum += _matrixA[i, k] * _matrixB[k, j];
                    }
                    result[i, j] = sum;
                }
            }
            return result;
        }

        [Benchmark]
        public byte[] Sha256()
        {
            using (var sha256 = SHA256.Create())
            {
                return sha256.ComputeHash(_dataToHash);
            }
        }

        [Benchmark]
        public string JsonSerialize()
        {
            return JsonSerializer.Serialize(_testData);
        }

        [Benchmark]
        public TestData JsonDeserialize()
        {
            return JsonSerializer.Deserialize<TestData>(JsonSerializer.Serialize(_testData));
        }

        public class TestData
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public List<int> Values { get; set; }
        }
    }
}
