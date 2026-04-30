function Invoke-Checked {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE"
    }
}

Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/01_load_unified_stage.sql }
Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/02_build_star.sql }
Invoke-Checked { docker compose exec -T trino trino --server http://localhost:8080 --file /sql/trino/03_build_reports.sql }
