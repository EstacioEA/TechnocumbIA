param(
	[string]$GodotPath = (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'),
	[int]$Port = 24567
)

$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path -LiteralPath $GodotPath)) {
	throw "No se encontró Godot: $GodotPath. Indica -GodotPath con la ruta del ejecutable Godot 4."
}
if ($Port -lt 1 -or $Port -gt 65535) {
	throw 'El puerto debe estar entre 1 y 65535.'
}

$runId = [guid]::NewGuid().ToString('N')
$hostOut = Join-Path $env:TEMP "papoi-lan-host-$runId.out.log"
$hostErr = Join-Path $env:TEMP "papoi-lan-host-$runId.err.log"
$clientOut = Join-Path $env:TEMP "papoi-lan-client-$runId.out.log"
$clientErr = Join-Path $env:TEMP "papoi-lan-client-$runId.err.log"
$hostProcess = $null
$clientProcess = $null

try {
	$hostArgs = "--headless --path `"$projectPath`" --script res://tests/network/lan_transport_test.gd -- host $Port"
	$hostProcess = Start-Process -FilePath $GodotPath -ArgumentList $hostArgs -WindowStyle Hidden -PassThru -RedirectStandardOutput $hostOut -RedirectStandardError $hostErr
	Start-Sleep -Milliseconds 800
	if ($hostProcess.HasExited) {
		throw "El proceso host terminó antes de aceptar clientes (exit $($hostProcess.ExitCode))."
	}

	$clientArgs = "--headless --path `"$projectPath`" --script res://tests/network/lan_transport_test.gd -- client $Port"
	$clientProcess = Start-Process -FilePath $GodotPath -ArgumentList $clientArgs -WindowStyle Hidden -PassThru -RedirectStandardOutput $clientOut -RedirectStandardError $clientErr
	if (-not $clientProcess.WaitForExit(15000)) {
		throw 'El proceso cliente superó el timeout de 15 segundos.'
	}
	if (-not $hostProcess.WaitForExit(15000)) {
		throw 'El proceso host no registró la conexión dentro de 15 segundos.'
	}
	$hostProcess.Refresh()
	$clientProcess.Refresh()

	$hostOutput = Get-Content -LiteralPath $hostOut -Raw
	$hostErrors = Get-Content -LiteralPath $hostErr -Raw
	$clientOutput = Get-Content -LiteralPath $clientOut -Raw
	$clientErrors = Get-Content -LiteralPath $clientErr -Raw
	Write-Output "--- HOST stdout ---`n$hostOutput`n--- HOST stderr ---`n$hostErrors"
	Write-Output "--- CLIENT stdout ---`n$clientOutput`n--- CLIENT stderr ---`n$clientErrors"

	if ($hostOutput -notmatch 'HOST_PEER_JOINED' -or $clientOutput -notmatch 'CLIENT_CONNECTED') {
		throw 'Los procesos no reportaron los eventos esperados de conexión.'
	}
	if ($hostErrors -match 'LAN_TRANSPORT_TEST_FAIL|ERROR:|SCRIPT ERROR:' -or $clientErrors -match 'LAN_TRANSPORT_TEST_FAIL|ERROR:|SCRIPT ERROR:') {
		throw 'Uno de los procesos Godot reportó un error; revisa los logs mostrados arriba.'
	}
	Write-Output 'LAN_TRANSPORT_TEST: PASS'
}
finally {
	foreach ($process in @($clientProcess, $hostProcess)) {
		if ($null -ne $process -and -not $process.HasExited) {
			$process.Kill()
			$process.WaitForExit()
		}
	}
	Remove-Item -LiteralPath @($hostOut, $hostErr, $clientOut, $clientErr) -ErrorAction SilentlyContinue
}
