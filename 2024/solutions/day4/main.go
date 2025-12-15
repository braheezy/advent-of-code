package main

import (
	"bufio"
	"embed"
	"fmt"
	"log"
	"strings"
	"unicode"
)

//go:embed input.txt
var inputFile embed.FS

type Direction struct {
	dx, dy int
	name   string
}

var directions = []Direction{
	{1, 0, "Right"},
	{-1, 0, "Left"},
	{0, 1, "Down"},
	{0, -1, "Up"},
	{1, 1, "Diagonal Down-Right"},
	{-1, 1, "Diagonal Down-Left"},
	{1, -1, "Diagonal Up-Right"},
	{-1, -1, "Diagonal Up-Left"},
}

var diagonalDirections = []Direction{
	{1, 1, "Top-Left to Bottom-Right"},
	{-1, 1, "Top-Right to Bottom-Left"},
	{1, -1, "Bottom-Left to Top-Right"},
	{-1, -1, "Bottom-Right to Top-Left"},
}

func main() {
	data, err := inputFile.ReadFile("input.txt")
	if err != nil {
		log.Fatalf("Failed to read input file: %v", err)
	}

	grid := parseGrid(string(data))

	totalXMAS := countXMAS(grid, "XMAS")
	totalXCross := countXCrosses(grid, "MAS")

	fmt.Printf("Total 'XMAS' occurrences found: %d\n", totalXMAS)
	fmt.Printf("Total 'MAS' X-cross patterns found: %d\n", totalXCross)
}

func parseGrid(content string) [][]rune {
	var grid [][]rune
	scanner := bufio.NewScanner(strings.NewReader(content))
	for scanner.Scan() {
		line := scanner.Text()
		grid = append(grid, []rune(line))
	}
	if err := scanner.Err(); err != nil {
		log.Fatalf("Error reading grid: %v", err)
	}
	return grid
}

func countXMAS(grid [][]rune, word string) int {
	count := 0
	rows := len(grid)
	if rows == 0 {
		return count
	}
	cols := len(grid[0])
	wordRunes := []rune(word)
	wordLen := len(wordRunes)

	for y := 0; y < rows; y++ {
		for x := 0; x < cols; x++ {
			if unicode.ToUpper(grid[y][x]) == unicode.ToUpper(wordRunes[0]) {
				for _, dir := range directions {
					if searchWord(grid, x, y, dir, wordRunes, wordLen) {
						count++
					}
				}
			}
		}
	}
	return count
}

func searchWord(grid [][]rune, x, y int, dir Direction, wordRunes []rune, wordLen int) bool {
	rows := len(grid)
	cols := len(grid[0])

	for i := 0; i < wordLen; i++ {
		newX := x + dir.dx*i
		newY := y + dir.dy*i

		if newX < 0 || newX >= cols || newY < 0 || newY >= rows {
			return false
		}

		if unicode.ToUpper(grid[newY][newX]) != unicode.ToUpper(wordRunes[i]) {
			return false
		}
	}
	return true
}

func countXCrosses(grid [][]rune, word string) int {
	count := 0
	rows := len(grid)
	if rows == 0 {
		return count
	}
	cols := len(grid[0])
	wordRunes := []rune(word)
	wordLen := len(wordRunes)

	for y := 0; y < rows; y++ {
		for x := 0; x < cols; x++ {
			if unicode.ToUpper(grid[y][x]) == 'A' {
				matchingDirs := findMatchingDirections(grid, x, y, wordRunes, wordLen)
				count += countUniquePairs(len(matchingDirs))
			}
		}
	}
	return count
}

func findMatchingDirections(grid [][]rune, x, y int, wordRunes []rune, wordLen int) []int {
	matchingDirs := []int{}
	for idx, dir := range diagonalDirections {
		if isWordAtCenter(grid, x, y, dir, wordRunes, wordLen) {
			matchingDirs = append(matchingDirs, idx)
		}
	}
	return matchingDirs
}

func isWordAtCenter(grid [][]rune, x, y int, dir Direction, wordRunes []rune, wordLen int) bool {
	mid := wordLen / 2
	startX := x - dir.dx*mid
	startY := y - dir.dy*mid

	for i := 0; i < wordLen; i++ {
		newX := startX + dir.dx*i
		newY := startY + dir.dy*i

		if newX < 0 || newX >= len(grid[0]) || newY < 0 || newY >= len(grid) {
			return false
		}

		if unicode.ToUpper(grid[newY][newX]) != unicode.ToUpper(wordRunes[i]) {
			return false
		}
	}
	return true
}

func countUniquePairs(n int) int {
	if n < 2 {
		return 0
	}
	return n * (n - 1) / 2
}
