using BenchmarkDotNet.Attributes;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class IoBenchmarks
    {
        private string _filePath;
        private byte[] _data;

        [GlobalSetup]
        public void Setup()
        {
            _filePath = Path.GetTempFileName();
            _data = new byte[100 * 1024 * 1024]; // 100MB
            new Random(42).NextBytes(_data);
        }

        [GlobalCleanup]
        public void Cleanup()
        {
            if (File.Exists(_filePath))
            {
                File.Delete(_filePath);
            }
        }

        [Benchmark]
        public void FileWriteRead()
        {
            File.WriteAllBytes(_filePath, _data);
            var readData = File.ReadAllBytes(_filePath);
        }
    }
}
