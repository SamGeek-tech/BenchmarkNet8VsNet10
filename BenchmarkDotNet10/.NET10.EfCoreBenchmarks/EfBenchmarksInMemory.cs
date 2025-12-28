using BenchmarkDotNet.Attributes;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace EfCoreBenchmarks
{
    [MemoryDiagnoser]
    [SimpleJob(id: "InMemory")]
    public class EfBenchmarksInMemory
    {
        private AppDbContext _context;
        private IMemoryCache _cache;

        [GlobalSetup]
        public void Setup()
        {
#if DEBUG
            if (!Debugger.IsAttached)
                Debugger.Launch();
#endif

            _context = new AppDbContext(DatabaseProvider.InMemory);
            _context.Database.EnsureDeleted();
            _context.Database.EnsureCreated();
            SeedData();
            
            _cache = new MemoryCache(new MemoryCacheOptions());
            
            Console.WriteLine($"[EF Core Benchmark - InMemory] Database initialized in memory");
        }

        [GlobalCleanup]
        public void Cleanup()
        {
            _context?.Dispose();
            _cache?.Dispose();
        }

        private void SeedData()
        {
            // Existing Seed
            var blogs = Enumerable.Range(0, 1000).Select(i => new Blog { Url = $"http://blog{i}.com" }).ToList();
            _context.Blogs.AddRange(blogs);
            
            var random = new Random(42);
            var posts = Enumerable.Range(0, 10000).Select(i => new Post
            {
                Title = $"Post {i}",
                Content = "Content...",
                BlogId = random.Next(1, 1001)
            }).ToList();
            _context.Posts.AddRange(posts);

            // New Seed
            var users = Enumerable.Range(0, 1000).Select(i => new User { Name = $"User {i}", Email = $"user{i}@example.com" }).ToList();
            _context.Users.AddRange(users);
            
            var products = Enumerable.Range(0, 100).Select(i => new Product { Name = $"Product {i}", Price = i * 1.5m }).ToList();
            _context.Products.AddRange(products);
            
            _context.SaveChanges();
        }

        [Benchmark]
        public void SimpleQuery()
        {
            var blog = _context.Blogs.Find(1);
        }

        [Benchmark]
        public List<Blog> QueryTop100()
        {
            return _context.Blogs.Take(100).ToList();
        }

        [Benchmark]
        public List<Post> ComplexQuery()
        {
            return _context.Posts
                .Include(p => p.Blog)
                .Where(p => p.BlogId < 10)
                .ToList();
        }

        [Benchmark]
        public void Insert()
        {
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                context.Blogs.Add(new Blog { Url = "http://newblog.com" });
                context.SaveChanges();
            }
        }

        [Benchmark]
        public void Update()
        {
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                var blog = context.Blogs.First();
                blog.Url = "http://updated.com";
                context.SaveChanges();
            }
        }

        [Benchmark]
        public void Delete()
        {
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                // Create a dummy one to delete so we don't run out of data
                var b = new Blog { Url = "to_delete" };
                context.Blogs.Add(b);
                context.SaveChanges();

                context.Blogs.Remove(b);
                context.SaveChanges();
            }
        }

        [Benchmark]
        public List<Blog> AsNoTracking()
        {
            return _context.Blogs.AsNoTracking().Take(100).ToList();
        }

        [Benchmark]
        public void BulkInsert()
        {
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                var orders = new List<Order>();
                for (int i = 0; i < 1000; i++)
                {
                    orders.Add(new Order { OrderDate = DateTime.Now, UserId = 1 });
                }
                context.Orders.AddRange(orders);
                context.SaveChanges();
            }
        }

        [Benchmark]
        public void BulkUpdate()
        {
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                var users = context.Users.Take(100).ToList();
                foreach (var user in users)
                {
                    user.Name += " Updated";
                }
                context.SaveChanges();
            }
        }

        [Benchmark]
        public List<User> RawSql()
        {
            return _context.Users.FromSqlRaw("SELECT * FROM Users WHERE UserId < 100").ToList();
        }

        [Benchmark]
        public List<User> LinqQuery()
        {
            return _context.Users.Where(u => u.UserId < 100).ToList();
        }

        [Benchmark]
        public void ColdStart()
        {
            // Simulate cold start by creating a fresh context and running a query
            using (var context = new AppDbContext(DatabaseProvider.InMemory))
            {
                var user = context.Users.FirstOrDefault();
            }
        }

        [Benchmark]
        public User Caching()
        {
            return _cache.GetOrCreate("User1", entry =>
            {
                return _context.Users.Find(1);
            });
        }
    }
}
