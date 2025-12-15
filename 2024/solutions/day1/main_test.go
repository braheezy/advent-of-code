package main

import "testing"

func TestDay1(t *testing.T) {
	list1 := []int{3, 4, 2, 1, 3, 3}
	list2 := []int{4, 3, 5, 3, 9, 3}

	result := part2(list1, list2)
	if result != 31 {
		t.Errorf("Expected 31, got %d", result)
	}

}
