using BenchmarkDotNet.Attributes;
using System.Threading;
using System.Threading.Tasks;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class PrimeBenchmarks
    {
        [Params(100_000, 1_000_000)]
        public int N;

        [Benchmark]
        public int SieveSingleThread()
        {
            bool[] isPrime = new bool[N + 1];
            for (int i = 2; i <= N; i++) isPrime[i] = true;

            for (int p = 2; p * p <= N; p++)
            {
                if (isPrime[p])
                {
                    for (int i = p * p; i <= N; i += p)
                        isPrime[i] = false;
                }
            }

            int count = 0;
            for (int i = 2; i <= N; i++)
                if (isPrime[i]) count++;
            return count;
        }

        [Benchmark]
        public int SieveParallel()
        {
            int count = 0;
            Parallel.For(2, N + 1, i =>
            {
                if (IsPrime(i)) Interlocked.Increment(ref count);
            });
            return count;
        }

        private bool IsPrime(int number)
        {
            if (number < 2) return false;
            if (number == 2) return true;
            if (number % 2 == 0) return false;
            for (int i = 3; i * i <= number; i += 2)
            {
                if (number % i == 0) return false;
            }
            return true;
        }
    }
}
