$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Test-FullyContains {
    param($A, $B)

    [int]$aMin, [int]$aMax = $A -split "-"
    [int]$bMin, [int]$bMax = $B -split "-"

    if ($aMin -ge $bMin -and $aMax -le $bMax) {
        return $true
    }
    if ($bMin -ge $aMin -and $bMax -le $aMax) {
        return $true
    }

    return $false
}

$redundantCleaningCount = 0
foreach ($row in $data) {
    $a, $b = $row -split ","

    if (Test-FullyContains -A $a -B $b) {
        $redundantCleaningCount += 1
    }
}

$redundantCleaningCount
