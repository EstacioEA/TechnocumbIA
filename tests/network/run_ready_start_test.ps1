param(
	[string]$GodotPath = (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'),
	[int]$Port = 24569
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
$markerDir = Join-Path $env:TEMP "papoi-ready-start-$runId"
New-Item -ItemType Directory -Path $markerDir | Out-Null
$processes = [System.Collections.Generic.List[object]]::new()

function Start-ReadyStartProcess([string]$role, [string]$name) {
	$outFile = Join-Path $markerDir "$name.out.log"
	$errFile = Join-Path $markerDir "$name.err.log"
	$arguments = "--headless --path `"$projectPath`" --script res://tests/network/ready_start_test.gd -- $role $Port $name `"$markerDir`""
	$process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
	$processes.Add([pscustomobject]@{ Role = $role; Name = $name; Process = $process; Out = $outFile; Err = $errFile })
	return $process
}

function Wait-ReadyStartMarkers([string[]]$names, [int]$timeoutSeconds) {
	$deadline = [DateTime]::UtcNow.AddSeconds($timeoutSeconds)
	while ([DateTime]::UtcNow -lt $deadline) {
		$missing = @($names | Where-Object { -not (Test-Path -LiteralPath (Join-Path $markerDir "$($_).ok")) })
		if ($missing.Count -eq 0) { return }
		foreach ($entry in $processes) {
			$entry.Process.Refresh()
			if ($entry.Process.HasExited) {
				$marker = if ($entry.Role -eq 'host') { 'host-game-started' } else { "$($entry.Name)-game-started" }
				if (-not (Test-Path -LiteralPath (Join-Path $markerDir "$marker.ok"))) {
					throw "Proceso $($entry.Name) terminó antes de confirmar la sesión de juego (exit $($entry.Process.ExitCode))."
				}
			}
		}
		Start-Sleep -Milliseconds 100
	}
	throw "Timeout esperando estos marcadores: $($missing -join ', ')."
}

try {
	$hostProcess = Start-ReadyStartProcess 'host' 'host'
	Start-Sleep -Milliseconds 800
	if ($hostProcess.HasExited) { throw 'El host terminó antes de iniciar el escenario.' }

	$clientNames = @('client1', 'client2', 'client3', 'client4', 'client5')
	foreach ($name in $clientNames) { [void](Start-ReadyStartProcess 'client' $name) }

	$earlyMarkers = @('host-five-start-blocked', 'host-unready-start-blocked', 'host-ready-set')
	foreach ($name in $clientNames) {
		$earlyMarkers += "$name-client-start-blocked"
		$earlyMarkers += "$name-ready-requested"
	}
	Wait-ReadyStartMarkers $earlyMarkers 25

	$startMarkers = @('host-start-received')
	foreach ($name in $clientNames) { $startMarkers += "$name-lobby-start-received" }
	Wait-ReadyStartMarkers $startMarkers 15

	$gameMarkers = @('host-game-started')
	foreach ($name in $clientNames) { $gameMarkers += "$name-game-started" }
	Wait-ReadyStartMarkers $gameMarkers 15

	# Close clients one at a time so the authoritative host can process each
	# disconnect before the next peer closes its ENet transport.
	foreach ($name in $clientNames) {
		New-Item -ItemType File -Path (Join-Path $markerDir "shutdown-$name.signal") | Out-Null
		$entry = $processes | Where-Object { $_.Name -eq $name }
		if (-not $entry.Process.WaitForExit(5000)) {
			throw "El cliente $name no finalizó tras la señal de cierre ordenado."
		}
		if ($entry.Process.ExitCode -ne 0) { throw "El cliente $name terminó con código $($entry.Process.ExitCode)." }
		Start-Sleep -Milliseconds 250
	}
	New-Item -ItemType File -Path (Join-Path $markerDir 'shutdown-host.signal') | Out-Null
	if (-not $hostProcess.WaitForExit(5000)) { throw 'El host no finalizó tras la señal de cierre ordenado.' }
	if ($hostProcess.ExitCode -ne 0) { throw "El host terminó con código $($hostProcess.ExitCode)." }

	$errors = @()
	foreach ($entry in $processes) {
		$outText = if (Test-Path -LiteralPath $entry.Out) { Get-Content -LiteralPath $entry.Out -Raw } else { '' }
		$errText = if (Test-Path -LiteralPath $entry.Err) { Get-Content -LiteralPath $entry.Err -Raw } else { '' }
		Write-Output "--- $($entry.Name) ---`n$outText`n$errText"
		if ($errText -match 'READY_START_TEST_FAIL|ERROR:|SCRIPT ERROR:') { $errors += $entry.Name }
	}
	if ($errors.Count -gt 0) { throw "Errores Godot/test en procesos: $($errors -join ', ')." }
	Write-Output 'READY_START_TEST: PASS (bloqueos host/cliente, seis ready, lobby_start y snapshot inicial recibido por los seis procesos; cierre ordenado)'
}
catch {
	foreach ($entry in $processes) {
		foreach ($log in @($entry.Out, $entry.Err)) {
			if (Test-Path -LiteralPath $log) {
				Write-Output "--- $($entry.Name): $log ---"
				Get-Content -LiteralPath $log
			}
		}
	}
	throw
}
finally {
	foreach ($entry in $processes) {
		$entry.Process.Refresh()
		if (-not $entry.Process.HasExited) {
			try {
				$entry.Process.Kill()
				$entry.Process.WaitForExit()
			} catch {
				$entry.Process.Refresh()
				if (-not $entry.Process.HasExited) { throw }
			}
		}
	}
	if (Test-Path -LiteralPath $markerDir) {
		$tempRoot = (Resolve-Path -LiteralPath $env:TEMP).Path.TrimEnd('\') + '\'
		$resolvedMarkerDir = (Resolve-Path -LiteralPath $markerDir).Path
		if ($resolvedMarkerDir.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
			Remove-Item -LiteralPath $resolvedMarkerDir -Recurse -Force -ErrorAction SilentlyContinue
		}
	}
}
