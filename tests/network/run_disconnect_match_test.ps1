param(
	[string]$GodotPath = (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'),
	[int]$Port = 24570
)

$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot executable not found: $GodotPath" }
if ($Port -lt 2 -or $Port -gt 65535) { throw 'Port must be between 2 and 65535 so the pre-match lobby scenario has a separate port.' }

$runId = [guid]::NewGuid().ToString('N')
$markerDir = Join-Path $env:TEMP "papoi-disconnect-match-$runId"
New-Item -ItemType Directory -Path $markerDir | Out-Null
$processes = [System.Collections.Generic.List[object]]::new()

function Start-DisconnectProcess([string]$role, [string]$name) {
	$outFile = Join-Path $markerDir "$name.out.log"
	$errFile = Join-Path $markerDir "$name.err.log"
	$arguments = "--headless --path `"$projectPath`" --script res://tests/network/disconnect_match_test.gd -- $role $Port $name `"$markerDir`""
	$process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
	$processes.Add([pscustomobject]@{ Name = $name; Process = $process; Out = $outFile; Err = $errFile })
	return $process
}

function Wait-DisconnectMarkers([string[]]$names, [int]$timeoutSeconds) {
	$deadline = [DateTime]::UtcNow.AddSeconds($timeoutSeconds)
	while ([DateTime]::UtcNow -lt $deadline) {
		$missing = @($names | Where-Object { -not (Test-Path -LiteralPath (Join-Path $markerDir "$($_).ok")) })
		if ($missing.Count -eq 0) { return }
		foreach ($entry in $processes) {
			$entry.Process.Refresh()
			if ($entry.Process.HasExited -and $entry.Name -ne 'client1') {
				$marker = if ($entry.Name -eq 'host') { 'host-connected-clients-confirmed' } else { "$($entry.Name)-match-invalidated" }
				if (-not (Test-Path -LiteralPath (Join-Path $markerDir "$marker.ok"))) {
					throw "Process $($entry.Name) exited before completing disconnect checks (exit $($entry.Process.ExitCode))."
				}
			}
		}
		Start-Sleep -Milliseconds 100
	}
	throw "Timed out waiting for markers: $($missing -join ', ')."
}

try {
	$preMatchRunner = Join-Path $PSScriptRoot 'run_lobby_slots_test.ps1'
	& $preMatchRunner -GodotPath $GodotPath -Port ($Port - 1)
	Write-Output 'PRE_MATCH_DISCONNECT_TEST: PASS (peer removed from lobby and roster updated)'

	$hostProcess = Start-DisconnectProcess 'host' 'host'
	Start-Sleep -Milliseconds 800
	if ($hostProcess.HasExited) { throw 'Host exited before the scenario started.' }
	foreach ($name in @('client1', 'client2', 'client3', 'client4', 'client5')) {
		[void](Start-DisconnectProcess 'client' $name)
	}

	$markers = @('host-roster-six', 'host-match-active', 'client1-disconnected-during-match', 'host-match-invalidated', 'host-connected-clients-confirmed')
	foreach ($name in @('client1', 'client2', 'client3', 'client4', 'client5')) {
		$markers += "$name-ready-requested"
		$markers += "$name-lobby-start"
	}
	foreach ($name in @('client2', 'client3', 'client4', 'client5')) { $markers += "$name-match-invalidated" }
	Wait-DisconnectMarkers $markers 30

	foreach ($entry in $processes) {
		if (-not $entry.Process.WaitForExit(5000)) { throw "Process $($entry.Name) did not exit after PASS markers." }
	}
	$errors = @()
	foreach ($entry in $processes) {
		$outText = if (Test-Path -LiteralPath $entry.Out) { Get-Content -LiteralPath $entry.Out -Raw } else { '' }
		$errText = if (Test-Path -LiteralPath $entry.Err) { Get-Content -LiteralPath $entry.Err -Raw } else { '' }
		Write-Output "--- $($entry.Name) ---`n$outText`n$errText"
		if ($errText -match 'DISCONNECT_TEST_FAIL|ERROR:|SCRIPT ERROR:') { $errors += $entry.Name }
	}
	if ($errors.Count -gt 0) { throw "Godot/test errors in: $($errors -join ', ')." }
	Write-Output 'DISCONNECT_MATCH_TEST: PASS (pre-match peer removed; active-match invalidation replicated to connected clients)'
}
catch {
	foreach ($entry in $processes) {
		foreach ($log in @($entry.Out, $entry.Err)) {
			if (Test-Path -LiteralPath $log) { Write-Output "--- $($entry.Name): $log ---"; Get-Content -LiteralPath $log }
		}
	}
	throw
}
finally {
	foreach ($entry in $processes) {
		$entry.Process.Refresh()
		if (-not $entry.Process.HasExited) {
			try { $entry.Process.Kill(); $entry.Process.WaitForExit() }
			catch { $entry.Process.Refresh(); if (-not $entry.Process.HasExited) { throw } }
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
