$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$sensorsAndBeacons = $data | % {
    $s, $b = $_ -split ":"
    $sx, $sy = ($s | Select-String -Pattern "x=(-?\d+), y=(-?\d+)").Matches.Groups.Value | Select-Object -Skip 1
    $bx, $by = ($b | Select-String -Pattern "x=(-?\d+), y=(-?\d+)").Matches.Groups.Value | Select-Object -Skip 1

    return ,@(@($sx, $sy), @($bx, $by))
}
$sensorsAndBeacons
