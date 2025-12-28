# Entity Framework Core - .NET 8 vs .NET 10 Performance

**Generated:** 2025-12-15 15:38:36

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
| AsNoTracking | 102,674.46 ns | 73,496.77 ns | [+] **+28.4%** | 42281 B | 45873 B |
| BulkInsert | 31,672,144.12 ns | 28,498,234.82 ns | [+] **+10.0%** | 11538680 B | 10310026 B |
| BulkUpdate | 123,968,292.43 ns | 121,990,883.32 ns | **+1.6%** | 59492305 B | 57384135 B |
| Caching | 36.54 ns | 29.61 ns | [+] **+19.0%** | 64 B | 0 B |
| ColdStart | 104,321.34 ns | 105,589.52 ns | -1.2% | 59567 B | 63460 B |
| ComplexQuery | 114,037.51 ns | 175,685.59 ns | [-] -54.1% | 42016 B | 54736 B |
| Delete | 1,654,737.89 ns | 1,679,330.26 ns | -1.5% | 79423 B | 83322 B |
| Insert | 873,156.78 ns | 895,315.44 ns | -2.5% | 66383 B | 68723 B |
| LinqQuery | 67,529.55 ns | 65,395.57 ns | **+3.2%** | 35168 B | 37696 B |
| QueryTop100 | 54,568.43 ns | 60,077.88 ns | [-] -10.1% | 34513 B | 37569 B |
| RawSql | 65,609.71 ns | 61,816.23 ns | [+] **+5.8%** | 38185 B | 40384 B |
| SimpleQuery | 36.12 ns | 24.36 ns | [+] **+32.6%** | 88 B | 56 B |
| Update | 104,024.48 ns | 103,417.31 ns | **+0.6%** | 60140 B | 63828 B |

## Summary

- **Total Benchmarks**: 13
- **Improvements**: 8 (61.5%)
- **Regressions**: 5
- **Neutral**: 0

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
