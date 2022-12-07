$data = Get-Content -Path "$PSScriptRoot/input.txt"

function Resolve-Tree {
    param(
        [hashtable]$Tree,
        [string[]]$Lines
    )

    for ($i = 0; $i -lt $Lines.Length; $i += 1) {
        $line = $Lines[$i]

        if ($line.StartsWith("`$ cd ")) {
            $key = ($line -split "cd ")[1]

            if ($key -eq "..") {
                return $Lines[($i+1)..($Lines.Length-1)]
            }

            if (-not $Tree.ContainsKey($key)) {
                $Tree[$key] = @{ Size=0 }
            }
        }
        elseif ($line -eq "`$ ls") {
            $Lines = Resolve-Tree -Key $key -Tree $Tree[$key] -Lines $Lines[($i+1)..($Lines.Length-1)]
            $Tree.Size += $Tree[$key].Size
            $i = -1
        }
        elseif (-not $line.StartsWith("dir")) {
            $Tree.Size += [int](($line -split " ")[0])
        }
    }

    return @()
}

function Get-Sizes {
    param (
        [hashtable]$Tree
    )
    
    $Size = 0

    foreach ($key in $Tree.Keys | Where-Object { $_ -ne "Size" }) {
        if ($Tree[$key].Size -lt 100000) {
            $Size += $Tree[$key].Size
        }
        $Size += Get-Sizes -Tree $Tree[$key]
    }

    return $Size
}

$tree = @{}
Resolve-Tree -Tree $tree -Lines $data

Get-Sizes -Tree $tree
