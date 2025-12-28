using BenchmarkDotNet.Attributes;
using System.Threading.Channels;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class ThreadingBenchmarks
    {
        private const int TaskCount = 10_000;
        private readonly object _lock = new();
        private readonly SemaphoreSlim _semaphore = new(1, 1);
        private SpinLock _spinLock = new();

        [Benchmark]
        public async Task TaskOverhead()
        {
            var tasks = new Task[TaskCount];
            for (int i = 0; i < TaskCount; i++)
            {
                tasks[i] = Task.Run(() => { });
            }
            await Task.WhenAll(tasks);
        }

        [Benchmark]
        public async ValueTask ValueTaskOverhead()
        {
            for (int i = 0; i < TaskCount; i++)
            {
                await DoValueTask();
            }
        }

        private ValueTask DoValueTask() => ValueTask.CompletedTask;

        [Benchmark]
        public void ThreadOverhead()
        {
            var threads = new Thread[100]; // Reduce count for raw threads to avoid OS limits in benchmark
            for (int i = 0; i < 100; i++)
            {
                threads[i] = new Thread(() => { });
                threads[i].Start();
            }
            for (int i = 0; i < 100; i++)
            {
                threads[i].Join();
            }
        }

        [Benchmark]
        public async Task ChannelThroughput()
        {
            var channel = Channel.CreateBounded<int>(new BoundedChannelOptions(1000) { SingleReader = true, SingleWriter = true });
            var writer = channel.Writer;
            var reader = channel.Reader;

            var producer = Task.Run(async () =>
            {
                for (int i = 0; i < TaskCount; i++)
                {
                    await writer.WriteAsync(i);
                }
                writer.Complete();
            });

            var consumer = Task.Run(async () =>
            {
                while (await reader.WaitToReadAsync())
                {
                    while (reader.TryRead(out _)) { }
                }
            });

            await Task.WhenAll(producer, consumer);
        }

        [Benchmark]
        public void LockContention()
        {
            Parallel.For(0, TaskCount, i =>
            {
                lock (_lock) { }
            });
        }

        [Benchmark]
        public async Task SemaphoreContention()
        {
            var tasks = new Task[TaskCount];
            for (int i = 0; i < TaskCount; i++)
            {
                tasks[i] = Task.Run(async () =>
                {
                    await _semaphore.WaitAsync();
                    _semaphore.Release();
                });
            }
            await Task.WhenAll(tasks);
        }

        [Benchmark]
        public void SpinLockContention()
        {
            Parallel.For(0, TaskCount, i =>
            {
                bool lockTaken = false;
                try
                {
                    _spinLock.Enter(ref lockTaken);
                }
                finally
                {
                    if (lockTaken) _spinLock.Exit();
                }
            });
        }
    }
}
