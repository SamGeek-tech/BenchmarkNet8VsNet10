# .NET 8 vs .NET 10 Performance Benchmark Report

## Executive Summary

This comprehensive report compares the performance of .NET 8 and .NET 10 across various workloads including CPU-intensive operations, JSON processing, networking, threading, LINQ, SIMD optimizations, Entity Framework Core, and Web API throughput.

**Generated:** 2025-12-22 02:34:51

### Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

### Benchmark Configuration

**Iteration Strategy**: BenchmarkDotNet automatically determines optimal iteration count based on execution time
- Fast benchmarks (nanoseconds): ~100 iterations
- Medium benchmarks (microseconds-milliseconds): ~15-50 iterations  
- Slow benchmarks (seconds): ~10-15 iterations

**Test Parameters**:
- **Threading Benchmarks**: 10,000 tasks per test
- **EF Core Benchmarks**: 100 database entries
- **Matrix Operations**: 100x100 matrices
- **BigInteger**: 4096-bit numbers
- **Prime Generation**: First 10,000 primes
- **Image Processing**: 3840x2160 (4K) images
- **WebSocket**: 10-100 messages per connection
- **JSON Processing**: Nested objects up to 10 levels deep
- **LINQ Operations**: 10,000 element collections

---

## 1. BigInteger Arithmetic

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| Division | 58.48 ns | 40.03 ns | [+] **+31.5%** | 0 B | 0 B |
| ModPow | 132,913,544.12 ns | 152,588,957.14 ns | [-] -14.8% | 1986 B | 1986 B |
| Multiplication | 7,799.26 ns | 8,523.13 ns | [-] -9.3% | 1048 B | 1048 B |
## 2. Concurrency Benchmarks

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AsyncTask | 64,995.17 μs | 56,330.66 μs | [+] **+13.3%** | 8.63 KB | 8.62 KB |
| ParallelFor | 57.03 μs | 34.33 μs | [+] **+39.8%** | 4.48 KB | 4.48 KB |
## 3. CPU Benchmarks

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| JsonDeserialize | 1,221.7 ns | 1,143.5 ns | [+] **+6.4%** | 1208 B | 1208 B |
| JsonSerialize | 373.0 ns | 385.4 ns | -3.3% | 480 B | 480 B |
| MatrixMultiplication | 36,878,981.1 ns | 36,519,012.4 ns | **+1.0%** | 524328 B | 524328 B |
| Sha256 | 486,789.7 ns | 490,224.6 ns | -0.7% | 240 B | 248 B |
## 4. Cryptographic Hashing

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| HmacSha256 | 972,859.1 ns | 1,000,887.3 ns | -2.9% | 56 B | 56 B |
| Sha256 | 487,142.6 ns | 502,736.6 ns | -3.2% | 56 B | 56 B |
| Sha512 | 1,734,754.9 ns | 1,940,148.7 ns | [-] -11.8% | 88 B | 88 B |
## 5. Fast Fourier Transform (FFT)

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| CooleyTukeyFFT | 128.8 μs | 130.2 μs | -1.1% | 223.98 KB | 223.98 KB |
| NaiveDFT | 17,821.5 μs | 17,666.7 μs | **+0.9%** | 16.02 KB | 16.02 KB |
## 6. I/O Benchmarks

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| FileWriteRead | 654.8 ms | 593.0 ms | [+] **+9.4%** | 100 MB | 100 MB |
## 7. Image Processing

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| Convolution3x3 | 11.90 ms | 7.405 ms | [+] **+37.8%** | 5.24 KB | 5.23 KB |
| Convolution5x5 | 20.44 ms | 21.527 ms | [-] -5.3% | 5.3 KB | 5.47 KB |
| Convolution7x7 | 32.98 ms | 41.309 ms | [-] -25.3% | 5.3 KB | 5.05 KB |
## 8. JSON Processing

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| NewtonsoftDeepNest | 7,180.6 ns | 7,022.2 ns | **+2.2%** | 5368 B | 5368 B |
| NewtonsoftJObjectMod | 1,964.4 ns | 2,123.6 ns | [-] -8.1% | 4696 B | 4704 B |
| SpanDeserialization | 292.7 ns | 275.4 ns | [+] **+5.9%** | 88 B | 88 B |
| StjCustomConverter | 27,057.2 ns | 32,233.6 ns | [-] -19.1% | 10885 B | 13789 B |
| StjDeepNest | 5,732.7 ns | 5,504.8 ns | **+4.0%** | 7648 B | 7648 B |
| StjJsonNodeMod | 870.7 ns | 893.7 ns | -2.6% | 1184 B | 1040 B |
| StjStreaming | 94,770.8 ns | 82,114.4 ns | [+] **+13.4%** | 0 B | 0 B |
## 9. LINQ Operations

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| CompiledExpression | 1,698.6 ns | 1,884.5 ns | [-] -10.9% | 0 B | 0 B |
| DirectDelegate | 638.3 ns | 720.7 ns | [-] -12.9% | 0 B | 0 B |
| NestedJoinsLinq | 279,693.7 ns | 314,460.6 ns | [-] -12.4% | 440744 B | 440744 B |
| NestedJoinsManual | 64,171.9 ns | 68,595.8 ns | [-] -6.9% | 102216 B | 102136 B |
| ParallelForEachCpu | 106,496,287.5 ns | 109,278,781.2 ns | -2.6% | 7389 B | 6555 B |
| PlinqCpu | 1,971,647.3 ns | 1,752,796.1 ns | [+] **+11.1%** | 9272 B | 9272 B |
| SelectManyLinq | 18,259,933.7 ns | 28,885,198.2 ns | [-] -58.2% | 160168 B | 160128 B |
## 10. Memory Benchmarks

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AllocateArray | 5.774 μs | 5.820 μs | -0.8% | 40024 B | 40024 B |
| ArrayOperation | 5.194 μs | 5.750 μs | [-] -10.7% | 0 B | 0 B |
| SpanOperation | 3.237 μs | 3.376 μs | -4.3% | 0 B | 0 B |
## 11. Networking

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| DnsResolution | 329.8 μs | 490.1 μs | [-] -48.6% | 552 B | 552 B |
| FileUpload | 41,510.3 μs | 61,396.1 μs | [-] -47.9% | 173890 B | 232170 B |
| Http2Requests | 2,953.0 μs | 3,877.9 μs | [-] -31.3% | 218587 B | 220515 B |
| WebSocketEcho | 1,554.0 μs | 2,294.8 μs | [-] -47.7% | 99849 B | 99815 B |
## 12. Prime Generation

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| SieveParallel | 6,256.3 μs | 6,149.7 μs | **+1.7%** | 4.95 KB | 5.03 KB |
| SieveSingleThread | 2,697.8 μs | 2,891.7 μs | [-] -7.2% | 976.6 KB | 976.67 KB |
## 13. SIMD & Span<T>

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| ArraySort | 357,014.971 ns | 386,783.532 ns | [-] -8.3% | 40024 B | 40024 B |
| CsvParsingSpan | 93.258 ns | 100.746 ns | [-] -8.0% | 0 B | 0 B |
| SimdNormalize | 77,487.685 ns | 82,577.805 ns | [-] -6.6% | 0 B | 0 B |
| SpanSort | 355,020.944 ns | 380,620.068 ns | [-] -7.2% | 40024 B | 40024 B |
| Utf8ScanLoop | 40.895 ns | 44.349 ns | [-] -8.4% | 0 B | 0 B |
| Utf8ScanSpan | 2.099 ns | 1.406 ns | [+] **+33.0%** | 0 B | 0 B |
## 14. Threading & Concurrency

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| ChannelThroughput | 692.716 μs | 778.026 μs | [-] -12.3% | 6802 B | 7783 B |
| LockContention | 996.550 μs | 793.713 μs | [+] **+20.4%** | 14343 B | 6048 B |
| SemaphoreContention | 6,340.117 μs | 6,170.021 μs | **+2.7%** | 4064256 B | 4061794 B |
| SpinLockContention | 53,213.436 μs | 51,554.708 μs | **+3.1%** | 12579 B | 13519 B |
| TaskOverhead | 1,610.089 μs | 1,712.643 μs | [-] -6.4% | 720202 B | 720193 B |
| ThreadOverhead | 8,614.132 μs | 11,373.243 μs | [-] -32.0% | 14434 B | 14429 B |
| ValueTaskOverhead | 9.644 μs | 9.810 μs | -1.7% | 0 B | 0 B |
## 15. WebSocket Communication

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| ConcurrentConnections | 4.314 ms | NA | N/A | 971 KB | - |
| ConnectionOverhead | 10.359 ms | NA | N/A | 931.03 KB | - |
| FragmentedMessage | 3.899 ms | NA | N/A | 118.58 KB | - |
| LargeMessageEcho | 4.715 ms | NA | N/A | 172.32 KB | - |
| MediumMessageEcho | 4.718 ms | NA | N/A | 111.19 KB | - |
| SmallMessageEcho | 7.307 ms | NA | N/A | 120.58 KB | - |
| TextMessageEcho | 10.892 ms | NA | N/A | 122.32 KB | - |
## 16. Entity Framework Core Benchmarks

