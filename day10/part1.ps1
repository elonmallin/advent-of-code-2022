$data = Get-Content -Path "$PSScriptRoot/input.txt"

$signalStrength = 0
$cycleCount = 0
$x = 1
$instructions = @{}
$cycleCheckpoints = 20, 60, 100, 140, 180, 220
$op = {
    if ($cycleCheckpoints.Contains($cycleCount)) {
        $signalStrength += $x * $cycleCount
    }

    if ($instructions.ContainsKey($cycleCount)) {
        $x += $instructions[$cycleCount]
    }

    $cycleCount += 1
}

foreach ($line in $data) {
    . $op

    if ($line -ne "noop") {
        [int]$addX = ($line -split " ")[1]
        $instructions[$cycleCount+1] = $addX
        
        . $op
    }
}

$signalStrength
