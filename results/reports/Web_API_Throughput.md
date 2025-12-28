# Web API Throughput - .NET 8 vs .NET 10 Performance

**Generated:** 2025-12-15 15:38:36

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Endpoint | .NET 8 RPS | .NET 10 RPS | Improvement | Description |
|----------|------------|-------------|-------------|-------------|
| No-Op | 8,327.98 | 7,367.20 | [-] -11.5% | Minimal endpoint with no processing |
| CPU-Bound | 7,887.30 | 7,380.38 | [-] -6.4% | Fibonacci calculation (n=20) |

## Summary

- **Total Benchmarks**: 2
- **Improvements**: 0 (0%)
- **Regressions**: 2
- **Neutral**: 0

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
