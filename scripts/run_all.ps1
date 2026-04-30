function Invoke-Checked {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE"
    }
}

docker compose up -d postgres clickhouse trino

$containers = @(
    "bd_trino_postgres",
    "bd_trino_clickhouse",
    "bd_trino_engine"
)

$deadline = (Get-Date).AddMinutes(8)
do {
    $notReady = @()
    foreach ($container in $containers) {
        $health = docker inspect -f "{{.State.Health.Status}}" $container 2>$null
        if ($health -ne "healthy") {
            $notReady += "$container=$health"
        }
    }
    if ($notReady.Count -eq 0) {
        break
    }
    Write-Host ("Waiting for services: " + ($notReady -join ", "))
    Start-Sleep -Seconds 10
} while ((Get-Date) -lt $deadline)

if ($notReady.Count -ne 0) {
    docker compose ps
    throw "Some services did not become healthy in time"
}

Invoke-Checked { docker compose run --rm clickhouse-loader }
Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/01_load_unified_stage.sql }
Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/02_build_star.sql }
Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/03_build_reports.sql }
