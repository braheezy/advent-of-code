// https://adventofcode.com/2024/day/5
package main

import (
	"bufio"
	"embed"
	"fmt"
	"strconv"
	"strings"

	"github.com/braheezy/advent-of-code/solutions/utils"
)

//go:embed input.txt
var inputFile embed.FS

func main() {
	file, err := inputFile.Open("input.txt")
	utils.Check(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	rules := make([][2]string, 0)

	// Read the ordering rules
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			break
		}
		pages := strings.Split(line, "|")
		rules = append(rules, [2]string{pages[0], pages[1]})
	}

	total := 0
	for scanner.Scan() {
		line := scanner.Text()
		pages := strings.Split(line, ",")
		if !isCorrectOrder(pages, rules) {
			sortedPages := topologicalSort(pages, rules)
			// Find median page
			medianPage, _ := strconv.Atoi(sortedPages[len(sortedPages)/2])
			total += medianPage
		}
	}
	fmt.Printf("total: %v\n", total)
}

func isCorrectOrder(pages []string, rules [][2]string) bool {
	position := make(map[string]int)
	for idx, page := range pages {
		position[page] = idx
	}
	for _, rule := range rules {
		x, y := rule[0], rule[1]
		idxX, okX := position[x]
		idxY, okY := position[y]
		if okX && okY && idxX >= idxY {
			return false
		}
	}
	return true
}

func topologicalSort(pages []string, rules [][2]string) []string {
	// Build the graph
	pageSet := make(map[string]bool)
	for _, page := range pages {
		pageSet[page] = true
	}
	inDegree := make(map[string]int)
	graph := make(map[string][]string)
	for page := range pageSet {
		inDegree[page] = 0
		graph[page] = []string{}
	}
	for _, rule := range rules {
		x, y := rule[0], rule[1]
		if pageSet[x] && pageSet[y] {
			graph[x] = append(graph[x], y)
			inDegree[y]++
		}
	}

	// Perform topological sort
	result := []string{}
	queue := []string{}
	position := make(map[string]int)
	for idx, page := range pages {
		position[page] = idx
	}
	for page := range pageSet {
		if inDegree[page] == 0 {
			queue = append(queue, page)
		}
	}
	// Sort queue based on original position in reverse order
	queue = sortPages(queue, position, true)
	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]
		result = append(result, current)
		for _, neighbor := range graph[current] {
			inDegree[neighbor]--
			if inDegree[neighbor] == 0 {
				queue = append(queue, neighbor)
			}
		}
		queue = sortPages(queue, position, true)
	}
	return result
}

func sortPages(pages []string, position map[string]int, reverse bool) []string {
	sortedPages := make([]string, len(pages))
	copy(sortedPages, pages)
	if reverse {
		// Sort in reverse order
		for i := 0; i < len(sortedPages)-1; i++ {
			for j := i + 1; j < len(sortedPages); j++ {
				if position[sortedPages[i]] < position[sortedPages[j]] {
					sortedPages[i], sortedPages[j] = sortedPages[j], sortedPages[i]
				}
			}
		}
	} else {
		// Sort in original order
		for i := 0; i < len(sortedPages)-1; i++ {
			for j := i + 1; j < len(sortedPages); j++ {
				if position[sortedPages[i]] > position[sortedPages[j]] {
					sortedPages[i], sortedPages[j] = sortedPages[j], sortedPages[i]
				}
			}
		}
	}
	return sortedPages
}
