$data = Get-Content -Path "$PSScriptRoot/input.example.txt" -Raw

$pairs = $data -split "`r?`n`r?`n" | % { ,($_ -split "`r?`n") }

$compareAtIdx = {param($a,$b,$i)$a[$i] -lt $b[$i]}

function Test-Order {
    param (
        $l,
        $r,
        $li,
        $ri
    )
    
    if ($l[$li] -is [int] -and $r[$ri] -is [int] -and $l[$li] -gt $r[$ri]) {
        return $false # int, left is higher than right
    }


    return $true
}

$rightOrderCount = 0
foreach ($pair in $pairs) {
    $l, $r = $pair | % { ,(Invoke-Expression (($_ -replace "\[", "@(") -replace "\]", ")")) }

    $j = 0
    for ($i = 0; $i -lt $l.Count; $i++) {
        if ($l[$i] -is [int] -and $r[$j] -is [int] -and $l[$i] -gt $r[$j]) {
            break # int, left is higher than right
        }
    }
}