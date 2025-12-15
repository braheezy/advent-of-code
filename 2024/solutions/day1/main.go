// https://adventofcode.com/2024/day/1
package main

import (
	"bufio"
	"embed"
	"math"
	"sort"
	"strconv"
	"strings"

	"github.com/braheezy/advent-of-code/solutions/utils"
)

//go:embed input.txt
var inputFile embed.FS

func part1(list1, list2 []int) int {
	sort.Ints(list1)
	sort.Ints(list2)

	sum := 0
	for i := range 1000 {
		sum += int(math.Abs(float64(list1[i]) - float64(list2[i])))
	}

	return sum
}

func part2(list1, list2 []int) int {
	map1 := make(map[int]int)
	for _, x := range list1 {
		map1[x]++
	}

	map2 := make(map[int]int)
	for _, x := range list2 {
		map2[x]++
	}

	similarity := 0
	for k1 := range map1 {
		if v2, ok := map2[k1]; ok {
			similarity += v2 * k1
		}
	}

	return similarity
}

func main() {
	file, err := inputFile.Open("input.txt")
	utils.Check(err)
	defer file.Close()

	var list1 = make([]int, 1000)
	var list2 = make([]int, 1000)
	scanner := bufio.NewScanner(file)

	i := 0
	for scanner.Scan() {
		words := strings.Fields(scanner.Text())
		list1[i], err = strconv.Atoi(words[0])
		utils.Check(err)
		list2[i], err = strconv.Atoi(words[1])
		utils.Check(err)
		i++
	}

	println("part 1 answer: ", part1(list1, list2))

	println("part 2 answer: ", part2(list1, list2))
}
