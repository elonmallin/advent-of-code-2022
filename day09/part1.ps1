$data = Get-Content -Path "$PSScriptRoot/input.txt"

$directionMap = @{ R=@(1,0); D=@(0,1); L=@(-1,0); U=@(0,-1) }
$head = @(0, 0)
$tail = @(0, 0)
$tailVisits = @{}

foreach ($line in $data) {
    $d, $c = $line -split " "
    $d = $directionMap[$d]
    $c = [int][string]$c

    foreach ($_ in 1..$c) {
        $head[0] += $d[0]
        $head[1] += $d[1]

        foreach ($adj in @(@(1,0), @(-1,0), @(0,1), @(0,-1))) {
            if ($adj[0] -ne 0 -and ($tail[0] + $adj[0] * 2) -eq $head[0]) {
                $tail[0] += $adj[0]
                $tail[1] = $head[1]
                break
            }
            if ($adj[1] -ne 0 -and ($tail[1] + $adj[1] * 2) -eq $head[1]) {
                $tail[0] = $head[0]
                $tail[1] += $adj[1]
                break
            }
        }

        $tailVisits["$($tail[0]):$($tail[1])"] = $true
    }
}

$tailVisits.Keys.Count
