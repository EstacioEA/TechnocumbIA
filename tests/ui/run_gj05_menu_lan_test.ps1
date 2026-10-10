param(
	[string]$GodotPath = (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'),
	[int]$Port = 24570
)

$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path -LiteralPath $GodotPath)) {
	throw "Godot was not found: $GodotPath"
}
if ($Port -lt 1 -or $Port -gt 65535) {
	throw 'Port must be between 1 and 65535.'
}

$runId = [guid]::NewGuid().ToString('N')
$markerDir = Join-Path $env:TEMP "papoi-gj05-menu-lan-$runId"
New-Item -ItemType Directory -Path $markerDir | Out-Null
$processes = [System.Collections.Generic.List[object]]::new()

function Start-MenuProcess([string]$role) {
	$outFile = Join-Path $markerDir "$role.out.log"
	$errFile = Join-Path $markerDir "$role.err.log"
	$arguments = "--headless --path `"$projectPath`" --script res://tests/ui/gj05_menu_lan_test.gd -- $role $Port `"$markerDir`""
	$process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
	$processes.Add([pscustomobject]@{ Role = $role; Process = $process; Out = $outFile; Err = $errFile })
	return $process
}

try {
	$hostProcess = Start-MenuProcess 'host'
	Start-Sleep -Milliseconds 700
	if ($hostProcess.HasExited) { throw 'Host process exited before lobby startup.' }
	$client = Start-MenuProcess 'client'
	$deadline = [DateTime]::UtcNow.AddSeconds(18)
	while ([DateTime]::UtcNow -lt $deadline) {
		$hostProcess.Refresh()
		$client.Refresh()
		$hostMarker = Test-Path -LiteralPath (Join-Path $markerDir 'host-menu-lobby-connected.ok')
		$clientMarker = Test-Path -LiteralPath (Join-Path $markerDir 'client-menu-lobby-connected.ok')
		if ($hostMarker -and $clientMarker) { break }
		if (($hostProcess.HasExited -and -not $hostMarker) -or ($client.HasExited -and -not $clientMarker)) {
			throw 'A menu flow process exited before reaching the two-player lobby.'
		}
		Start-Sleep -Milliseconds 100
	}
	if (-not (Test-Path -LiteralPath (Join-Path $markerDir 'host-menu-lobby-connected.ok')) -or -not (Test-Path -LiteralPath (Join-Path $markerDir 'client-menu-lobby-connected.ok'))) {
		throw 'Timed out waiting for both menu flow markers.'
	}
	foreach ($entry in $processes) {
		if (-not $entry.Process.WaitForExit(5000)) { throw "Process $($entry.Role) did not exit after PASS." }
		$outText = Get-Content -LiteralPath $entry.Out -Raw
		$errText = Get-Content -LiteralPath $entry.Err -Raw
		Write-Output "--- $($entry.Role) ---`n$outText`n$errText"
		if (($outText + $errText) -match 'GJ05_MENU_LAN_FAIL|SCRIPT ERROR:|ERROR:') {
			throw "Godot runtime/test error in $($entry.Role) process."
		}
	}
	Write-Output 'GJ05_MENU_LAN_TEST: PASS (host and client navigated from menu and shared a two-player LAN lobby)'
}
catch {
	foreach ($entry in $processes) {
		foreach ($log in @($entry.Out, $entry.Err)) {
			if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log }
		}
	}
	throw
}
finally {
	foreach ($entry in $processes) {
		$entry.Process.Refresh()
		if (-not $entry.Process.HasExited) {
			try { $entry.Process.Kill(); $entry.Process.WaitForExit() } catch { }
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
