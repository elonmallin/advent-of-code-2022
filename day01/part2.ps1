$data = Get-Content -Path "$PSScriptRoot/input.txt" -Raw
$nl = "`n"
$elves = $data -split "$nl$nl"
$calorieSums = $elves | ForEach-Object { ($_ -split $nl | Measure-Object -Sum).Sum } | Sort-Object -Descending
($calorieSums[0..2] | Measure-Object -Sum).Sum
