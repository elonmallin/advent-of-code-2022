$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$sensorsAndBeacons = $data | % {
    $s, $b = $_ -split ":"
    $sx, $sy = ($s | Select-String -Pattern "x=(-?\d+), y=(-?\d+)").Matches.Groups.Value | Select-Object -Skip 1
    $bx, $by = ($b | Select-String -Pattern "x=(-?\d+), y=(-?\d+)").Matches.Groups.Value | Select-Object -Skip 1

    return ,@(@($sx, $sy), @($bx, $by))
}

function Get-MapRect {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Position=0)]$Map
    )
    
    $xs = $Map.Keys | % { ($_ -split ":")[0] | % { [int]$_ } } | Sort-Object
    $ys = $Map.Keys | % { ($_ -split ":")[1] | % { [int]$_ } } | Sort-Object
    $xMin, $xMax = $xs[0], $xs[-1]
    $yMin, $yMax = $ys[0], $ys[-1]

    return $xMin, $yMin, $xMax, $yMax
}

function Format-Map {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Position=0)]$Map
    )

    $xMin, $yMin, $xMax, $yMax = Get-MapRect $Map

    $formattedMap = ""
    for ($y = $yMin; $y -le $yMax; $y++) {
        for ($x = $xMin; $x -le $xMax; $x++) {
            $formattedMap += ($Map["$x`:$y"] ? $Map["$x`:$y"] : ".")
        }
        $formattedMap += "`n"
    }

    return $formattedMap
}

function Get-ManhattanDistance {
    param ($P1, $P2)
    
    return [Math]::Abs($P1[0]-$P2[0]) + [Math]::Abs($P1[1]-$P2[1])
}

function Write-MapData {
    param (
        $Map, $S, $B, $D
    )

    $Map["$($S[0])`:$($S[1])"] = "S"
    $Map["$($B[0])`:$($B[1])"] = "B"
    
    for ($i = 0; $i -lt (($D*2)+1); $i++) {
        $x = $S[0] - ($i -le $D ? $i : (($D*2) - $i))
        $y = $S[1] - ($D-$i)
        $fillCount = ($i -lt $D ? ($i + $i + 1) : (($D*2-$i) + ($D*2-$i) + 1))
        for ($j = 0; $j -lt $fillCount; $j++) {
            $x2 = $x + $j
            $k = "$x2`:$y"
            if (-not $Map[$k]) {
                $Map[$k] = "#"
            }
        }
    }
}

$map = @{}
foreach ($sb in $sensorsAndBeacons) {
    $s, $b = $sb
    $d = Get-ManhattanDistance $s $b
    Write-MapData $map $s $b $d
    # $map | Format-Map
}

$map | Format-Map > beacon.txt

($map.GetEnumerator() | Where-Object { ($_.Key -split ":")[1] -eq 10 -and $_.Value -eq "#" }).Count