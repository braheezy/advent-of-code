// https://adventofcode.com/2024/day/2
package main

import (
	"bufio"
	"embed"
	"io"
	"log"
	"strconv"
	"unicode"

	"github.com/braheezy/advent-of-code/solutions/utils"
)

//go:embed input.txt
var inputFile embed.FS

type State int

const (
	Init State = iota
	LeftParen
	LeftOperand
	Comma
	RightOperand
	RightParen
)

func main() {
	file, err := inputFile.Open("input.txt")
	utils.Check(err)

	// var buf = make([]byte, 40)
	r := bufio.NewReader(file)
	state := Init
	var leftOp, rightOp int
	total := 0

	for {
		token, err := nextToken(r)
		if err == io.EOF {
			break
		}
		switch state {
		case Init:
			if token == 'm' {
				next, err := r.Peek(2)
				if err == io.EOF {
					break
				}
				if string(next) == "ul" {
					state = LeftParen
					// and consume
					r.ReadRune()
					r.ReadRune()
				}
			}
		case LeftParen:
			if token == '(' {
				state = LeftOperand
			} else {
				state = Init
				utils.Check(r.UnreadRune())
			}
		case LeftOperand:
			if unicode.IsDigit(token) {
				utils.Check(r.UnreadRune())
				leftOp, err = consumeDigits(r)
				if err == io.EOF {
					break
				}
				state = Comma
			} else {
				state = Init
				utils.Check(r.UnreadRune())
			}
		case Comma:
			if token == ',' {
				state = RightOperand
			} else {
				state = Init
				utils.Check(r.UnreadRune())
			}
		case RightOperand:
			if unicode.IsDigit(token) {
				utils.Check(r.UnreadRune())
				rightOp, err = consumeDigits(r)
				if err == io.EOF {
					break
				}
				state = RightParen
			} else {
				state = Init
				utils.Check(r.UnreadRune())
			}
		case RightParen:
			if token == ')' {
				total += leftOp * rightOp
				state = Init
			} else {
				state = Init
				utils.Check(r.UnreadRune())
			}
		}
	}
	println("answer: ", total)
}

func nextToken(r *bufio.Reader) (rune, error) {
	var token rune
	var err error
	if token, _, err = r.ReadRune(); err != nil {
		if err == io.EOF {
			return token, err
		} else {
			log.Fatal(err)
		}
	}

	return token, nil
}

func consumeDigits(r *bufio.Reader) (int, error) {
	result := ""
	for {
		token, err := nextToken(r)
		if err != nil {
			return 0, err
		}
		if unicode.IsDigit(token) {
			result += string(token)
		} else {
			utils.Check(r.UnreadRune())
			break
		}
	}
	return strconv.Atoi(result)
}
