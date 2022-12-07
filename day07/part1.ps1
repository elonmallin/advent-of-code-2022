$data = Get-Content -Path "$PSScriptRoot/input.example.txt"

$directoryTree = @{}
$fullPath = "/"

foreach ($line in $data[2..($data.Length-1)]) {
    if ($line.StartsWith("`$ cd ")) {
        $cd = ($line -split "cd ")[1]
        if ($cd -eq "..") {
            $idx = $fullPath.LastIndexOf("/")
            $fullPath = $fullPath.Substring(0, $idx)
        }
        else {
            if ($fullPath -eq "/") {
                $fullPath += "$cd"
            }
            else {
                $fullPath += "/$cd"
            }
        }
    }
    elseif ($line -eq "`$ ls") {

    }
    else {
        if (-not $directoryTree.ContainsKey($fullPath)) {
            $directoryTree[$fullPath] = @()
        }

        $directoryTree[$fullPath] += $line
    }
}

$directoryTree
