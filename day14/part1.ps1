$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$lines = $data | % { ,($_ -split " -> " | % { ,($_ -split "," | % { [int]$_ }) }) }

$cave = @{}

function Format-Cave {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Position=0)]$Cave
    )
    
    $xs = $Cave.Keys | % { ($_ -split ":")[0] | % { [int]$_ } } | Sort-Object
    $ys = $Cave.Keys | % { ($_ -split ":")[1] | % { [int]$_ } } | Sort-Object
    $xMin, $xMax = $xs[0], $xs[-1]
    $yMin, $yMax = $ys[0], $ys[-1]

    $formattedCave = ""
    for ($y = $yMin; $y -le $yMax; $y++) {
        for ($x = $xMin; $x -le $xMax; $x++) {
            $formattedCave += ($Cave["$x`:$y"] ? $Cave["$x`:$y"] : ".")
        }
        $formattedCave += "`n"
    }

    return $formattedCave
}

function Write-RockLine {
    param ($Cave, $P1, $P2)
    
    $d = @(
        ($P1[0] -eq $P2[0] ? 0 : ($P2[0] -lt $P1[0] ? -1 : 1)),
        ($P1[1] -eq $P2[1] ? 0 : ($P2[1] -lt $P1[1] ? -1 : 1))
    )

    $p = @($P1[0], $P1[1])
    $Cave["$($p[0]):$($p[1])"] = "#"
    while ($p[0] -ne $P2[0] -or $p[1] -ne $P2[1]) {
        $p[0] += $d[0]
        $p[1] += $d[1]
        $Cave["$($p[0]):$($p[1])"] = "#"
    }
}

foreach ($line in $lines) {
    $p = $line[0]
    foreach ($coord in $line[1..($line.Count-1)]) {
        Write-RockLine $cave $p $coord
        $p = $coord
    }
}

$cave | Format-Cave
