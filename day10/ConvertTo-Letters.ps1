$crtLetters = @"
.##..###...##..####.####..##..#..#.###....##.#..#.#.....##..###..###...###.#..#.#...#.####
#..#.#..#.#..#.#....#....#..#.#..#..#......#.#.#..#....#..#.#..#.#..#.#....#..#.#...#....#
#..#.###..#....###..###..#....####..#......#.##...#....#..#.#..#.#..#.#....#..#..#.#....#.
####.#..#.#....#....#....#.##.#..#..#......#.#.#..#....#..#.###..###...##..#..#...#....#..
#..#.#..#.#..#.#....#....#..#.#..#..#...#..#.#.#..#....#..#.#....#.#.....#.#..#...#...#...
#..#.###...##..####.#.....###.#..#.###...##..#..#.####..##..#....#..#.###...##....#...####
"@
$letters = "ABCEFGHIJKLOPRSUYZ"

function ConvertTo-Letters {
    param (
        $crtInput
    )

    $translated = ""
    
    $crtStartX = 0
    foreach ($crtIn in 1..($crtInput[0].Length/5)) {
        $letterStartX = 0
        foreach ($letter in $letters.ToCharArray()) {
            $found = $true
            for ($y = 0; $y -lt 6; $y++) {
                for ($x = 0; $x -lt 4; $x++) {
                    if ($crtInput[$y][$x+$crtStartX] -ne $crtLetters[($y*92)+($x+$letterStartX)]) {
                        $found = $false
                        break
                    }
                }
                if (-not $found) {
                    break
                }
            }
            
            $letterStartX += 5

            if ($found) {
                $translated += $letter
                break
            }
        }
        
        $crtStartX += 5
    }

    return $translated
}
