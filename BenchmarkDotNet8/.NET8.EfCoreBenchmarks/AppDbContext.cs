using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace EfCoreBenchmarks
{
    public enum DatabaseProvider
    {
        SQLite,
        InMemory,
        AzureSQL
    }

    public class AppDbContext : DbContext
    {
        private readonly DatabaseProvider _provider;

        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<Tag> Tags { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<Product> Products { get; set; }

        public AppDbContext() : this(DatabaseProvider.SQLite)
        {
        }

        public AppDbContext(DatabaseProvider provider)
        {
            _provider = provider;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            switch (_provider)
            {
                case DatabaseProvider.SQLite:
                    var dbPath = @"D:\temp\benchmarks8.db";
                    optionsBuilder.UseSqlite($"Data Source={dbPath}");
                    break;

                case DatabaseProvider.InMemory:
                    optionsBuilder.UseInMemoryDatabase("BenchmarkInMemoryDb");
                    break;

                case DatabaseProvider.AzureSQL:
                    // Get connection string from environment variable or use default
                    var connectionString = Environment.GetEnvironmentVariable("AZURE_SQL_CONNECTION_STRING") 
                        ?? "Server=(localdb)\\mssqllocaldb;Database=EfCoreBenchmarks8;Trusted_Connection=True;MultipleActiveResultSets=true";
                    optionsBuilder.UseSqlServer(connectionString);
                    break;
            }
        }
    }

    public class Blog
    {
        public int BlogId { get; set; }
        public string Url { get; set; }
        public List<Post> Posts { get; set; } = new();
    }

    public class Post
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public int BlogId { get; set; }
        public Blog Blog { get; set; }
        public List<Tag> Tags { get; set; } = new();
    }

    public class Tag
    {
        public int TagId { get; set; }
        public string Name { get; set; }
        public List<Post> Posts { get; set; } = new();
    }

    public class User
    {
        public int UserId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public List<Order> Orders { get; set; } = new();
    }

    public class Order
    {
        public int OrderId { get; set; }
        public DateTime OrderDate { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public List<Product> Products { get; set; } = new();
    }

    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public List<Order> Orders { get; set; } = new();
    }
}
