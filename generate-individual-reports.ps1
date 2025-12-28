# Generate Individual Benchmark Reports
# This script creates separate report files for each benchmark category

param(
    [string]$OutputDir = "results\reports"
)

$ErrorActionPreference = "Continue"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Generating Individual Benchmark Reports" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

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
        $data = Import-Csv $file.FullName
        foreach ($row in $data) {
            $benchmarkName = $row.Method
            if ($row.Type) {
                $className = ($row.Type -split '\.')[-1] -replace 'Benchmarks$', ''
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
                Type      = $row.Type
            }
        }
    }
    return $results
}

# Group benchmarks by category
function Get-BenchmarkCategory {
    param([string]$BenchmarkName)
    
    if ($BenchmarkName -match '^BigInteger\.') { return "CPU - BigInteger Arithmetic" }
    if ($BenchmarkName -match '^Prime\.') { return "CPU - Prime Generation" }
    if ($BenchmarkName -match '^Fft\.') { return "CPU - Fast Fourier Transform" }
    if ($BenchmarkName -match '^ImageProcessing\.') { return "CPU - Image Processing" }
    if ($BenchmarkName -match '^Hashing\.') { return "CPU - Cryptographic Hashing" }
    if ($BenchmarkName -match '^Json\.') { return "JSON Processing" }
    if ($BenchmarkName -match '^Threading\.') { return "Threading & Concurrency" }
    if ($BenchmarkName -match '^Networking\.') { return "Networking" }
    if ($BenchmarkName -match '^WebSocket\.') { return "WebSocket Communication" }
    if ($BenchmarkName -match '^Linq\.') { return "LINQ Operations" }
    if ($BenchmarkName -match '^Simd\.') { return "SIMD & Span<T>" }
    if ($BenchmarkName -match '^Cpu\.') { return "Baseline - CPU" }
    if ($BenchmarkName -match '^Memory\.') { return "Baseline - Memory" }
    if ($BenchmarkName -match '^Io\.') { return "Baseline - I/O" }
    if ($BenchmarkName -match '^Concurrency\.') { return "Baseline - Concurrency" }
    return "Other"
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

# Collect all unique benchmark names by category
$allBenchmarks = @{}
if ($net8BaselineResults) {
    foreach ($key in $net8BaselineResults.Keys) {
        $category = Get-BenchmarkCategory $key
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
        $category = Get-BenchmarkCategory $key
        if (-not $allBenchmarks.ContainsKey($category)) {
            $allBenchmarks[$category] = @()
        }
        if ($allBenchmarks[$category] -notcontains $key) {
            $allBenchmarks[$category] += $key
        }
    }
}

# Generate individual report for each category
foreach ($category in ($allBenchmarks.Keys | Sort-Object)) {
    $safeFileName = $category -replace '[^a-zA-Z0-9]', '_'
    $reportPath = Join-Path $OutputDir "$safeFileName.md"
    
    Write-Host "Generating report for: $category" -ForegroundColor Yellow
    
    $categoryReport = @"
# $category - .NET 8 vs .NET 10 Performance

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
"@
    
    $categoryImprovements = 0
    $categoryRegressions = 0
    $categoryTotal = 0
    
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
        
        if ($improvement -match '\+') { $categoryImprovements++ }
        elseif ($improvement -match '-') { $categoryRegressions++ }
        $categoryTotal++
        
        $benchmarkDisplay = $benchmark -replace '^\w+\.', ''
        $categoryReport += "`n| $benchmarkDisplay | $net8Mean | $net10Mean | $improvement | $net8Alloc | $net10Alloc |"
    }
    
    $categoryImprovementRate = if ($categoryTotal -gt 0) { [math]::Round(($categoryImprovements / $categoryTotal) * 100, 1) } else { 0 }
    
    $categoryReport += @"


## Summary

- **Total Benchmarks**: $categoryTotal
- **Improvements**: $categoryImprovements ($categoryImprovementRate%)
- **Regressions**: $categoryRegressions
- **Neutral**: $($categoryTotal - $categoryImprovements - $categoryRegressions)

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
"@
    
    $categoryReport | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "  [CREATED] $reportPath" -ForegroundColor Green
}

