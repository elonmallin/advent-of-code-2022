$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$directionMap = @{ R=@(1,0); D=@(0,1); L=@(-1,0); U=@(0,-1) }
$head = @(0, 0)
$tail = @(0, 0)

foreach ($line in $data) {
    $d, $c = $line -split " "
    $d = $directionMap[$d]
    $c = [int][string]$c

    foreach ($_ in 1..$c) {
        $head[0] += $d[0]
        $head[1] += $d[1]
    }
}

$head
