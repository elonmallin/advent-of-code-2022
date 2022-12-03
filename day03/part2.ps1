$data = Get-Content -Path "$PSScriptRoot/input.txt"

$items = New-Object System.Collections.Generic.List[int]
for ($i = 0; $i -lt $data.Length; $i += 3) {
    $badge = ""

    $h2 = $data[$i+1].ToCharArray() | Select-Object -Unique | Group-Object -AsHashTable
    $h3 = $data[$i+2].ToCharArray() | Select-Object -Unique | Group-Object -AsHashTable
    foreach ($c in $data[$i].ToCharArray()) {
        if ($h2.ContainsKey($c) -and $h3.ContainsKey($c)) {
            $badge = $c
            break;
        }
    }

    $adjust = ([int]([char]"A") - 27)
    if ([int]([char]$badge) -ge [int]([char]"a")) {
        $adjust = [int]([char]"a") - 1
    }

    $prio = [int]([char]$badge) - $adjust

    $items.Add($prio)
}

($items | Measure-Object -Sum).Sum
