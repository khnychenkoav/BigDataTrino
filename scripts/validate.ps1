function Invoke-Checked {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE"
    }
}

Invoke-Checked { docker compose exec -T postgres psql -U lab -d trino_lab -c "select 'postgres_stage_raw' as object_name, count(*) as rows_count from stage.mock_data_raw;" }
Invoke-Checked { docker compose exec -T clickhouse clickhouse-client --user lab --password lab --queries-file /sql/validation/clickhouse.sql }
