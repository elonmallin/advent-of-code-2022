$data = Get-Content -Path "$PSScriptRoot/input.txt"

[System.Collections.Generic.List[object]]$pairs = $data | Where-Object { $_ }
$pairs.Add("[[2]]")
$pairs.Add("[[6]]")
$pairs = $pairs | % { $_ | ConvertFrom-Json -NoEnumerate }

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

$pairs.Sort({
    param($a,$b)
    Test-Order $a $b
})

$res = 1
for ($i = 0; $i -lt $pairs.Count; $i++) {
    $json = ,$pairs[$i] | ConvertTo-Json -Compress -Depth 99
    if ($json -eq "[[2]]") {
        $res *= $i+1
    }
    if ($json -eq "[[6]]") {
        $res *= $i+1
    }
}

$res