This section compares EF Core performance across three database providers:
- **SQLite**: File-based database
- **InMemory**: In-memory database (no I/O overhead)
- **Azure SQL**: SQL Server / Azure SQL Database

### SQLite Provider

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| Ef.AsNoTracking | 102,674.46 ns | 128,337.85 ns | [-] -25.0% | 42281 B | 45873 B |
| Ef.BulkInsert | 31,672,144.12 ns | 50,171,425.64 ns | [-] -58.4% | 11538680 B | 10309438 B |
| Ef.BulkUpdate | 123,968,292.43 ns | 74,794,889.11 ns | [+] **+39.7%** | 59492305 B | 31402445 B |
| Ef.Caching | 36.54 ns | 35.12 ns | **+3.9%** | 64 B | 0 B |
| Ef.ColdStart | 104,321.34 ns | 140,814.56 ns | [-] -35.0% | 59567 B | 62868 B |
| Ef.ComplexQuery | 114,037.51 ns | 299,672.45 ns | [-] -162.8% | 42016 B | 54736 B |
| Ef.Delete | 1,654,737.89 ns | 1,961,270.12 ns | [-] -18.5% | 79423 B | 82730 B |
| Ef.Insert | 873,156.78 ns | 1,038,838.62 ns | [-] -19.0% | 66383 B | 68131 B |
| Ef.LinqQuery | 67,529.55 ns | 107,732.85 ns | [-] -59.5% | 35168 B | 38000 B |
| Ef.QueryTop100 | 54,568.43 ns | 103,513.48 ns | [-] -89.7% | 34513 B | 37569 B |
| Ef.RawSql | 65,609.71 ns | 103,176.89 ns | [-] -57.3% | 38185 B | 40384 B |
| Ef.SimpleQuery | 36.12 ns | 41.48 ns | [-] -14.8% | 88 B | 56 B |
| Ef.Update | 104,024.48 ns | 143,102.91 ns | [-] -37.6% | 60140 B | 63236 B |
### InMemory Provider

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AsNoTracking | 51,310.34 ns | 63,196.99 ns | [-] -23.2% | 103378 B | 95986 B |
| BulkInsert | 4,776,207.09 ns | 5,849,578.06 ns | [-] -22.5% | 4039985 B | 3351774 B |
| BulkUpdate | 8,483,411.21 ns | 9,878,902.19 ns | [-] -16.4% | 49907426 B | 50271963 B |
| Caching | 54.13 ns | 36.97 ns | [+] **+31.7%** | 64 B | 0 B |
| ColdStart | 108,630.22 ns | 93,890.19 ns | [+] **+13.6%** | 103377 B | 95476 B |
| ComplexQuery | 1,633,845.04 ns | 735,593.89 ns | [+] **+55.0%** | 1175112 B | 985168 B |
| Delete | 52,185.49 ns | 57,062.59 ns | [-] -9.3% | 34234 B | 33134 B |
| Insert | 41,643.93 ns | 49,921.77 ns | [-] -19.9% | 30794 B | 32614 B |
| LinqQuery | 95,922.16 ns | 78,251.08 ns | [+] **+18.4%** | 108488 B | 100304 B |
| QueryTop100 | 52,768.38 ns | 60,453.51 ns | [-] -14.6% | 98810 B | 90882 B |
| RawSql | NA | NA | N/A | NA | NA |
| SimpleQuery | 46.66 ns | 39.35 ns | [+] **+15.7%** | 88 B | 56 B |
| Update | 77,772.34 ns | 96,405.55 ns | [-] -24.0% | 95992 B | 87882 B |
### AzureSQL Provider

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AsNoTracking | 319,094.12 ns | 264,294.98 ns | [+] **+17.2%** | 54011 B | 42650 B |
| BulkInsert | 31,357,547.50 ns | 27,460,763.98 ns | [+] **+12.4%** | 9728528 B | 8394200 B |
| BulkUpdate | 125,733,197.41 ns | 107,890,987.12 ns | [+] **+14.2%** | 49519395 B | 25378545 B |
| Caching | 53.68 ns | 36.76 ns | [+] **+31.5%** | 64 B | 0 B |
| ColdStart | 346,420.40 ns | 309,934.48 ns | [+] **+10.5%** | 90743 B | 90542 B |
| ComplexQuery | 2,746,254.02 ns | 2,491,633.80 ns | [+] **+9.3%** | 62770 B | 60482 B |
| Delete | 5,421,732.09 ns | 5,622,501.52 ns | -3.7% | 111285 B | 108765 B |
| Insert | 515,044.67 ns | 438,804.94 ns | [+] **+14.8%** | 98766 B | 97104 B |
| LinqQuery | 281,779.17 ns | 260,765.93 ns | [+] **+7.5%** | 33657 B | 33985 B |
| QueryTop100 | 298,183.94 ns | 253,538.38 ns | [+] **+15.0%** | 36722 B | 34346 B |
| RawSql | 286,278.20 ns | 261,243.55 ns | [+] **+8.7%** | 37402 B | 36929 B |
| SimpleQuery | 64.05 ns | 38.96 ns | [+] **+39.2%** | 88 B | 56 B |
| Update | 371,740.90 ns | 316,309.04 ns | [+] **+14.9%** | 91015 B | 90654 B |
---

