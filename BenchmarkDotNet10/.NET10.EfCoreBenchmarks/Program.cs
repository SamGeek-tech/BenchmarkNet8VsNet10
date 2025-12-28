using BenchmarkDotNet.Running;

namespace EfCoreBenchmarks
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=".PadRight(80, '='));
            Console.WriteLine("EF Core Benchmarks - .NET 10");
            Console.WriteLine("Running 3 scenarios: SQLite, InMemory, Azure SQL");
            Console.WriteLine("=".PadRight(80, '='));
            Console.WriteLine();

            // Run SQLite benchmarks (original)
            Console.WriteLine(">>> Running SQLite Benchmarks...");
            //BenchmarkRunner.Run<EfBenchmarks>();
            Console.WriteLine();

            // Run InMemory benchmarks
            Console.WriteLine(">>> Running InMemory Benchmarks...");
            BenchmarkRunner.Run<EfBenchmarksInMemory>();
            Console.WriteLine();

            // Run Azure SQL benchmarks
            Console.WriteLine(">>> Running Azure SQL Benchmarks...");
            BenchmarkRunner.Run<EfBenchmarksAzureSQL>();
            Console.WriteLine();

            Console.WriteLine("=".PadRight(80, '='));
            Console.WriteLine("All benchmarks completed!");
            Console.WriteLine("=".PadRight(80, '='));
        }
    }
}
