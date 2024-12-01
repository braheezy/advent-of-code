# Advent of Code

My solutions to the [Advent of Code](https://adventofcode.com/2024/about) problems.

## Usage

In the spirit of AoC, the inputs that are unique to me are not stored in source control. That can be obtained like so:

```bash
./fetch_input.sh <day>
```

You'll need to provide your login session token (find in browser's cookies). When it works, a text file will be downloaded.

The solutions assume the input text files exist. They can be run directly:

```bash
go run solution/day1.go
```
