$data = Get-Content -Path "$PSScriptRoot/input.txt"

$directionMap = @{ R=@(1,0); D=@(0,1); L=@(-1,0); U=@(0,-1) }
$rope = 1..10 | ForEach-Object { ,@(0, 0) }
$tailVisits = @{}

function Format-Rope {
    param(
        $Rope
    )

    $x = $Rope | % { $_[0] } | measure -Minimum -Maximum
    $xMin = $x.Minimum
    $xMax = $x.Maximum
    $y = $Rope | % { $_[1] } | measure -Minimum -Maximum
    $yMin = $y.Minimum
    $yMax = $y.Maximum
    $xShift = 0
    $yShift = 0
    if ($xMin -lt 0) {
        $xMax += -$xMin
        $xShift = $xMin*-1
        $xMin = 0
    }
    if ($yMin -lt 0) {
        $yMax += -$yMin
        $yShift = $yMin*-1
        $yMin = 0
    }

    $grid = $yMin..$yMax | % { ,($xMin..$xMax | % {$s=@()}{$s+="."}{$s}) }
    for ($i = 0; $i -lt $Rope.Length; $i++) {
        $grid[$Rope[$i][1]+$yShift][$Rope[$i][0]+$xShift] = "$i"
    }

    $res = ($grid | % { $_ | % {$s=""}{ $s+=$_ }{$s} }) -join "`r`n"

    return $res
}

foreach ($line in $data) {
    $d, $c = $line -split " "
    $d = $directionMap[$d]
    $c = [int][string]$c

    foreach ($_ in 1..$c) {
        $rope[0][0] += $d[0]
        $rope[0][1] += $d[1]

        for ($i = 0; $i -lt $rope.Count-1; $i++) {
            $head = $rope[$i]
            $tail = $rope[$i+1]

            foreach ($adj in @(@(1,0), @(-1,0), @(0,1), @(0,-1))) {
                if ($adj[0] -ne 0 -and ($tail[0] + $adj[0] * 2) -eq $head[0]) {
                    $tail[0] += $adj[0]
                    if ($head[1] - $tail[1] -le -2) {
                        $tail[1] += -1
                    }
                    elseif ($head[1] - $tail[1] -ge 2) {
                        $tail[1] += 1
                    }
                    else {
                        $tail[1] = $head[1]
                    }
                    break
                }
                if ($adj[1] -ne 0 -and ($tail[1] + $adj[1] * 2) -eq $head[1]) {
                    if ($head[0] - $tail[0] -le -2) {
                        $tail[0] += -1
                    }
                    elseif ($head[0] - $tail[0] -ge 2) {
                        $tail[0] += 1
                    }
                    else {
                        $tail[0] = $head[0]
                    }
                    $tail[1] += $adj[1]
                    break
                }
            }
        }

        $tailVisits["$($rope[-1][0]):$($rope[-1][1])"] = $true
    }
}

$tailVisits.Keys.Count
