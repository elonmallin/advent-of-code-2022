$data = Get-Content -Path "$PSScriptRoot/input.txt"

$data = $data | ForEach-Object { ,($_.ToCharArray() | ForEach-Object { [int]$_ }) }

function Test-OutOfBounds {
    param (
        $HeightMap,
        [int]$X,
        [int]$Y
    )
    
    return ($X -lt 0 -or $Y -lt 0 -or $Y -ge $HeightMap.Count -or $X -ge $HeightMap[0].Count)
}

function Test-StepWithinReach {
    param (
        [int]$Height,
        [int]$NextHeight
    )

    if ($NextHeight -eq [int][char]'E') {
        $NextHeight = [int][char]'z'
    }
    
    return ($Height -eq $NextHeight -or $Height + 1 -eq $NextHeight)
}

function Get-ShortestPath {
    param(
        $HeightMap,
        [int]$X,
        [int]$Y,
        [hashtable]$Visited
    )

    $shortest = [int]::MaxValue

    $h = $HeightMap[$Y][$X]
    if ($h -eq [int][char]'S') {
        $h = [int][char]'a'
    }
    elseif ($h -eq [int][char]'E') {
        # $Visited["$X/$Y"] = $true

        return $Visited.Keys.Count
    }

    $dir = @(@(1,0),@(0,1),@(-1,0),@(0,-1))
    foreach ($d in $dir) {
        $x2 = $X + $d[0]
        $y2 = $Y + $d[1]
        if (Test-OutOfBounds -HeightMap $HeightMap -X $x2 -Y $y2) {
            continue
        }
        if ($Visited.ContainsKey("$x2/$y2")) {
            continue
        }

        $h2 = $HeightMap[$y2][$x2]
        if (-not (Test-StepWithinReach -Height $h -NextHeight $h2)) {
            continue
        }

        $vis2 = @{ "$x2/$y2"=$true }
        foreach ($v in $Visited.Keys) {
            $vis2[$v] = $true
        }
        
        $length = Get-ShortestPath -HeightMap $HeightMap -X $x2 -Y $y2 -Visited $vis2
        if ($length -lt $shortest) {
            $shortest = $length
        }
    }

    # $Visited["$x2/$y2"] = $true

    return $shortest
}

$visited = @{ "0/0"=$true }
(Get-ShortestPath -HeightMap $data -X 0 -Y 0 -Visited $visited) - 1