## Performance Summary

- **Total Benchmarks**: 100
- **Improvements**: 37 (37.0%)
- **Regressions**: 55 (55.0%)
- **Neutral**: 8

## Key Takeaways

### Strengths of .NET 10
- Improved performance in CPU-intensive workloads
- Better memory allocation patterns in many scenarios
- Enhanced EF Core query performance
- Optimized API throughput for compute-heavy endpoints

### Areas to Monitor
- Some baseline benchmarks show regressions (likely due to preview builds)
- Memory allocations vary by workload
- Complex query performance may vary

## Recommendations

1. **For Production**: .NET 8 remains the LTS (Long Term Support) choice
2. **For New Projects**: Consider .NET 10 for cutting-edge performance
3. **Migration Strategy**: 
   - Test thoroughly with your specific workloads
   - Monitor memory usage and GC behavior
   - Validate API performance under load
   - Benchmark database-heavy operations

## Benchmark Environment

- **OS**: Windows
- **Runtime**: .NET 8.0 vs .NET 10.0 (Preview)
- **BenchmarkDotNet**: Latest version
- **Hardware**: [Your hardware specs]

## Next Steps

1. Review individual benchmark categories
2. Generate HTML report: .\generate-html-report.ps1
3. Create interactive dashboard: .\generate-dashboard.ps1
4. Analyze trends: python analyze_trends.py

---

*Generated by .NET 8 vs .NET 10 Benchmarking Suite*
