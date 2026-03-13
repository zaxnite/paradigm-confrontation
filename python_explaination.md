# Binary Search in Python — Code Explanation
**BCS 222 | Programming Paradigms**

---

## Overview

This document explains the Python implementation of Binary Search using a purely iterative, imperative approach. Every design decision reflects the imperative paradigm: explicit state management through mutable variables, manual index tracking, and loop-driven control flow.

---

## How Binary Search Works

Binary Search operates on a **sorted array**. At each step, it compares the target value to the element at the middle index of the current search range:

- If the middle element **equals** the target → return the index.
- If the middle element is **less than** the target → the target must be in the **right half**; discard the left.
- If the middle element is **greater than** the target → the target must be in the **left half**; discard the right.
- If the search range is **empty** (low > high) → the target is not in the array; return `-1`.

This halving of the search space gives Binary Search its `O(log n)` time complexity.

---

## Code Walkthrough

### 1. Function Signature

```python
def binary_search(arr, target):
```

The function accepts two arguments: the sorted array to search through, and the target value to find. Unlike the functional approach, there is no need for additional boundary parameters — they are initialized as local variables inside the function body.

---

### 2. State Initialization

```python
low = 0
high = len(arr) - 1
```

Before the loop begins, two **mutable variables** are created to track the current search boundaries:

- `low` — the index of the leftmost element of the current search range, starting at `0`.
- `high` — the index of the rightmost element, starting at the last valid index (`length - 1`).

These variables represent the **state** of the search. In the imperative paradigm, state lives in named memory locations that are explicitly modified as the algorithm progresses. This is the fundamental difference from the functional approach, where state is passed as function arguments and never mutated.

---

### 3. The `while` Loop — Iteration as Control Flow

```python
while low <= high:
```

The loop continues as long as the search range is valid — i.e., `low` has not crossed `high`. This condition serves the same logical role as the base case in the recursive implementation: when `low > high`, the search space is exhausted.

Each iteration of the loop corresponds to one recursive call in the functional version. The key difference is that instead of creating a new stack frame, the loop simply updates `low` and `high` in place and repeats.

---

### 4. Midpoint Calculation

```python
mid = (low + high) // 2
```

On every iteration, the midpoint index is calculated using integer division. This gives the index of the element to compare against the target. The `//` operator ensures the result is always a whole number, avoiding floating-point indices.

Note that `mid` is reassigned on every loop iteration — it is a mutable variable whose value changes each cycle, reflecting the updated search boundaries.

---

### 5. The Three-Way Comparison

```python
if arr[mid] == target:
    return mid

elif arr[mid] < target:
    low = mid + 1

else:
    high = mid - 1
```

This block is the core decision logic, evaluated once per iteration:

| Condition | Meaning | Action |
|---|---|---|
| `arr[mid] == target` | Found the target | Return `mid` immediately |
| `arr[mid] < target` | Target is in the right half | Mutate `low` to `mid + 1` |
| `arr[mid] > target` | Target is in the left half | Mutate `high` to `mid - 1` |

The mutation of `low` and `high` is what drives the search forward. Each assignment narrows the search window by half, discarding the portion of the array that cannot contain the target. This direct in-place modification of variables is characteristic of the imperative paradigm.

---

### 6. Not Found — Return `-1`

```python
return -1
```

If the `while` loop exits naturally (i.e., `low > high` without ever finding the target), the function returns `-1` to signal that the element is not present. This line is only reached when the search space is fully exhausted.

---

### 7. Test Case

```python
numbers = [3, 7, 11, 18, 25, 31, 42, 56, 70]
target = 25
result = binary_search(numbers, target)

if result != -1:
    print("Element found at index:", result)
else:
    print("Element not found")
```

The array is a standard Python list of sorted integers. The test searches for `25`, which exists at index `4`. The result is checked against `-1` to determine whether the search succeeded.

---

## State Mutation — Step-by-Step Trace

Searching for `31` in `[3, 7, 11, 18, 25, 31, 42, 56, 70]`:

```
Initial:    low=0, high=8

Iteration 1:
  mid = (0+8)//2 = 4
  arr[4] = 25 < 31  →  low = mid + 1 = 5

Iteration 2:
  mid = (5+8)//2 = 6
  arr[6] = 42 > 31  →  high = mid - 1 = 5

Iteration 3:
  mid = (5+5)//2 = 5
  arr[5] = 31 == 31  →  return 5
```

Notice that `low` and `high` are **overwritten** on each iteration. There is no record of their previous values. This is in contrast to the recursive approach, where each call preserves its own copy of `low` and `high` on the stack.

---

## Memory Model

The iterative implementation is highly memory-efficient. At any point during execution, only a fixed set of variables exist in memory:

| Variable | Purpose |
|---|---|
| `arr` | Reference to the input array (not copied) |
| `target` | The value being searched for |
| `low` | Lower boundary of the current search range |
| `high` | Upper boundary of the current search range |
| `mid` | Index of the current midpoint |

This is **O(1) auxiliary space** — the memory usage does not grow with the size of the input. No additional stack frames are created; the same variables are reused across all iterations.

---

## Loop Termination — Formal Proof

For the loop to be guaranteed to terminate:

1. **Progress**: On every iteration where the target is not found, either `low` increases (`mid + 1`) or `high` decreases (`mid - 1`). The search range `(high - low)` strictly shrinks each cycle.

2. **Bound**: The range cannot shrink indefinitely — once `low > high`, the loop condition fails and execution exits.

This guarantees termination in at most `O(log n)` iterations.

---

## Rubric Compliance Summary

| Constraint | Status | Evidence |
|---|---|---|
| No built-in `.find()` or `.sort()` | ✅ Compliant | Core logic written manually with a `while` loop |
| Manual index management | ✅ Compliant | `low`, `high`, and `mid` tracked explicitly |
| Pure iteration | ✅ Compliant | No recursion; loop drives all control flow |
| Explicit loop termination | ✅ Compliant | `while low <= high` fails when range is exhausted |
| State management | ✅ Compliant | State held in mutable local variables, mutated in-place |