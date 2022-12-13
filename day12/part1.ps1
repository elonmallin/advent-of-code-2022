Import-Module Prelude
$data = Get-Content -Path "$PSScriptRoot/input.txt"

$data = $data | ForEach-Object { ,($_.ToCharArray() | ForEach-Object { [int]$_ }) }

function My-Graph {
    param (
        $Data
    )

    $graph = [ordered]@{}
    $s = ""
    $e = ""
    $nodes = @{}
    $edges = @()
    
    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[$y].Count; $x++) {
            $v = $Data[$y][$x]
            if ($Data[$y][$x] -eq [int][char]'S') {
                $s = "$x`:$y"
                $v = [int][char]'a'
            }
            if ($Data[$y][$x] -eq [int][char]'E') {
                $e = "$x`:$y"
                $v = [int][char]'z'
            }
            $graph["$x`:$y"] = [ordered]@{ value=$v; graph=[ordered]@{} }
            $nodes["$x`:$y"] = [Node]"$x`:$y"
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

                $edges += [Edge]::New($nodes["$x`:$y"], $nodes["$x2`:$y2"])
                $graph["$x`:$y"].graph["$x2`:$y2"] = $graph["$x2`:$y2"]
            }
        }
    }

    # $nodeList = @()
    # foreach ($n in $nodes.Keys) {
    #     $nodeList += $nodes[$n]
    # }
    # $myg = [Graph]::New($nodeList, $edges)
    # $myg.GetShortestPathLength($nodes[$s], $nodes[$e])

    return $graph, $s, $e
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

$graph, $s, $e = My-Graph -Data $data


function Djikstra {
    param (
        $Graph,
        $Start
    )
    
    $visited = @{}
    $parentsMap = @{}
    $pq = New-Object System.Collections.Generic.Queue[string]
    $nodeCosts = @{}
    $nodeCosts[$Start] = 0
    $pq.Enqueue($Start)

    while ($pq.Count -gt 0) {
        $node = $pq.Dequeue()
        $visited[$node] = $true

        foreach ($adjNode in $Graph[$node].graph.GetEnumerator()) {
            if ($visited.ContainsKey($adjNode.Key)) {
                continue
            }

            $newCost = $nodeCosts[$node]
            if (-not $nodeCosts.ContainsKey($adjNode.Key)) {
                $nodeCosts[$adjNode.Key] = [int]::MaxValue
            }
            if ($nodeCosts[$adjNode.Key] -gt $newCost) {
                $parentsMap[$adjNode.Key] = $node
                $nodeCosts[$adjNode.Key] = $newCost
                $pq.Enqueue($adjNode.Key)
            }
        }
    }

    return $parentsMap, $nodeCosts
}

$par, $nc = Djikstra -Graph $graph -Start $s
$k = $par[$e]
$i = 0
while ($k) {
    $i++
    $k = $par[$k]
    if ($k -eq $s) {
        break
    }
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
