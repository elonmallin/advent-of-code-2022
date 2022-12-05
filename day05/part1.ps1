$data = Get-Content -Path "$PSScriptRoot/input.txt"

$stacks = 1..($data[0].Length / 4) | ForEach-Object { New-Object System.Collections.Generic.Stack[string] }

$doMoves = $false
foreach ($row in $data) {
    if (-not $row) {
        $doMoves = $true
        for ($i = 0; $i -lt $stacks.Count; $i +=1) {
            $stacks[$i] = New-Object System.Collections.Generic.Stack[string]($stacks[$i])
        }
        continue
    }

    if (-not $doMoves) {
        for ($i = 1; $i -lt $row.Length; $i += 4) {
            $c = $row[$i]
            if (-not ([string]::IsNullOrWhiteSpace($c)) -and -not ($c -match "^\d+$")) {
                $stacks[($i - 1) / 4].Push($c)
            }
        }
    }
    else {
        $moveCount, $from, $to = ($row | Select-String -Pattern "move (\d+) from (\d+) to (\d+)").Matches.Groups.Value | Select-Object -Skip 1

        foreach ($_ in 1..$moveCount) {
            $item = $stacks[[int]$from-1].Pop()
            $stacks[[int]$to-1].Push($item)
        }
    }
}

($stacks | ForEach-Object { $_.Pop() }) -join ""
