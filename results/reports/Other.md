# Other - .NET 8 vs .NET 10 Performance

**Generated:** 2025-12-15 15:38:36

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AllocateArray | 835.4 ns | 791.5 ns | [+] **+5.3%** | 40024 B | 40024 B |
| ArrayOperation | 4,727.4 ns | 5,371.1 ns | [-] -13.6% | 0 B | 0 B |
| ArraySort | 357,014.971 ns | 367,086.966 ns | -2.8% | 40024 B | 40024 B |
| AsyncTask | 62,753.91 μs | 62,072.12 μs | **+1.1%** | 8.63 KB | 8.62 KB |
| ChannelThroughput | 745.14 μs | 734.541 μs | **+1.4%** | 5234 B | 4318 B |
| CompiledExpression | 1,698.6 ns | 1,348.5 ns | [+] **+20.6%** | 0 B | 0 B |
| ConcurrentConnections | NA | NA | N/A | - | - |
| ConnectionOverhead | NA | NA | N/A | - | - |
| Convolution3x3 | 8.241 ms | 8.584 ms | -4.2% | 4.68 KB | 4.69 KB |
| Convolution5x5 | 18.068 ms | 19.079 ms | [-] -5.6% | 5.03 KB | 5.06 KB |
| Convolution7x7 | 28.855 ms | 40.320 ms | [-] -39.7% | 5.16 KB | 6.25 KB |
| CooleyTukeyFFT | 107.4 μs | 103.7 μs | **+3.4%** | 223.98 KB | 223.98 KB |
| CsvParsingSpan | 93.258 ns | 90.762 ns | **+2.7%** | 0 B | 0 B |
| DirectDelegate | 638.3 ns | 662.1 ns | -3.7% | 0 B | 0 B |
| Division | 55.63 ns | 36.85 ns | [+] **+33.8%** | 0 B | 0 B |
| DnsResolution | 379.2 μs | 384.2 μs | -1.3% | 552 B | 552 B |
| FileUpload | NA | NA | N/A | NA | NA |
| FileWriteRead | 624.0 ms | 561.0 ms | [+] **+10.1%** | 100 MB | 100 MB |
| FragmentedMessage | NA | NA | N/A | - | - |
| HmacSha256 | 989,953.1 ns | 983,501.2 ns | **+0.7%** | 56 B | 56 B |
| Http2Requests | NA | NA | N/A | NA | NA |
| JsonDeserialize | 958.7 ns | 950.2 ns | **+0.9%** | 1208 B | 1208 B |
| JsonSerialize | 370.2 ns | 328.1 ns | [+] **+11.4%** | 480 B | 480 B |
| LargeMessageEcho | NA | NA | N/A | - | - |
| LockContention | 903.91 μs | 812.176 μs | [+] **+10.1%** | 9292 B | 8057 B |
| MatrixMultiplication | 30,439,249.5 ns | 35,459,625.9 ns | [-] -16.5% | 524328 B | 524328 B |
| MediumMessageEcho | NA | NA | N/A | - | - |
| ModPow | 151,880,460.00 ns | 150,234,798.02 ns | **+1.1%** | 1986 B | 1986 B |
| Multiplication | 8,746.05 ns | 8,438.63 ns | **+3.5%** | 1048 B | 1048 B |
| NaiveDFT | 16,363.8 μs | 16,696.2 μs | -2.0% | 16.02 KB | 16.02 KB |
| NestedJoinsLinq | 279,693.7 ns | 235,627.5 ns | [+] **+15.8%** | 440744 B | 440744 B |
| NestedJoinsManual | 64,171.9 ns | 50,770.4 ns | [+] **+20.9%** | 102216 B | 102136 B |
| NewtonsoftDeepNest | 7,892.8 ns | 6,245.3 ns | [+] **+20.9%** | 5368 B | 5368 B |
| NewtonsoftJObjectMod | 1,957.4 ns | 1,621.3 ns | [+] **+17.2%** | 4696 B | 4704 B |
| ParallelFor | 50.46 μs | 34.07 μs | [+] **+32.5%** | 4.35 KB | 4.39 KB |
| ParallelForEachCpu | 106,496,287.5 ns | 102,167,891.8 ns | **+4.1%** | 7389 B | 6901 B |
| PlinqCpu | 1,971,647.3 ns | 1,649,040.0 ns | [+] **+16.4%** | 9272 B | 9272 B |
| SelectManyLinq | 18,259,933.7 ns | 25,466,410.2 ns | [-] -39.5% | 160168 B | 160128 B |
| SemaphoreContention | 7,249.00 μs | 5,884.440 μs | [+] **+18.8%** | 4071320 B | 4066278 B |
| Sha256 | 494,973.4 ns | 493,138.0 ns | **+0.4%** | 56 B | 56 B |
| Sha512 | 1,833,030.7 ns | 1,808,415.4 ns | **+1.3%** | 88 B | 88 B |
| SieveParallel | 6,324.9 μs | 6,244.3 μs | **+1.3%** | 4.68 KB | 4.81 KB |
| SieveSingleThread | 2,588.7 μs | 2,369.9 μs | [+] **+8.5%** | 976.67 KB | 976.65 KB |
| SimdNormalize | 77,487.685 ns | 77,787.932 ns | -0.4% | 0 B | 0 B |
| SmallMessageEcho | NA | NA | N/A | - | - |
| SpanDeserialization | 324.6 ns | 252.2 ns | [+] **+22.3%** | 88 B | 88 B |
| SpanOperation | 2,433.0 ns | 3,246.3 ns | [-] -33.4% | 0 B | 0 B |
| SpanSort | 355,020.944 ns | 363,138.637 ns | -2.3% | 40024 B | 40024 B |
| SpinLockContention | 81,158.18 μs | 87,790.397 μs | [-] -8.2% | 5571 B | 11059 B |
| StjCustomConverter | 28,867.1 ns | 27,516.6 ns | **+4.7%** | 10911 B | 13834 B |
| StjDeepNest | 6,178.6 ns | 4,504.1 ns | [+] **+27.1%** | 7648 B | 7648 B |
| StjJsonNodeMod | 1,006.0 ns | 766.7 ns | [+] **+23.8%** | 1184 B | 1040 B |
| StjStreaming | 107,639.7 ns | 76,560.0 ns | [+] **+28.9%** | 0 B | 0 B |
| TaskOverhead | 1,736.78 μs | 1,823.426 μs | -5.0% | 720204 B | 720202 B |
| TextMessageEcho | NA | NA | N/A | - | - |
| ThreadOverhead | 9,355.29 μs | 9,062.565 μs | **+3.1%** | 14434 B | 14430 B |
| Utf8ScanLoop | 40.895 ns | 41.185 ns | -0.7% | 0 B | 0 B |
| Utf8ScanSpan | 2.099 ns | 1.238 ns | [+] **+41.0%** | 0 B | 0 B |
| ValueTaskOverhead | 12.58 μs | 9.053 μs | [+] **+28.0%** | 0 B | 0 B |
| WebSocketEcho | NA | NA | N/A | NA | NA |

## Summary

- **Total Benchmarks**: 60
- **Improvements**: 34 (56.7%)
- **Regressions**: 16
- **Neutral**: 10

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
