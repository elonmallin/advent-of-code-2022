$data = Get-Content -Path "$PSScriptRoot/input.txt"

$cycleCount = 0
$x = 1
$instructions = @{}
$cycleCheckpoint = 40
$cycleOp = {
    if ($cycleCheckpoint -eq $cycleCount) {
        $cycleCheckpoint += 40
    }

    if ($instructions.ContainsKey($cycleCount)) {
        $x += $instructions[$cycleCount]
    }

    $row = [Math]::Floor(($cycleCount)/40)
    [string]$image[$row] += (($x-1)..($x+1)).Contains($cycleCount%40) ? "#" : "."

    $cycleCount += 1
}
$image = 1..6 | % { ,@() }

foreach ($line in $data) {
    . $cycleOp

    if ($line -ne "noop") {
        [int]$addX = ($line -split " ")[1]
        $instructions[$cycleCount+1] = $addX
        
        . $cycleOp
    }
}

$image

. "$PSScriptRoot/ConvertTo-Letters.ps1"
ConvertTo-Letters -CrtInput $image
