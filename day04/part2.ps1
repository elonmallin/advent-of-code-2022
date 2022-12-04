$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Test-Overlap {
    param($A, $B)

    [int]$aMin, [int]$aMax = $A -split "-"
    [int]$bMin, [int]$bMax = $B -split "-"

    if ($aMax -lt $bMin -or $aMin -gt $bMax) {
        return $false
    }

    return $true
}

$redundantCleaningCount = 0
foreach ($row in $data) {
    $a, $b = $row -split ","

    if (Test-Overlap -A $a -B $b) {
        $redundantCleaningCount += 1
    }
}

$redundantCleaningCount
