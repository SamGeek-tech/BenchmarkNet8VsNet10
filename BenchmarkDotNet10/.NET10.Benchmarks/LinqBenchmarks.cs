using BenchmarkDotNet.Attributes;
using System.Linq.Expressions;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class LinqBenchmarks
    {
        private List<Person> _people;
        private List<Order> _orders;
        private int[] _numbers;
        private Func<int, int> _compiledDelegate;
        private Func<int, int> _directDelegate;

        [GlobalSetup]
        public void Setup()
        {
            _people = Enumerable.Range(0, 1000).Select(i => new Person { Id = i, Name = $"Person {i}" }).ToList();
            _orders = Enumerable.Range(0, 10000).Select(i => new Order { Id = i, PersonId = i % 1000, Amount = i }).ToList();
            _numbers = Enumerable.Range(0, 1_000_000).ToArray();

            Expression<Func<int, int>> expr = x => x * x + 2 * x + 1;
            _compiledDelegate = expr.Compile();
            _directDelegate = x => x * x + 2 * x + 1;
        }

        [Benchmark]
        public int NestedJoinsLinq()
        {
            return _people.Join(_orders, p => p.Id, o => o.PersonId, (p, o) => o.Amount).Sum();
        }

        [Benchmark]
        public int NestedJoinsManual()
        {
            int sum = 0;
            // Naive nested loop join simulation (optimized with dictionary for fairness would be better, but testing raw loop overhead)
            // Actually, let's do a hash join manually to be comparable to LINQ's hash join
            var personDict = new Dictionary<int, Person>();
            foreach (var p in _people) personDict[p.Id] = p;

            foreach (var o in _orders)
            {
                if (personDict.ContainsKey(o.PersonId))
                {
                    sum += o.Amount;
                }
            }
            return sum;
        }

        [Benchmark]
        public double PlinqCpu()
        {
            return _numbers.AsParallel().Select(HeavyCalc).Sum();
        }

        [Benchmark]
        public double ParallelForEachCpu()
        {
            double sum = 0;
            object lockObj = new object();
            Parallel.ForEach(_numbers, n =>
            {
                var res = HeavyCalc(n);
                lock (lockObj) sum += res; // Naive accumulation
            });
            return sum;
        }

        private double HeavyCalc(int n) => Math.Sqrt(n) * Math.Sin(n);

        [Benchmark]
        public int SelectManyLinq()
        {
            return _people.SelectMany(p => _orders.Where(o => o.PersonId == p.Id)).Count();
        }

        [Benchmark]
        public int CompiledExpression()
        {
            int sum = 0;
            for (int i = 0; i < 1000; i++) sum += _compiledDelegate(i);
            return sum;
        }

        [Benchmark]
        public int DirectDelegate()
        {
            int sum = 0;
            for (int i = 0; i < 1000; i++) sum += _directDelegate(i);
            return sum;
        }
    }

    public class Person { public int Id { get; set; } public string Name { get; set; } }
    public class Order { public int Id { get; set; } public int PersonId { get; set; } public int Amount { get; set; } }
}
