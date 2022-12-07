$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Get-FolderSize {
    param(
        [string]$Key,
        [hashtable]$Mem,
        [string[]]$Lines
    )

    for ($i = 0; $i -lt $Lines.Length; $i += 1) {
        $line = $Lines[$i]

        if ($line.StartsWith("`$ cd ")) {
            $Key = ($line -split "cd ")[1]

            if ($Key -eq "..") {
                return $Lines[($i+1)..($Lines.Length-1)]
            }

            if (-not $Mem.ContainsKey($Key)) {
                $Mem[$Key] = @{ Size=0 }
            }
        }
        elseif ($line -eq "`$ ls") {
            $Lines = Get-FolderSize -Key $Key -Mem $Mem[$Key] -Lines $Lines[($i+1)..($Lines.Length-1)]
            $Mem.Size += $Mem[$Key].Size
            $i = -1
        }
        elseif (-not $line.StartsWith("dir")) {
            $size = [int](($line -split " ")[0])

            $Mem.Size += $size
        }
    }

    return @()
}

function Get-Sizes {
    param (
        [hashtable]$Mem,
        [int[]]$Sizes
    )

    foreach ($key in $Mem.Keys | Where-Object { $_ -ne "Size" }) {
        $Sizes += $Mem[$key].Size
        $Sizes = Get-Sizes -Mem $Mem[$key] -Sizes $Sizes
    }

    return $Sizes
}

$mem = @{}
Get-FolderSize -Key "" -Mem $mem -Lines $data

$deleteSize = 30000000 - (70000000 - $mem.Size)

Get-Sizes -Mem $mem -Sizes @() |
    Where-Object { $_ -ge $deleteSize } |
    Sort-Object |
    Select-Object -First 1
