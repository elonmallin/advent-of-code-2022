$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$data = $data | ForEach-Object { ,($_.ToCharArray() | ForEach-Object { [int]$_ }) }

function Build-Graph {
    param (
        $Data
    )

    $graph = @{}
    $s = ""
    $e = ""

    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[$y].Count; $x++) {
            $graph["$x`:$y"] = @{ items=[System.Collections.Generic.List[hashtable]]@() }
            $dir = @(@(1,0),@(0,1),@(-1,0),@(0,-1))
            
            $h = $Data[$y][$x]
            if ($h -eq [int][char]'S') { $h = [int][char]'a'; $s = "$x`:$y" }
            if ($h -eq [int][char]'E') { $h = [int][char]'z'; $e = "$x`:$y" }

            foreach ($d in $dir) {
                $x2 = $x + $d[0]
                $y2 = $y + $d[1]

                if (Test-OutOfBounds -HeightMap $Data -X $x2 -Y $y2) {
                    continue
                }

                $h2 = $Data[$y2][$x2]
                if ($h2 -eq [int][char]'S') { $h2 = [int][char]'a' }
                if ($h2 -eq [int][char]'E') {
                    $h2 = [int][char]'z'
                }

                if (-not (Test-StepWithinReach -Height $h -NextHeight $h2)) {
                    continue
                }

                $graph["$x`:$y"].items.Add(@{Key="$x2`:$y2"; Weight=1})
            }
        }
    }

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
    
    return ($Height -ge $NextHeight -or $Height + 1 -ge $NextHeight)
}

$graph, $s, $e = Build-Graph -Data $data


function Dijkstra {
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

        foreach ($item in $Graph[$node].items) {
            $adjNode = $item.Key
            $weight = $item.Weight

            if ($visited.ContainsKey($adjNode)) {
                continue
            }

            $newCost = $nodeCosts[$node] + $weight
            if (-not $nodeCosts.ContainsKey($adjNode)) {
                $nodeCosts[$adjNode] = [int]::MaxValue
            }
            if ($nodeCosts[$adjNode] -gt $newCost) {
                $parentsMap[$adjNode] = $node
                $nodeCosts[$adjNode] = $newCost
                $pq.Enqueue($adjNode)
            }
        }
    }

    return $parentsMap, $nodeCosts
}

$par, $nc = Dijkstra -Graph $graph -Start $s
$k = $par[$e]
$i = 0
while ($k) {
    $i++
    $k = $par[$k]
    if ($k -eq $s) {
        break
    }
}

$i+1
