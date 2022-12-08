$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Test-TreeVisible {
    param(
        [int]$X,
        [int]$Y,
        [string[]]$Data,
        [int]$Height,
        [array[]]$Directions = @(@(1, 0), @(-1, 0), @(0, 1), @(0, -1))
    )

    if ($X -eq 0 -or $Y -eq 0 -or $X -eq ($Data.Length-1) -or $Y -eq ($Data.Length-1)) {
        return $true
    }

    foreach ($d in $Directions) {
        $x2 = $X+$d[0]
        $y2 = $Y+$d[1]

        if ($Height -gt ([int]([string]($Data[$y2][$x2])))) {
            if (Test-TreeVisible -X $x2 -Y $y2 -Data $Data -Height $Height -Directions @(,$d)) {
                return $true
            }
        }

    }

    return $false
}

$visibleTreeCount = 0
for ($y = 0; $y -lt $data.Length; $y++) {
    for ($x = 0; $x -lt $data[$y].Length; $x++) {
        if (Test-TreeVisible -X $x -Y $y -Data $data -Height ([int]([string]($data[$y][$x])))) {
            $visibleTreeCount += 1
        }
    }
}

$visibleTreeCount
