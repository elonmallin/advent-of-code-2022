$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$data = $data | ForEach-Object { ,($_.ToCharArray() | ForEach-Object { [int]$_ }) }

function New-Graph {
    param (
        $Data
    )

    $graph = [ordered]@{}
    
    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[$y].Count; $x++) {
            $v = $Data[$y][$x]
            if ($Data[$y][$x] -eq [int][char]'S') {
                $graph["s"] = "$x`:$y"
                $v = [int][char]'a'
            }
            if ($Data[$y][$x] -eq [int][char]'E') {
                $graph["e"] = "$x`:$y"
                $v = [int][char]'z'
            }
            $graph["$x`:$y"] = [ordered]@{ value=$v; graph=[ordered]@{} }
        }
    }

    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[$y].Count; $x++) {
            $dir = @(@(1,0),@(0,1),@(-1,0),@(0,-1))
            foreach ($d in $dir) {
                $x2 = $x + $d[0]
                $y2 = $y + $d[1]
                if (Test-OutOfBounds -HeightMap $Data -X $x2 -Y $y2) {
                    continue
                }
                if (-not (Test-StepWithinReach -Height $graph["$x`:$y"].value -NextHeight $graph["$x2`:$y2"].value)) {
                    continue
                }

                $graph["$x`:$y"].graph["$x2`:$y2"] = $graph["$x2`:$y2"]
            }
        }
    }

    return $graph
}

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

$graph = New-Graph -Data $data
$graph

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
