# Benchmark Runner Script
# This script runs all benchmarks in the project and collects results

param(
    [switch]$SkipBaseline,
    [switch]$SkipEfCore,
    [switch]$SkipApi,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$OriginalLocation = Get-Location

# Color output functions
function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

# Results tracking
$Results = @{
    BaselineDotNet8  = $null
    BaselineDotNet10 = $null
    EfCoreDotNet8    = $null
    EfCoreDotNet10   = $null
    ApiDotNet8NoOp   = $null
    ApiDotNet10NoOp  = $null
    ApiDotNet8Cpu    = $null
    ApiDotNet10Cpu   = $null
    Errors           = @()
}

$StartTime = Get-Date

try {
    Write-Header "Starting Benchmark Suite"
    Write-Info "Start Time: $StartTime"
    Write-Info "Working Directory: $PWD"

    # 1. Baseline Benchmarks
    if (-not $SkipBaseline) {
        Write-Header "Running Baseline Benchmarks (CPU, Memory, I/O)"
        
        # .NET 8 Baseline
        Write-Info "Running .NET 8 Baseline Benchmarks..."
        try {
            Set-Location "BenchmarkDotNet8\.NET8.Benchmarks"
            $output = dotnet run -c Release 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success ".NET 8 Baseline benchmarks completed"
                $Results.BaselineDotNet8 = "Success"
            }
            else {
                throw "dotnet run failed with exit code $LASTEXITCODE"
            }
            if ($Verbose) { Write-Host $output }
        }
        catch {
            Write-Error-Custom ".NET 8 Baseline benchmarks failed: $_"
            $Results.BaselineDotNet8 = "Failed: $_"
            $Results.Errors += "Baseline .NET 8: $_"
        }
        finally {
            Set-Location $OriginalLocation
        }

        # .NET 10 Baseline
        Write-Info "Running .NET 10 Baseline Benchmarks..."
        try {
            Set-Location "BenchmarkDotNet10\.NET10.Benchmarks"
            $output = dotnet run -c Release 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success ".NET 10 Baseline benchmarks completed"
                $Results.BaselineDotNet10 = "Success"
            }
            else {
                throw "dotnet run failed with exit code $LASTEXITCODE"
            }
            if ($Verbose) { Write-Host $output }
        }
        catch {
            Write-Error-Custom ".NET 10 Baseline benchmarks failed: $_"
            $Results.BaselineDotNet10 = "Failed: $_"
            $Results.Errors += "Baseline .NET 10: $_"
        }
        finally {
            Set-Location $OriginalLocation
        }
    }
    else {
        Write-Info "Skipping Baseline Benchmarks"
    }

    # 2. EF Core Benchmarks
    if (-not $SkipEfCore) {
        Write-Header "Running EF Core Benchmarks"
        
        # .NET 8 EF Core
        Write-Info "Running .NET 8 EF Core Benchmarks..."
        try {
            Set-Location "BenchmarkDotNet8\.NET8.EfCoreBenchmarks"
            $output = dotnet run -c Release 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success ".NET 8 EF Core benchmarks completed"
                $Results.EfCoreDotNet8 = "Success"
            }
            else {
                throw "dotnet run failed with exit code $LASTEXITCODE"
            }
            if ($Verbose) { Write-Host $output }
        }
        catch {
            Write-Error-Custom ".NET 8 EF Core benchmarks failed: $_"
            $Results.EfCoreDotNet8 = "Failed: $_"
            $Results.Errors += "EF Core .NET 8: $_"
        }
        finally {
            Set-Location $OriginalLocation
        }

        # .NET 10 EF Core
        Write-Info "Running .NET 10 EF Core Benchmarks..."
        try {
            Set-Location "BenchmarkDotNet10\.NET10.EfCoreBenchmarks"
            $output = dotnet run -c Release 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success ".NET 10 EF Core benchmarks completed"
                $Results.EfCoreDotNet10 = "Success"
            }
            else {
                throw "dotnet run failed with exit code $LASTEXITCODE"
            }
            if ($Verbose) { Write-Host $output }
        }
        catch {
            Write-Error-Custom ".NET 10 EF Core benchmarks failed: $_"
            $Results.EfCoreDotNet10 = "Failed: $_"
            $Results.Errors += "EF Core .NET 10: $_"
        }
        finally {
            Set-Location $OriginalLocation
        }
    }
    else {
        Write-Info "Skipping EF Core Benchmarks"
    }

    # 3. API Benchmarks
    if (-not $SkipApi) {
        Write-Header "Running API Benchmarks"
        
        # Prepare results file
        $ApiResultsDir = "results\api"
        if (-not (Test-Path $ApiResultsDir)) {
            New-Item -ItemType Directory -Path $ApiResultsDir -Force | Out-Null
        }
        $ApiResultsFile = "$ApiResultsDir\results.md"
        "API Benchmark Results" | Out-File -FilePath $ApiResultsFile -Encoding UTF8
        "---------------------" | Out-File -FilePath $ApiResultsFile -Append -Encoding UTF8
        
        Write-Info "Starting API servers..."
        
        # Start .NET 8 API
        Write-Info "Starting .NET 8 API on port 5008..."
        $api8Job = Start-Job -ScriptBlock {
            Set-Location "d:\Programming\Benchmark\BenchmarkApi8"
            dotnet run -c Release --urls http://localhost:5008
        }
        
        # Start .NET 10 API
        Write-Info "Starting .NET 10 API on port 5010..."
        $api10Job = Start-Job -ScriptBlock {
            Set-Location "d:\Programming\Benchmark\BenchmarkApi10"
            dotnet run -c Release --urls http://localhost:5010
        }
        
        # Wait for APIs to start
        Write-Info "Waiting for APIs to start (30 seconds)..."
        Start-Sleep -Seconds 30
        
        # Check if APIs are running
        $api8Running = $false
        $api10Running = $false
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5008/benchmark/noop" -TimeoutSec 5 -ErrorAction SilentlyContinue
            $api8Running = $true
            Write-Success ".NET 8 API is running"
        }
        catch {
            Write-Error-Custom ".NET 8 API failed to start"
            $Results.Errors += "API .NET 8 failed to start"
        }
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5010/benchmark/noop" -TimeoutSec 5 -ErrorAction SilentlyContinue
            $api10Running = $true
            Write-Success ".NET 10 API is running"
        }
        catch {
            Write-Error-Custom ".NET 10 API failed to start"
            $Results.Errors += "API .NET 10 failed to start"
        }
        
        # Run API benchmarks if servers are running
        if ($api8Running -or $api10Running) {
            # Test .NET 8 No-Op endpoint
            if ($api8Running) {
                Write-Info "Benchmarking .NET 8 No-Op endpoint..."
                try {
                    $output = dotnet run --project ApiBenchmark -- http://localhost:5008/benchmark/noop 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success ".NET 8 No-Op benchmark completed"
                        $Results.ApiDotNet8NoOp = "Success"
                        
                        # Parse and save results
                        $outputStr = $output | Out-String
                        if ($outputStr -match "RPS: ([\d\.]+)") {
                            $rps = $matches[1]
                            ".NET 8 No-Op: $rps RPS" | Out-File -FilePath $ApiResultsFile -Append -Encoding UTF8
                        }
                    }
                    else {
                        throw "Benchmark failed with exit code $LASTEXITCODE"
                    }
                    if ($Verbose) { Write-Host $output }
                }
                catch {
                    Write-Error-Custom ".NET 8 No-Op benchmark failed: $_"
                    $Results.ApiDotNet8NoOp = "Failed: $_"
                    $Results.Errors += "API .NET 8 No-Op: $_"
                }
            }
            
            # Test .NET 10 No-Op endpoint
            if ($api10Running) {
                Write-Info "Benchmarking .NET 10 No-Op endpoint..."
                try {
                    $output = dotnet run --project ApiBenchmark -- http://localhost:5010/benchmark/noop 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success ".NET 10 No-Op benchmark completed"
                        $Results.ApiDotNet10NoOp = "Success"
                        
                        # Parse and save results
                        $outputStr = $output | Out-String
                        if ($outputStr -match "RPS: ([\d\.]+)") {
                            $rps = $matches[1]
                            ".NET 10 No-Op: $rps RPS" | Out-File -FilePath $ApiResultsFile -Append -Encoding UTF8
                        }
                    }
                    else {
                        throw "Benchmark failed with exit code $LASTEXITCODE"
                    }
                    if ($Verbose) { Write-Host $output }
                }
                catch {
                    Write-Error-Custom ".NET 10 No-Op benchmark failed: $_"
                    $Results.ApiDotNet10NoOp = "Failed: $_"
                    $Results.Errors += "API .NET 10 No-Op: $_"
                }
            }
            
            # Test .NET 8 CPU endpoint
            if ($api8Running) {
                Write-Info "Benchmarking .NET 8 CPU endpoint..."
                try {
                    $output = dotnet run --project ApiBenchmark -- http://localhost:5008/benchmark/cpu 2>&1
                    Write-Host $output
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success ".NET 8 CPU benchmark completed"
                        $Results.ApiDotNet8Cpu = "Success"
                        
                        # Parse and save results
                        $outputStr = $output | Out-String
                        if ($outputStr -match "RPS: ([\d\.]+)") {
                            $rps = $matches[1]
                            ".NET 8 CPU: $rps RPS" | Out-File -FilePath $ApiResultsFile -Append -Encoding UTF8
                        }
                    }
                    else {
                        throw "Benchmark failed with exit code $LASTEXITCODE"
                    }
                    if ($Verbose) { Write-Host $output }
                }
                catch {
                    Write-Error-Custom ".NET 8 CPU benchmark failed: $_"
                    $Results.ApiDotNet8Cpu = "Failed: $_"
                    $Results.Errors += "API .NET 8 CPU: $_"
                }
            }
            
            # Test .NET 10 CPU endpoint
            if ($api10Running) {
                Write-Info "Benchmarking .NET 10 CPU endpoint..."
                try {
                    $output = dotnet run --project ApiBenchmark -- http://localhost:5010/benchmark/cpu 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success ".NET 10 CPU benchmark completed"
                        $Results.ApiDotNet10Cpu = "Success"
                        
                        # Parse and save results
                        $outputStr = $output | Out-String
                        if ($outputStr -match "RPS: ([\d\.]+)") {
                            $rps = $matches[1]
                            ".NET 10 CPU: $rps RPS" | Out-File -FilePath $ApiResultsFile -Append -Encoding UTF8
                        }
                    }
                    else {
                        throw "Benchmark failed with exit code $LASTEXITCODE"
                    }
                    if ($Verbose) { Write-Host $output }
                }
                catch {
                    Write-Error-Custom ".NET 10 CPU benchmark failed: $_"
                    $Results.ApiDotNet10Cpu = "Failed: $_"
                    $Results.Errors += "API .NET 10 CPU: $_"
                }
            }
        }
        
        # Stop API servers
        Write-Info "Stopping API servers..."
        Stop-Job -Job $api8Job -ErrorAction SilentlyContinue
        Stop-Job -Job $api10Job -ErrorAction SilentlyContinue
        Remove-Job -Job $api8Job -ErrorAction SilentlyContinue
        Remove-Job -Job $api10Job -ErrorAction SilentlyContinue
        Write-Success "API servers stopped"
        
    }
    else {
        Write-Info "Skipping API Benchmarks"
    }

}
finally {
    Set-Location $OriginalLocation
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

# Display Results Summary
Write-Header "Benchmark Results Summary"
Write-Host "Total Duration: $($Duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host ""

Write-Host "Baseline Benchmarks:" -ForegroundColor White
Write-Host "  .NET 8:  $(if ($null -ne $Results.BaselineDotNet8) { $Results.BaselineDotNet8 } else { 'Skipped' })" -ForegroundColor $(if ($Results.BaselineDotNet8 -eq 'Success') { 'Green' } elseif ($Results.BaselineDotNet8 -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host "  .NET 10: $(if ($null -ne $Results.BaselineDotNet10) { $Results.BaselineDotNet10 } else { 'Skipped' })" -ForegroundColor $(if ($Results.BaselineDotNet10 -eq 'Success') { 'Green' } elseif ($Results.BaselineDotNet10 -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host ""

Write-Host "EF Core Benchmarks:" -ForegroundColor White
Write-Host "  .NET 8:  $(if ($null -ne $Results.EfCoreDotNet8) { $Results.EfCoreDotNet8 } else { 'Skipped' })" -ForegroundColor $(if ($Results.EfCoreDotNet8 -eq 'Success') { 'Green' } elseif ($Results.EfCoreDotNet8 -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host "  .NET 10: $(if ($null -ne $Results.EfCoreDotNet10) { $Results.EfCoreDotNet10 } else { 'Skipped' })" -ForegroundColor $(if ($Results.EfCoreDotNet10 -eq 'Success') { 'Green' } elseif ($Results.EfCoreDotNet10 -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host ""

Write-Host "API Benchmarks:" -ForegroundColor White
Write-Host "  .NET 8 No-Op:  $(if ($null -ne $Results.ApiDotNet8NoOp) { $Results.ApiDotNet8NoOp } else { 'Skipped' })" -ForegroundColor $(if ($Results.ApiDotNet8NoOp -eq 'Success') { 'Green' } elseif ($Results.ApiDotNet8NoOp -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host "  .NET 10 No-Op: $(if ($null -ne $Results.ApiDotNet10NoOp) { $Results.ApiDotNet10NoOp } else { 'Skipped' })" -ForegroundColor $(if ($Results.ApiDotNet10NoOp -eq 'Success') { 'Green' } elseif ($Results.ApiDotNet10NoOp -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host "  .NET 8 CPU:    $(if ($null -ne $Results.ApiDotNet8Cpu) { $Results.ApiDotNet8Cpu } else { 'Skipped' })" -ForegroundColor $(if ($Results.ApiDotNet8Cpu -eq 'Success') { 'Green' } elseif ($Results.ApiDotNet8Cpu -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host "  .NET 10 CPU:   $(if ($null -ne $Results.ApiDotNet10Cpu) { $Results.ApiDotNet10Cpu } else { 'Skipped' })" -ForegroundColor $(if ($Results.ApiDotNet10Cpu -eq 'Success') { 'Green' } elseif ($Results.ApiDotNet10Cpu -like 'Failed*') { 'Red' } else { 'Gray' })
Write-Host ""

if ($Results.Errors.Count -gt 0) {
    Write-Host "Errors Encountered:" -ForegroundColor Red
    foreach ($error in $Results.Errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Header "Results Location"
Write-Info "Baseline results: BenchmarkDotNet8\.NET8.Benchmarks\BenchmarkDotNet.Artifacts\results"
Write-Info "                  BenchmarkDotNet10\.NET10.Benchmarks\BenchmarkDotNet.Artifacts\results"
Write-Info "EF Core results:  BenchmarkDotNet8\.NET8.EfCoreBenchmarks\BenchmarkDotNet.Artifacts\results"
Write-Info "                  BenchmarkDotNet10\.NET10.EfCoreBenchmarks\BenchmarkDotNet.Artifacts\results"
Write-Info "                  (Separate files for SQLite, InMemory, and AzureSQL providers)"
Write-Info "API results:      Check console output above for RPS and latency metrics"

# Generate Reports
if (Test-Path ".\generate-final-report.ps1") {
    Write-Header "Generating Reports"
    Write-Info "Executing generate-final-report.ps1..."
    .\generate-final-report.ps1
    
    if (Test-Path ".\generate-html-report.ps1") {
        Write-Info "Executing generate-html-report.ps1..."
        .\generate-html-report.ps1
    }
    
    if (Test-Path ".\generate-dashboard.ps1") {
        Write-Info "Executing generate-dashboard.ps1..."
        .\generate-dashboard.ps1
    }
}

Write-Host "`nBenchmark suite completed!" -ForegroundColor Green
