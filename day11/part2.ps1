$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Get-Lcm {
    param (
        [int[]]$Numbers
    )
    
    $lcm = $Numbers[0]
    for ($i = 1; $i -lt $Numbers.Count; $i++) {
        $lcm = $lcm * $Numbers[$i] / [bigint]::GreatestCommonDivisor($lcm, $Numbers[$i])
    }

    return $lcm
}

$monkeys = @()

for ($i = 0; $i -lt $data.Length; $i++) {
    $monkey = @{}
    $monkeys += $monkey

    $monkey["items"] = [System.Collections.Generic.Queue[int]](($data[++$i] -split ": ")[1] -split ", " | ForEach-Object { [int]$_ })
    $monkey["operation"] = ($data[++$i] -split "= ")[1]
    $monkey["test"] = [int](($data[++$i] -split "by ")[1])
    $monkey["true"] = [int](($data[++$i] -split "monkey ")[1])
    $monkey["false"] = [int](($data[++$i] -split "monkey ")[1])
    $monkey["inspectionCount"] = 0

    ++$i
}

$lcm = Get-Lcm -Numbers $monkeys.test

foreach ($_ in 1..10000) {
    foreach ($monkey in $monkeys) {
        while ($monkey["items"].Count -gt 0) {
            $monkey["inspectionCount"] += 1
            $item = $monkey["items"].Dequeue()

            $expr = $monkey["operation"] -replace "old", "$item"
            $newItem = Invoke-Expression $expr

            $wl = $newItem % $lcm
            $throwTo = if ($wl % $monkey["test"] -eq 0) { $monkey["true"] } else { $monkey["false"] }
            $monkeys[$throwTo]["items"].Enqueue($wl)
        }
    }
}

$sortedInspectionCounts = $monkeys.inspectionCount | Sort-Object -Descending
$sortedInspectionCounts[0] * $sortedInspectionCounts[1]
