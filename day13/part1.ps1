$data = Get-Content -Path "$PSScriptRoot/input.txt" -Raw

$pairs = $data -split "`r?`n`r?`n" | % { ,($_ -split "`r?`n") }

function Test-Order {
    param ($l, $r)
    
    if ($l -is [array] -and $r -is [array]) {
        $i = 0
        while ($i -lt $l.Count -and $i -lt $r.Count) {
            $c = Test-Order $l[$i] $r[$i]
            if ($c -eq 1) {
                return 1
            }
            elseif ($c -eq -1) {
                return -1
            }
            $i++
        }

        if ($i -eq $l.Count -and $i -lt $r.Count) {
            return -1
        }
        elseif ($i -eq $r.Count -and $i -lt $l.Count) {
            return 1
        }

        return 0
    }
    elseif ($l -is [int64] -and $r -is [int64]) {
        return $l -eq $r ? 0 : ($l -lt $r ? -1 : 1)
    }

    return Test-Order ($l -is [int64] ? ,$l : $l) ($r -is [int64] ? ,$r : $r) 0 0
}

$i = 0
$sum = 0
foreach ($pair in $pairs) {
    $i++
    $l, $r = $pair[0], $pair[1] | % { $_ -replace "`r?`n", "" | ConvertFrom-Json -NoEnumerate }

    if ((Test-Order $l $r) -eq -1) {
        $sum += $i
    }
}

$sum
