$data = Get-Content -Path "$PSScriptRoot/input.txt"

$items = New-Object System.Collections.Generic.List[int]
foreach ($rucksack in $data) {
    $l, $h = $rucksack.Length, ($rucksack.Length / 2)
    $compartment1, $compartment2 = $rucksack[0..($h-1)], $rucksack[$h..$l]
    $typeInBoth = ($compartment1 | Compare-Object -ReferenceObject $compartment2 -IncludeEqual -ExcludeDifferent).InputObject | Select-Object -Unique

    $adjust = ([int]([char]"A") - 27)
    if ([int]([char]$typeInBoth) -ge [int]([char]"a")) {
        $adjust = [int]([char]"a") - 1
    }

    $prio = [int]([char]$typeInBoth) - $adjust

    $items.Add($prio)
}

($items | Measure-Object -Sum).Sum
