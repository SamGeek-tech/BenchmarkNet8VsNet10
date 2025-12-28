using BenchmarkDotNet.Attributes;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class ConcurrencyBenchmarks
    {
        private const int Items = 100000;

        [Benchmark]
        public void ParallelFor()
        {
            Parallel.For(0, Items, i =>
            {
                Math.Sqrt(i);
            });
        }

        [Benchmark]
        public async Task AsyncTask()
        {
            var tasks = new List<Task>();
            for (int i = 0; i < 100; i++)
            {
                tasks.Add(Task.Run(() => Thread.Sleep(1)));
            }
            await Task.WhenAll(tasks);
        }
    }
}
