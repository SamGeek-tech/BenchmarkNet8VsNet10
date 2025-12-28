# .NET 8 vs .NET 10 Benchmarking

This suite compares the performance of .NET 8 and .NET 10 across a wide variety of tasks. It covers everything from basic CPU and memory operations to real-world scenarios like JSON processing, networking, and Entity Framework Core.

## Getting Started

### Prerequisites
- .NET 8 and .NET 10 SDKs
- Docker (optional, for database and monitoring services)

### Running the Suite
The easiest way to get results is to run the main script. **Note: A full run takes 3 to 5 hours depending on your hardware.**

```powershell
.\run-all-benchmarks.ps1
```

You can skip specific categories if you're short on time:
- `-SkipBaseline` (CPU, Memory, I/O)
- `-SkipEfCore` (Database operations)
- `-SkipApi` (Web API throughput)

## Benchmark Categories

### 1. General Workloads
There are 14 categories with over 50 individual tests:
- **Foundations**: CPU (matrix math, hashing), Memory (allocations, spans), Concurrency, and File I/O.
- **Advanced CPU**: BigInteger math (4096-bit), Prime generation (segmented sieve), FFT, and 4K Image processing.
- **Data**: Complex and nested JSON serialization using `System.Text.Json`.
- **System**: Threading (locks, channels, semaphores) and Networking (HTTP/2, WebSockets, DNS).
- **Optimizations**: LINQ performance and SIMD/Span operations.

### 2. Entity Framework Core
We test EF Core against three different database providers to isolate various performance bottlenecks.

| Provider | Database | Use Case |
|----------|----------|----------|
| **SQLite** | Local file | Good for baseline testing with storage I/O. |
| **InMemory** | RAM | Best for testing EF Core logic without any I/O overhead. |
| **SQL Server** | Real DB | Production-like testing (uses Azure SQL or LocalDB). |

#### Setting up SQL Server
By default, the suite looks for LocalDB. To test against a real SQL Server or Azure SQL instance, set this environment variable:
```powershell
$env:AZURE_SQL_CONNECTION_STRING = "Server=tcp:your-server.database.windows.net...;User ID=...;Password=...;"
```

### 3. Web API
The project includes two minimal API servers (.NET 8 and .NET 10) to compare endpoint throughput using a custom load testing tool.
- **No-Op**: Measures base overhead.
- **CPU-Bound**: Fibonacci calculations to test compute-heavy requests.

## Reports and Visualization

Once the benchmarks are done, you can generate several types of reports:
- **Markdown Summary**: `.\generate-final-report.ps1` -> `results\final_report.md`
- **HTML Report**: `.\generate-html-report.ps1` -> A clean, styled summary.

## Infrastructure and Services

The `docker-compose.yml` file spins up several services for testing and monitoring:
- **Postgres** (5432) & **SQL Server** (1433)
- **Nginx** (8080)
- **Prometheus** (9090) & **Grafana** (3000)

## Project Layout

- `BenchmarkDotNet8/10`: Project files for each framework.
- `BenchmarkApi8/10`: API servers for load tests.
- `ApiBenchmark`: The load testing tool.
- `results/`: All logs, CSVs, and generated reports.

## Adding New Tests
1. Add your benchmark class to both the .NET 8 and .NET 10 projects.
2. Use the `[Benchmark]` attribute on your methods.
3. Register the class in `Program.cs` via `BenchmarkRunner.Run<T>()`.
4. Run `.\generate-final-report.ps1` to update the aggregated report.
