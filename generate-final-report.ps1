# Generate Final Benchmark Report - Fixed Version
# This script aggregates all benchmark results and creates final_report.md with proper categorization

param(
    [string]$OutputFile = "results\final_report.md"
)

$ErrorActionPreference = "Continue"

# Helper function to calculate improvement percentage
function Get-Improvement {
    param(
        [string]$Net8Value,
        [string]$Net10Value
    )
    
    if ([string]::IsNullOrEmpty($Net8Value) -or [string]::IsNullOrEmpty($Net10Value)) {
        return "N/A"
    }
    
    # Extract numeric value
    $net8Numeric = 0.0
    $net10Numeric = 0.0
    
    # Parse values with units
    if ($Net8Value -match '([\d,\.]+)\s*(\w+)') {
        $net8Numeric = [double]($matches[1] -replace ',', '')
    }
    
    if ($Net10Value -match '([\d,\.]+)\s*(\w+)') {
        $net10Numeric = [double]($matches[1] -replace ',', '')
    }
    
    if ($net8Numeric -eq 0 -or $net10Numeric -eq 0) {
        return "N/A"
    }
    
    # Calculate improvement (lower is better for time-based metrics)
    $improvementPercent = (($net8Numeric - $net10Numeric) / $net8Numeric) * 100
    
    # Format with sign and color coding
    if ($improvementPercent -gt 5) {
        return "[+] **+{0:F1}%**" -f $improvementPercent
    }
    elseif ($improvementPercent -gt 0) {
        return "**+{0:F1}%**" -f $improvementPercent
    }
    elseif ($improvementPercent -lt -5) {
        return "[-] {0:F1}%" -f $improvementPercent
    }
    elseif ($improvementPercent -lt 0) {
        return "{0:F1}%" -f $improvementPercent
    }
    else {
        return "~0%"
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Generating Final Benchmark Report" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Helper function to parse BenchmarkDotNet results
function Get-BenchmarkResults {
    param([string]$ResultsPath)
    
    if (-not (Test-Path $ResultsPath)) {
        Write-Host "[WARNING] Results not found: $ResultsPath" -ForegroundColor Yellow
        return $null
    }
    
    $csvFiles = Get-ChildItem -Path $ResultsPath -Filter "*-report.csv" -ErrorAction SilentlyContinue
    if ($csvFiles.Count -eq 0) {
        return $null
    }
    
    Write-Host "[INFO] Found $($csvFiles.Count) result files in $ResultsPath" -ForegroundColor Yellow
    
    $results = @{}
    foreach ($file in $csvFiles) {
        Write-Host "  - Processing: $($file.Name)" -ForegroundColor Gray
        
        # Extract class name from filename
        $className = ""
        if ($file.Name -match 'Benchmarks\.(\w+)Benchmarks-report\.csv') {
            $className = $matches[1]
        }
        elseif ($file.Name -match 'EfCoreBenchmarks\.(EfBenchmarks\w*)-report\.csv') {
            $className = $matches[1]
        }
        
        $data = Import-Csv $file.FullName
        foreach ($row in $data) {
            $benchmarkName = $row.Method
            if ($className) {
                $benchmarkName = "$className.$($row.Method)"
            }
            $results[$benchmarkName] = @{
                Mean      = $row.Mean
                Error     = $row.Error
                StdDev    = $row.StdDev
                Allocated = $row.Allocated
                Gen0      = $row.'Gen0'
                Gen1      = $row.'Gen1'
                Gen2      = $row.'Gen2'
                ClassName = $className
            }
        }
    }
    return $results
}

# Parse all benchmark results
Write-Host "[INFO] Parsing benchmark results..." -ForegroundColor Yellow

$net8BaselineResults = Get-BenchmarkResults "BenchmarkDotNet8\.NET8.Benchmarks\BenchmarkDotNet.Artifacts\results"
$net10BaselineResults = Get-BenchmarkResults "BenchmarkDotNet10\.NET10.Benchmarks\BenchmarkDotNet.Artifacts\results"
$net8EfResults = Get-BenchmarkResults "BenchmarkDotNet8\.NET8.EfCoreBenchmarks\BenchmarkDotNet.Artifacts\results"
$net10EfResults = Get-BenchmarkResults "BenchmarkDotNet10\.NET10.EfCoreBenchmarks\BenchmarkDotNet.Artifacts\results"

# Parse API results if available
$apiResultsPath = "results\api\results.md"
$apiResults = @{}
if (Test-Path $apiResultsPath) {
    $apiContent = Get-Content $apiResultsPath -Raw
    if ($apiContent -match '.NET 8 No-Op:\s*([\d,\.]+)\s*RPS') {
        $apiResults['Net8NoOp'] = $matches[1] -replace ',', ''
    }
    if ($apiContent -match '.NET 10 No-Op:\s*([\d,\.]+)\s*RPS') {
        $apiResults['Net10NoOp'] = $matches[1] -replace ',', ''
    }
    if ($apiContent -match '.NET 8 CPU:\s*([\d,\.]+)\s*RPS') {
        $apiResults['Net8Cpu'] = $matches[1] -replace ',', ''
    }
    if ($apiContent -match '.NET 10 CPU:\s*([\d,\.]+)\s*RPS') {
        $apiResults['Net10Cpu'] = $matches[1] -replace ',', ''
    }
}

# Calculate summary statistics
$totalBenchmarks = 0
$improvements = 0
$regressions = 0

# Start building the report
$report = @"
# .NET 8 vs .NET 10 Performance Benchmark Report

## Executive Summary

This comprehensive report compares the performance of .NET 8 and .NET 10 across various workloads including CPU-intensive operations, JSON processing, networking, threading, LINQ, SIMD optimizations, Entity Framework Core, and Web API throughput.

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

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

"@

# Group benchmarks by category
function Get-BenchmarkCategory {
    param([string]$BenchmarkName, [hashtable]$BenchmarkData)
    
    # Use the ClassName from the benchmark data if available
    if ($BenchmarkData -and $BenchmarkData.ClassName) {
        $className = $BenchmarkData.ClassName
        
        # Return friendly names for each class
        switch ($className) {
            "Cpu" { return "CPU Benchmarks" }
            "Memory" { return "Memory Benchmarks" }
            "Concurrency" { return "Concurrency Benchmarks" }
            "Io" { return "I/O Benchmarks" }
            "BigInteger" { return "BigInteger Arithmetic" }
            "Prime" { return "Prime Generation" }
            "Fft" { return "Fast Fourier Transform (FFT)" }
            "ImageProcessing" { return "Image Processing" }
            "Hashing" { return "Cryptographic Hashing" }
            "Json" { return "JSON Processing" }
            "Threading" { return "Threading & Concurrency" }
            "Networking" { return "Networking" }
            "WebSocket" { return "WebSocket Communication" }
            "Linq" { return "LINQ Operations" }
            "Simd" { return "SIMD & Span<T>" }
            default { return $className }
        }
    }
    
    return "Other"
}

# Collect all unique benchmark names
$allBenchmarks = @{}
if ($net8BaselineResults) {
    foreach ($key in $net8BaselineResults.Keys) {
        $category = Get-BenchmarkCategory -BenchmarkName $key -BenchmarkData $net8BaselineResults[$key]
        if (-not $allBenchmarks.ContainsKey($category)) {
            $allBenchmarks[$category] = @()
        }
        if ($allBenchmarks[$category] -notcontains $key) {
            $allBenchmarks[$category] += $key
        }
    }
}
if ($net10BaselineResults) {
    foreach ($key in $net10BaselineResults.Keys) {
        $category = Get-BenchmarkCategory -BenchmarkName $key -BenchmarkData $net10BaselineResults[$key]
        if (-not $allBenchmarks.ContainsKey($category)) {
            $allBenchmarks[$category] = @()
        }
        if ($allBenchmarks[$category] -notcontains $key) {
            $allBenchmarks[$category] += $key
        }
    }
}

# Generate sections for each category
$sectionNumber = 1
foreach ($category in ($allBenchmarks.Keys | Sort-Object)) {
    $report += @"

## $sectionNumber. $category

### Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
"@
    
    foreach ($benchmark in ($allBenchmarks[$category] | Sort-Object)) {
        $net8Data = if ($net8BaselineResults -and $net8BaselineResults.ContainsKey($benchmark)) { 
            $net8BaselineResults[$benchmark] 
        }
        else { $null }
        
        $net10Data = if ($net10BaselineResults -and $net10BaselineResults.ContainsKey($benchmark)) { 
            $net10BaselineResults[$benchmark] 
        }
        else { $null }
        
        $net8Mean = if ($net8Data) { $net8Data.Mean } else { "N/A" }
        $net10Mean = if ($net10Data) { $net10Data.Mean } else { "N/A" }
        $net8Alloc = if ($net8Data -and $net8Data.Allocated) { $net8Data.Allocated } else { "-" }
        $net10Alloc = if ($net10Data -and $net10Data.Allocated) { $net10Data.Allocated } else { "-" }
        
        $improvement = Get-Improvement -Net8Value $net8Mean -Net10Value $net10Mean
        
        # Track statistics
        if ($improvement -match '\+') { $improvements++ }
        elseif ($improvement -match '-') { $regressions++ }
        $totalBenchmarks++
        
        $benchmarkDisplay = $benchmark -replace '^\w+\.', ''  # Remove class prefix for display
        $report += "`n| $benchmarkDisplay | $net8Mean | $net10Mean | $improvement | $net8Alloc | $net10Alloc |"
    }
    $sectionNumber++
}

# Add EF Core section with separate tables for each provider
if ($net8EfResults -and $net10EfResults) {
    $report += @"

## $sectionNumber. Entity Framework Core Benchmarks

This section compares EF Core performance across three database providers:
- **SQLite**: File-based database
- **InMemory**: In-memory database (no I/O overhead)
- **Azure SQL**: SQL Server / Azure SQL Database

"@
    
    # Group EF benchmarks by provider
    $efBenchmarksByProvider = @{
        'SQLite'   = @()
        'InMemory' = @()
        'AzureSQL' = @()
    }
    
    # Collect all unique benchmark names and categorize by provider
    $allEfBenchmarks = @()
    $allEfBenchmarks += $net8EfResults.Keys
    $allEfBenchmarks += $net10EfResults.Keys
    $allEfBenchmarks = $allEfBenchmarks | Select-Object -Unique
    
    foreach ($benchmark in $allEfBenchmarks) {
        # Get the class name from either .NET 8 or .NET 10 results
        $className = ""
        if ($net8EfResults[$benchmark] -and $net8EfResults[$benchmark].ClassName) {
            $className = $net8EfResults[$benchmark].ClassName
        }
        elseif ($net10EfResults[$benchmark] -and $net10EfResults[$benchmark].ClassName) {
            $className = $net10EfResults[$benchmark].ClassName
        }
        
        # Determine provider from class name
        if ($className -match 'InMemory') {
            $efBenchmarksByProvider['InMemory'] += $benchmark
        }
        elseif ($className -match 'AzureSQL') {
            $efBenchmarksByProvider['AzureSQL'] += $benchmark
        }
        else {
            # Default to SQLite (original EfBenchmarks class)
            $efBenchmarksByProvider['SQLite'] += $benchmark
        }
    }
    
    # Generate a table for each provider
    $providerOrder = @('SQLite', 'InMemory', 'AzureSQL')
    foreach ($provider in $providerOrder) {
        $benchmarks = $efBenchmarksByProvider[$provider] | Sort-Object
        
        if ($benchmarks.Count -gt 0) {
            $report += @"

### $provider Provider

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
"@
            
            foreach ($benchmark in $benchmarks) {
                $net8Data = if ($net8EfResults.ContainsKey($benchmark)) { $net8EfResults[$benchmark] } else { $null }
                $net10Data = if ($net10EfResults.ContainsKey($benchmark)) { $net10EfResults[$benchmark] } else { $null }
                
                $net8Mean = if ($net8Data) { $net8Data.Mean } else { "N/A" }
                $net10Mean = if ($net10Data) { $net10Data.Mean } else { "N/A" }
                $net8Alloc = if ($net8Data -and $net8Data.Allocated) { $net8Data.Allocated } else { "-" }
                $net10Alloc = if ($net10Data -and $net10Data.Allocated) { $net10Data.Allocated } else { "-" }
                
                $improvement = Get-Improvement -Net8Value $net8Mean -Net10Value $net10Mean
                
                if ($improvement -match '\+') { $improvements++ }
                elseif ($improvement -match '-') { $regressions++ }
                $totalBenchmarks++
                
                # Clean up benchmark name for display (remove class prefix)
                $benchmarkDisplay = $benchmark -replace '^EfBenchmarks(InMemory|AzureSQL)?\.', ''
                $report += "`n| $benchmarkDisplay | $net8Mean | $net10Mean | $improvement | $net8Alloc | $net10Alloc |"
            }
        }
    }
    
    $sectionNumber++
}

# Add API Benchmarks section
if ($apiResults.Count -gt 0) {
    $report += @"

## $sectionNumber. Web API Throughput

### Results

| Endpoint | .NET 8 RPS | .NET 10 RPS | Improvement | Description |
|----------|------------|-------------|-------------|-------------|
"@
    
    if ($apiResults.ContainsKey('Net8NoOp') -and $apiResults.ContainsKey('Net10NoOp')) {
        $net8Rps = [double]$apiResults['Net8NoOp']
        $net10Rps = [double]$apiResults['Net10NoOp']
        $improvement = if ($net8Rps -gt 0) {
            $pct = (($net10Rps - $net8Rps) / $net8Rps) * 100
            if ($pct -gt 5) { "[+] **+{0:F1}%**" -f $pct }
            elseif ($pct -gt 0) { "**+{0:F1}%**" -f $pct }
            elseif ($pct -lt -5) { "[-] {0:F1}%" -f $pct }
            else { "{0:F1}%" -f $pct }
        }
        else { "N/A" }
        $report += "`n| No-Op | {0:N2} | {1:N2} | $improvement | Minimal endpoint with no processing |" -f $net8Rps, $net10Rps
        
        if ($improvement -match '\+') { $improvements++ }
        elseif ($improvement -match '-') { $regressions++ }
        $totalBenchmarks++
    }
    
    if ($apiResults.ContainsKey('Net8Cpu') -and $apiResults.ContainsKey('Net10Cpu')) {
        $net8Rps = [double]$apiResults['Net8Cpu']
        $net10Rps = [double]$apiResults['Net10Cpu']
        $improvement = if ($net8Rps -gt 0) {
            $pct = (($net10Rps - $net8Rps) / $net8Rps) * 100
            if ($pct -gt 5) { "[+] **+{0:F1}%**" -f $pct }
            elseif ($pct -gt 0) { "**+{0:F1}%**" -f $pct }
            elseif ($pct -lt -5) { "[-] {0:F1}%" -f $pct }
            else { "{0:F1}%" -f $pct }
        }
        else { "N/A" }
        $report += "`n| CPU-Bound | {0:N2} | {1:N2} | $improvement | Fibonacci calculation (n=20) |" -f $net8Rps, $net10Rps
        
        if ($improvement -match '\+') { $improvements++ }
        elseif ($improvement -match '-') { $regressions++ }
        $totalBenchmarks++
    }
}

# Add summary statistics
$improvementRate = if ($totalBenchmarks -gt 0) { ($improvements / $totalBenchmarks) * 100 } else { 0 }
$regressionRate = if ($totalBenchmarks -gt 0) { ($regressions / $totalBenchmarks) * 100 } else { 0 }

$report += @"

---

## Performance Summary

- **Total Benchmarks**: $totalBenchmarks
- **Improvements**: $improvements ({0:F1}%)
- **Regressions**: $regressions ({1:F1}%)
- **Neutral**: $($totalBenchmarks - $improvements - $regressions)

"@ -f $improvementRate, $regressionRate

# Add recommendations
$report += @"

## Key Takeaways

### Strengths of .NET 10
- Improved performance in CPU-intensive workloads
- Better memory allocation patterns in many scenarios
- Enhanced EF Core query performance
- Optimized API throughput for compute-heavy endpoints

### Areas to Monitor
- Some baseline benchmarks show regressions
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
- **Runtime**: .NET 8.0 vs .NET 10.0
- **BenchmarkDotNet**: Latest version
- **Hardware**: [Your hardware specs]

## Next Steps

1. Review individual benchmark categories
2. Generate HTML report: `.\generate-html-report.ps1`
3. Create interactive dashboard: `.\generate-dashboard.ps1`
4. Analyze trends: `python analyze_trends.py`

---

*Generated by .NET 8 vs .NET 10 Benchmarking Suite*
"@

# Ensure results directory exists
$resultsDir = Split-Path $OutputFile -Parent
if ($resultsDir -and -not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "[SUCCESS] Report generated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nReport location: $OutputFile" -ForegroundColor Cyan
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host ("  Total Benchmarks: $totalBenchmarks") -ForegroundColor White
Write-Host ("  Improvements: $improvements ({0:F1}%)" -f $improvementRate) -ForegroundColor Green
Write-Host ("  Regressions: $regressions ({0:F1}%)" -f $regressionRate) -ForegroundColor Yellow

# Check for missing data (NA values)
if ($report -match '\| NA \|' -or $report -match '\| N/A \|') {
    Write-Host "`n[WARNING] Some benchmarks have missing values (NA). This usually indicates a setup failure." -ForegroundColor Red
    Write-Host "          Specifically, Networking/WebSocket benchmarks often require a test server." -ForegroundColor Red
    Write-Host "          Please run the following to fix:" -ForegroundColor Red
    Write-Host "          dotnet run -c Release --project BenchmarkDotNet8\.NET8.Benchmarks --filter ""*Networking*"" ""*WebSocket*""" -ForegroundColor Gray
    Write-Host "          (And similarly for .NET 10)" -ForegroundColor Gray
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  View Report: cat $OutputFile" -ForegroundColor White
Write-Host "  Generate HTML: .\generate-html-report.ps1" -ForegroundColor White
Write-Host "  Generate Dashboard: .\generate-dashboard.ps1" -ForegroundColor White
