$data = Get-Content -Path "$PSScriptRoot/input.txt"

$signalStrength = 0
$cycleCount = 0
$x = 1
$instructions = @{}
$cycleCheckpoint = 20
$op = {
    if ($cycleCheckpoint -eq $cycleCount) {
        $cycleCheckpoint += 40
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
