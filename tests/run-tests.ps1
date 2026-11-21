param([string]$Godot = 'godot')

$ErrorActionPreference = 'Stop'
$engine = (Get-Command $Godot -CommandType Application).Source
$project = Split-Path -Parent $PSScriptRoot
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')
$qaRoot = Join-Path $tempRoot ('archer-qa-' + [Guid]::NewGuid().ToString('N'))
$priorAppData = $env:APPDATA
$priorQa = $env:ARCHER_QA_DIR
New-Item -ItemType Directory -Path $qaRoot | Out-Null
try {
    $env:APPDATA = $qaRoot
    $env:ARCHER_QA_DIR = $qaRoot
    foreach ($suite in 'save_recovery', 'act_rules', 'upgrade_map', 'first_steps_and_records', 'sentinel', 'narrative', 'prototype_smoke') {
        $env:APPDATA = Join-Path $qaRoot $suite
        New-Item -ItemType Directory -Path $env:APPDATA | Out-Null
        $log = Join-Path $qaRoot ($suite + '.log')
        & $engine --headless --path $project --log-file $log --fixed-fps 60 --script "res://tests/$suite.gd"
        if ($LASTEXITCODE -ne 0 -or (Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|ERROR:|FAIL:' -Quiet)) {
            throw "Falló $suite. Revisá la salida de Godot."
        }
    }
}
finally {
    $env:APPDATA = $priorAppData
    $env:ARCHER_QA_DIR = $priorQa
    $actual = (Resolve-Path -LiteralPath $qaRoot).Path
    if ([IO.Directory]::GetParent($actual).FullName -eq $tempRoot -and [IO.Path]::GetFileName($actual) -match '^archer-qa-[0-9a-f]{32}$') {
        Remove-Item -Recurse -Force -LiteralPath $actual
    }
}
