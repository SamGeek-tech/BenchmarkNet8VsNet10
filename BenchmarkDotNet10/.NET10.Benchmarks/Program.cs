using BenchmarkDotNet.Running;

namespace Benchmarks
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--------------------------------------------------");
            Console.WriteLine($"Starting Benchmark Suite for .NET {System.Environment.Version}");
            Console.WriteLine("--------------------------------------------------");
            Console.ResetColor();

            // Baseline Benchmarks
            BenchmarkRunner.Run<CpuBenchmarks>();
            BenchmarkRunner.Run<MemoryBenchmarks>();
            BenchmarkRunner.Run<ConcurrencyBenchmarks>();
            BenchmarkRunner.Run<IoBenchmarks>();
            
            // Advanced CPU Benchmarks
            BenchmarkRunner.Run<BigIntegerBenchmarks>();
            BenchmarkRunner.Run<PrimeBenchmarks>();
            BenchmarkRunner.Run<FftBenchmarks>();
            BenchmarkRunner.Run<ImageProcessingBenchmarks>();
            BenchmarkRunner.Run<HashingBenchmarks>();
            BenchmarkRunner.Run<JsonBenchmarks>();
            BenchmarkRunner.Run<ThreadingBenchmarks>();
            BenchmarkRunner.Run<NetworkingBenchmarks>();
            BenchmarkRunner.Run<LinqBenchmarks>();
            BenchmarkRunner.Run<SimdBenchmarks>();
            BenchmarkRunner.Run<WebSocketBenchmarks>();
        }
    }
}
