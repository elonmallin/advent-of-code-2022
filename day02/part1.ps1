$data = Get-Content -Path "$PSScriptRoot/input.txt"
$points = @{R=1;P=2;S=3;Draw=3;Win=6;Loss=0}
$rpsMap = @{A="R";B="P";C="S";X="R";Y="P";Z="S";}
$winMap = @{
    RR=$points.R+$points.Draw; RP=$points.P+$points.Win; RS=$points.S+$points.Loss;
    PR=$points.R+$points.Loss; PP=$points.P+$points.Draw; PS=$points.S+$points.Win;
    SR=$points.R+$points.Win; SP=$points.P+$points.Loss; SS=$points.S+$points.Draw;
}

$totalScore = 0
foreach ($row in $data) {
    $strategyItem = $row -split " "
    $opponent = $rpsMap[$strategyItem[0]]
    $you = $rpsMap[$strategyItem[1]]
    $totalScore += $winMap["$opponent$you"]
}

$totalScore
