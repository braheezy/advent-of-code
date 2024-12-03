// https://adventofcode.com/2024/day/2
package main

import (
	"bufio"
	"embed"
	"fmt"
	"slices"
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

	scanner := bufio.NewScanner(file)

	numSafe := 0
	for scanner.Scan() {
		report := strings.Fields(scanner.Text())
		if reportIsSafe(report) {
			numSafe++
		}
	}

	println("part 1 answer: ", numSafe)
	file.Close()

	file, err = inputFile.Open("input.txt")
	utils.Check(err)
	scanner = bufio.NewScanner(file)

	numSafe = 0
	for scanner.Scan() {
		report := strings.Fields(scanner.Text())
		if reportIsSafe(report) {
			numSafe++
		} else {
			println("*******************")
			for i := 0; i < len(report); i++ {
				orignalReport := make([]string, len(report))
				copy(orignalReport, report)
				fmt.Printf("cutting report %v\n", orignalReport)
				newReport := slices.Delete(orignalReport, i, i+1)
				isSafe := reportIsSafe(newReport)
				fmt.Printf("new report %v is: %v\n", newReport, isSafe)
				if isSafe {
					numSafe++
					break
				}
			}
		}
	}

	println("part 2 answer: ", numSafe)
	file.Close()
}

func reportIsSafe(report []string) bool {
	isSafe := false
	currentChangeState := Unknown
	// toleranceHit := false
	for i := 0; i < len(report)-1; i++ {
		w1, _ := strconv.Atoi(report[i+1])
		w2, _ := strconv.Atoi(report[i])
		isSafe, currentChangeState = nextMoveSafe(w1, w2, currentChangeState)
		if !isSafe {
			break
		}
	}

	// fmt.Printf("%v is %v\n", report, isSafe)
	return isSafe
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

// func searchForSafeReport(oldReport, newReport []string) bool {
// 	for i := 0; i < len(oldReport); i++ {
// 		fmt.Printf("cutting report %v\n", oldReport)
// 		newReport := slices.Delete(oldReport, i, i+1)
// 		isSafe := reportIsSafe(newReport, false, Unknown)
// 		fmt.Printf("new report %v is: %v\n", newReport, isSafe)
// 		if isSafe {
// 			return true
// 		}
// 	}

// 	return false
// }
