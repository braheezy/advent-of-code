// https://adventofcode.com/2024/day/
package main

import (
	"bufio"
	"embed"
	"strconv"
	"strings"

	"github.com/braheezy/advent-of-code/solutions/utils"
)

//go:embed input.txt
var inputFile embed.FS

type ChangeState int

const (
	Unknown ChangeState = iota
	Increasing
	Decreasing
)

func main() {
	file, err := inputFile.Open("input.txt")
	utils.Check(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)

	numSafe := 0
	for scanner.Scan() {
		words := strings.Fields(scanner.Text())
		currentChangeState := Unknown
		isSafe := true
		for i := 0; i < len(words)-1; i++ {
			w1, _ := strconv.Atoi(words[i+1])
			w2, _ := strconv.Atoi(words[i])
			isSafe, currentChangeState = nextMoveSafe(w1, w2, currentChangeState)
			if !isSafe {
				break
			}
		}
		if isSafe {
			numSafe++
		}
	}

	println("answer: ", numSafe)
}

func nextMoveSafe(w1, w2 int, currentChangeState ChangeState) (bool, ChangeState) {
	if w1 == w2 {
		// must be changing by at least 1, unsafe!
		return false, currentChangeState
	} else if w2 < w1 {
		if currentChangeState == Unknown {
			currentChangeState = Increasing
		} else if currentChangeState == Decreasing {
			// Must only increase or decrease, unsafe!
			return false, currentChangeState
		}
		if w1-w2 <= 3 {
			return true, currentChangeState
		} else {
			// must change by at most 3, unsafe!
			return false, currentChangeState
		}
	} else {
		if currentChangeState == Unknown {
			currentChangeState = Decreasing
		} else if currentChangeState == Increasing {
			// Must only increase or decrease, unsafe!
			return false, currentChangeState
		}
		if w2-w1 <= 3 {
			return true, currentChangeState
		} else {
			// must change by at most 3, unsafe!
			return false, currentChangeState
		}
	}
}
