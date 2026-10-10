param(
	[string]$GodotPath = (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'),
	[int]$Port = 24568
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
$markerDir = Join-Path $env:TEMP "papoi-lobby-slots-$runId"
New-Item -ItemType Directory -Path $markerDir | Out-Null
$processes = [System.Collections.Generic.List[object]]::new()

function Start-LobbyProcess([string]$role, [string]$name) {
	$outFile = Join-Path $markerDir "$name.out.log"
	$errFile = Join-Path $markerDir "$name.err.log"
	$arguments = "--headless --path `"$projectPath`" --script res://tests/network/lobby_slots_test.gd -- $role $Port $name `"$markerDir`""
	$process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
	$processes.Add([pscustomobject]@{ Role = $role; Name = $name; Process = $process; Out = $outFile; Err = $errFile })
	return $process
}

function Wait-LobbyMarkers([string[]]$names, [int]$timeoutSeconds) {
	$deadline = [DateTime]::UtcNow.AddSeconds($timeoutSeconds)
	while ([DateTime]::UtcNow -lt $deadline) {
		$missing = @($names | Where-Object { -not (Test-Path -LiteralPath (Join-Path $markerDir "$($_).ok")) })
		if ($missing.Count -eq 0) {
			return
		}
		foreach ($entry in $processes) {
			$entry.Process.Refresh()
			if ($entry.Process.HasExited -and $entry.Role -ne 'member') {
				$expectedMarker = Join-Path $markerDir "$($entry.Name)-roster-six.ok"
				if (-not (Test-Path -LiteralPath $expectedMarker) -and $entry.Name -notin @('host', 'seventh')) {
					throw "Proceso $($entry.Name) terminó antes de completar el escenario (exit $($entry.Process.ExitCode))."
				}
			}
		}
		Start-Sleep -Milliseconds 100
	}
	throw "Timeout esperando estos marcadores: $($missing -join ', ')."
}

try {
	$hostProcess = Start-LobbyProcess 'host' 'host'
	Start-Sleep -Milliseconds 800
	if ($hostProcess.HasExited) {
		throw 'El host terminó antes de iniciar el escenario.'
	}

	$clientNames = @('drop', 'observer', 'member1', 'member2', 'member3')
	foreach ($name in $clientNames) {
		$role = 'member'
		if ($name -in @('drop', 'observer')) { $role = $name }
		[void](Start-LobbyProcess $role $name)
	}
	Wait-LobbyMarkers @('host-roster-six', 'drop-roster-six', 'observer-roster-six', 'member1-roster-six', 'member2-roster-six', 'member3-roster-six') 25

	$seventh = Start-LobbyProcess 'seventh' 'seventh'
	Wait-LobbyMarkers @('seventh-rejected') 12
	$seventh.Refresh()
	if (-not $seventh.HasExited -and -not $seventh.WaitForExit(3000)) {
		throw 'El proceso del séptimo jugador no cerró tras ser rechazado.'
	}

	Wait-LobbyMarkers @('drop-disconnected', 'host-roster-five', 'observer-roster-five') 15
	foreach ($name in @('host', 'drop', 'observer', 'seventh')) {
		$entry = $processes | Where-Object Name -eq $name | Select-Object -First 1
		if (-not $entry.Process.WaitForExit(5000)) {
			throw "El proceso $name no finalizó después de su resultado PASS."
		}
		$entry.Process.Refresh()
	}

	$errors = @()
	foreach ($entry in $processes) {
		$outText = if (Test-Path -LiteralPath $entry.Out) { Get-Content -LiteralPath $entry.Out -Raw } else { '' }
		$errText = if (Test-Path -LiteralPath $entry.Err) { Get-Content -LiteralPath $entry.Err -Raw } else { '' }
		Write-Output "--- $($entry.Name) ---`n$outText`n$errText"
		if ($errText -match 'LOBBY_SLOTS_TEST_FAIL|ERROR:|SCRIPT ERROR:') {
			$errors += $entry.Name
		}
	}
	if ($errors.Count -gt 0) {
		throw "Errores Godot/test en procesos: $($errors -join ', ')."
	}
	Write-Output 'LOBBY_SLOTS_TEST: PASS (host + 5 clientes, séptimo rechazado, desconexión y roster actualizado)'
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
