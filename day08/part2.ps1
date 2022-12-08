$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Get-TreeScore {
    param(
        [int]$X,
        [int]$Y,
        [string[]]$Data,
        [int]$Height,
        [array[]]$Directions = @(@(1, 0), @(-1, 0), @(0, 1), @(0, -1))
    )

    $scores = $Directions | ForEach-Object { $dir = @() } { $dir += 0 } { ,$dir }

    for ($i = 0; $i -lt $Directions.Length; $i++) {
        $d = $Directions[$i]
        $x2 = $X+$d[0]
        $y2 = $Y+$d[1]

        if ($x2 -lt 0 -or $y2 -lt 0 -or $x2 -gt ($Data.Length-1) -or $y2 -gt ($Data.Length-1)) {
            continue
        }

        $scores[$i] += 1
        if ($Height -gt ([int]([string]($Data[$y2][$x2])))) {
            $scores[$i] += Get-TreeScore -X $x2 -Y $y2 -Data $Data -Height $Height -Directions @(,$d)
        }
    }

    return $scores | ForEach-Object {$total=1} {$total *= $_} {$total}
}

$highestScore = 0
for ($y = 1; $y -lt $data.Length-1; $y++) {
    for ($x = 1; $x -lt $data[$y].Length-1; $x++) {
        $score = Get-TreeScore -X $x -Y $y -Data $data -Height ([int]([string]($data[$y][$x])))
        if ($score -gt $highestScore) {
            $highestScore = $score
        }
    }
}

$highestScore
