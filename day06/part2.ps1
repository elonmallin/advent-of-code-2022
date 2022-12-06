$data = Get-Content -Path "$PSScriptRoot/input.txt" -Raw

$answer = 0
$part = $data[0..13]

for ($i = 14; $i -lt $data.Length; $i++) {
    $c = $data[$i]

    if ($part.Length -eq ($part | Select-Object -Unique).Length) {
        $answer = $i
        break
    }

    $part = $part[1..13] + $c
}

$answer
