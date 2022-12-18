$data = Get-Content -Path "$PSScriptRoot/input.txt"

$lines = $data | % { ,($_ -split " -> " | % { ,($_ -split "," | % { [int]$_ }) }) }

$cave = @{}

function Get-CaveRect {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Position=0)]$Cave
    )
    
    $xs = $Cave.Keys | % { ($_ -split ":")[0] | % { [int]$_ } } | Sort-Object
    $ys = $Cave.Keys | % { ($_ -split ":")[1] | % { [int]$_ } } | Sort-Object
    $xMin, $xMax = $xs[0], $xs[-1]
    $yMin, $yMax = $ys[0], $ys[-1]

    return $xMin, $yMin, $xMax, $yMax
}

function Format-Cave {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Position=0)]$Cave
    )

    $xMin, $yMin, $xMax, $yMax = Get-CaveRect $Cave

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

function Add-Sand {
    param (
        $Cave,
        $SpawnPoint,
        $CaveRect,
        $Moves = @(@(0,1),@(-1,1),@(1,1))
    )
    
    $xMin, $yMin, $xMax, $yMax = $CaveRect
    $p = $SpawnPoint
    do {
        foreach ($d in $Moves) {
            $x2, $y2 = ($p[0] + $d[0]), ($p[1] + $d[1])
            if ($x2 -lt $xMin -or $x2 -gt $xMax -or $y2 -gt $yMax) {
                return $false, @($x2,$y2)
            }
            if (-not $Cave["$x2`:$y2"]) {
                $p[0] = $x2
                $p[1] = $y2
                break
            }
        }
    } while ($p[0] -eq $x2 -and $p[1] -eq $y2)

    $Cave["$($p[0]):$($p[1])"] = "o"

    return $true, $p
}

foreach ($line in $lines) {
    $p = $line[0]
    foreach ($coord in $line[1..($line.Count-1)]) {
        Write-RockLine $cave $p $coord
        $p = $coord
    }
}

$caveRect = Get-CaveRect $Cave
do {
    $settled, $point = Add-Sand $Cave @(500,0) $caveRect
} while($settled)

$cave | Format-Cave

($cave.Values | Where-Object { $_ -eq "o" }).Count
