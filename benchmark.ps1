
$baseUrl = "http://localhost:5219"
$runs = 10

$slowUrl = "$baseUrl/api/orders/slow"
$optimizedUrl = "$baseUrl/api/orders/optimized"

$results = @()

function Invoke-BenchmarkRequest {
    param(
        [string]$Endpoint,
        [string]$Url,
        [int]$Run
    )

    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 180 | Out-Null

    $timer.Stop()

    $elapsed = [math]::Round($timer.Elapsed.TotalMilliseconds, 2)

    Write-Host "$Endpoint | Run $Run | $elapsed ms"

    return [PSCustomObject]@{
        Endpoint     = $Endpoint
        Run          = $Run
        Milliseconds = $elapsed
    }
}

function Get-Median {
    param([array]$Values)

    $sorted = @($Values | Sort-Object)
    $count = $sorted.Count

    if ($count % 2 -eq 0) {
        return ($sorted[$count / 2 - 1] + $sorted[$count / 2]) / 2
    }

    return $sorted[[math]::Floor($count / 2)]
}

# Warm-up
Write-Host "`nWarming up endpoints..." -ForegroundColor Cyan

Invoke-RestMethod -Uri $slowUrl -Method Get -TimeoutSec 180 | Out-Null
Invoke-RestMethod -Uri $optimizedUrl -Method Get -TimeoutSec 180 | Out-Null

# Alternate request order to reduce order bias
Write-Host "`nStarting benchmark..." -ForegroundColor Cyan

for ($i = 1; $i -le $runs; $i++) {

    if ($i % 2 -eq 1) {
        $results += Invoke-BenchmarkRequest "Slow" $slowUrl $i
        $results += Invoke-BenchmarkRequest "Optimized" $optimizedUrl $i
    }
    else {
        $results += Invoke-BenchmarkRequest "Optimized" $optimizedUrl $i
        $results += Invoke-BenchmarkRequest "Slow" $slowUrl $i
    }
}

# Export individual measurements
$results | Export-Csv -Path ".\benchmark-results.csv" -NoTypeInformation -Encoding UTF8

# Calculate summary
Write-Host "`n=== Benchmark Summary ===" -ForegroundColor Green

$summary = foreach ($endpoint in @("Slow", "Optimized")) {

    $times = @(
        $results |
        Where-Object { $_.Endpoint -eq $endpoint } |
        Select-Object -ExpandProperty Milliseconds
    )

    [PSCustomObject]@{
        Endpoint = $endpoint
        Average  = [math]::Round(($times | Measure-Object -Average).Average, 2)
        Median   = [math]::Round((Get-Median $times), 2)
        Minimum  = ($times | Measure-Object -Minimum).Minimum
        Maximum  = ($times | Measure-Object -Maximum).Maximum
    }
}

$summary | Format-Table -AutoSize

Write-Host "`nDetailed results saved to benchmark-results.csv" -ForegroundColor Green
