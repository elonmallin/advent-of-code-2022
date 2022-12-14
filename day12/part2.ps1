$data = Get-Content -Path "$PSScriptRoot/input.txt"
$data = $data | % { ,($_.ToCharArray() | % { [int]$_ }) }

function Build-Graph {
    param (
        $Data
    )

    function Test-OutOfBounds {
        param ($HeightMap, [int]$X, [int]$Y)
        return ($X -lt 0 -or $Y -lt 0 -or $Y -ge $HeightMap.Count -or $X -ge $HeightMap[0].Count)
    }
    function Test-StepWithinReach {
        param ([int]$Height, [int]$NextHeight)
        return ($Height -ge $NextHeight -or $Height + 1 -ge $NextHeight)
    }
    $tryReplace = {param($data,$x,$y,$c)
        if ($data[$y][$x] -eq [int][char]$c) {
            $data[$y][$x] = @{S=[int][char]'a';E=[int][char]'z'}[$c]
            return $true
        }
        return $false
    }

    $graph = @{}
    $start, $end = "", ""

    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[$y].Count; $x++) {

            if (&$tryReplace $Data $x $y 'S') { $start = "$x`:$y" }
            if (&$tryReplace $Data $x $y 'E') { $end = "$x`:$y" }

            $graph["$x`:$y"] = @{
                height=$Data[$y][$x];
                items=[System.Collections.Generic.List[hashtable]]@()
            }
            
            foreach ($d in @(@(1,0),@(0,1),@(-1,0),@(0,-1))) {
                $x2, $y2 = ($x + $d[0]), ($y + $d[1])

                if (Test-OutOfBounds -HeightMap $Data -X $x2 -Y $y2) {
                    continue
                }

                if (&$tryReplace $Data $x2 $y2 'S') { $start = "$x2`:$y2" }
                if (&$tryReplace $Data $x2 $y2 'E') { $end = "$x2`:$y2" }
                if (-not (Test-StepWithinReach -Height $Data[$y][$x] -NextHeight $Data[$y2][$x2])) {
                    continue
                }

                $graph["$x`:$y"].items.Add(@{Key="$x2`:$y2"; Weight=1})
            }
        }
    }

    return $graph, $start, $end
}

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

    return $parentsMap
}

$graph, $start, $end = Build-Graph -Data $data
$starts = $graph.Keys | Where-Object { $graph[$_].height -eq [int][char]'a' }

$shortestCount = [int]::MaxValue
foreach ($s in $starts) {
    $map = Dijkstra -Graph $graph -Start $s
    $k = $end
    $i = 0

    do {
        $i++
        $k = $map[$k]
    }
    while ($k -and $k -ne $s)

    if ($shortestCount -gt $i -and $i -gt 1) {
        $shortestCount = $i
    }
}

$shortestCount
