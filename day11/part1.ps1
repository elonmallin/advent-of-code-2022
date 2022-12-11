$data = Get-Content -Path "$PSScriptRoot/input.txt"

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

foreach ($_ in 1..20) {
    foreach ($monkey in $monkeys) {
        while ($monkey["items"].Count -gt 0) {
            $monkey["inspectionCount"] += 1
            $item = $monkey["items"].Dequeue()
            $newItem = Invoke-Expression ($monkey["operation"] -replace "old", $item)
            $wl = [Math]::Floor($newItem / 3)
            $throwTo = if ($wl % $monkey["test"] -eq 0) { $monkey["true"] } else { $monkey["false"] }
            $monkeys[$throwTo]["items"].Enqueue($wl)
        }
    }
}

$sortedInspectionCounts = $monkeys.inspectionCount | Sort-Object -Descending
$sortedInspectionCounts[0] * $sortedInspectionCounts[1]