# Generate EF Core report
if ($net8EfResults -and $net10EfResults) {
    $reportPath = Join-Path $OutputDir "Entity_Framework_Core.md"
    Write-Host "Generating report for: Entity Framework Core" -ForegroundColor Yellow
    
    $efReport = @"
# Entity Framework Core - .NET 8 vs .NET 10 Performance

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Benchmark | .NET 8 Mean | .NET 10 Mean | Improvement | .NET 8 Allocated | .NET 10 Allocated |
|-----------|-------------|--------------|-------------|------------------|-------------------|
"@
    
    $efImprovements = 0
    $efRegressions = 0
    $efTotal = 0
    
    $allEfBenchmarks = @()
    $allEfBenchmarks += $net8EfResults.Keys
    $allEfBenchmarks += $net10EfResults.Keys
    $allEfBenchmarks = $allEfBenchmarks | Select-Object -Unique | Sort-Object
    
    foreach ($benchmark in $allEfBenchmarks) {
        $net8Data = if ($net8EfResults.ContainsKey($benchmark)) { $net8EfResults[$benchmark] } else { $null }
        $net10Data = if ($net10EfResults.ContainsKey($benchmark)) { $net10EfResults[$benchmark] } else { $null }
        
        $net8Mean = if ($net8Data) { $net8Data.Mean } else { "N/A" }
        $net10Mean = if ($net10Data) { $net10Data.Mean } else { "N/A" }
        $net8Alloc = if ($net8Data -and $net8Data.Allocated) { $net8Data.Allocated } else { "-" }
        $net10Alloc = if ($net10Data -and $net10Data.Allocated) { $net10Data.Allocated } else { "-" }
        
        $improvement = Get-Improvement -Net8Value $net8Mean -Net10Value $net10Mean
        
        if ($improvement -match '\+') { $efImprovements++ }
        elseif ($improvement -match '-') { $efRegressions++ }
        $efTotal++
        
        $efReport += "`n| $benchmark | $net8Mean | $net10Mean | $improvement | $net8Alloc | $net10Alloc |"
    }
    
    $efImprovementRate = if ($efTotal -gt 0) { [math]::Round(($efImprovements / $efTotal) * 100, 1) } else { 0 }
    
    $efReport += @"


## Summary

- **Total Benchmarks**: $efTotal
- **Improvements**: $efImprovements ($efImprovementRate%)
- **Regressions**: $efRegressions
- **Neutral**: $($efTotal - $efImprovements - $efRegressions)

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
"@
    
    $efReport | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "  [CREATED] $reportPath" -ForegroundColor Green
}

# Generate API report
if ($apiResults.Count -gt 0) {
    $reportPath = Join-Path $OutputDir "Web_API_Throughput.md"
    Write-Host "Generating report for: Web API Throughput" -ForegroundColor Yellow
    
    $apiReport = @"
# Web API Throughput - .NET 8 vs .NET 10 Performance

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Legend
- [+] **Significant improvement** (>5%)
- **Improvement** (0-5%)
- **Regression** (<0%)
- [-] **Significant regression** (<-5%)

## Results

| Endpoint | .NET 8 RPS | .NET 10 RPS | Improvement | Description |
|----------|------------|-------------|-------------|-------------|
"@
    
    $apiImprovements = 0
    $apiRegressions = 0
    $apiTotal = 0
    
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
        $apiReport += "`n| No-Op | {0:N2} | {1:N2} | $improvement | Minimal endpoint with no processing |" -f $net8Rps, $net10Rps
        
        if ($improvement -match '\+') { $apiImprovements++ }
        elseif ($improvement -match '-') { $apiRegressions++ }
        $apiTotal++
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
        $apiReport += "`n| CPU-Bound | {0:N2} | {1:N2} | $improvement | Fibonacci calculation (n=20) |" -f $net8Rps, $net10Rps
        
        if ($improvement -match '\+') { $apiImprovements++ }
        elseif ($improvement -match '-') { $apiRegressions++ }
        $apiTotal++
    }
    
    $apiImprovementRate = if ($apiTotal -gt 0) { [math]::Round(($apiImprovements / $apiTotal) * 100, 1) } else { 0 }
    
    $apiReport += @"


## Summary

- **Total Benchmarks**: $apiTotal
- **Improvements**: $apiImprovements ($apiImprovementRate%)
- **Regressions**: $apiRegressions
- **Neutral**: $($apiTotal - $apiImprovements - $apiRegressions)

---

*Part of .NET 8 vs .NET 10 Benchmark Suite*
"@
    
    $apiReport | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "  [CREATED] $reportPath" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "[SUCCESS] Individual reports generated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nReports location: $OutputDir" -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Filter "*.md" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
