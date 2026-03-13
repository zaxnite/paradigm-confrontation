# Binary Search in Common Lisp — Code Explanation
**BCS 222 | Programming Paradigms**

---

## Overview

This document explains the Common Lisp implementation of Binary Search using a purely functional, recursive approach. Every design decision is driven by the constraints of the functional paradigm: no mutation, no loops, and no shared state.

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

### 1. `array-length`

```lisp
(defun array-length (arr)
  (length arr))
```

A simple helper that wraps Lisp's built-in `length` function. It returns the number of elements in the array. This is used by the public entry point to calculate the initial `high` index.

---

### 2. `binary-search-recursive` — The Core Logic

```lisp
(defun binary-search-recursive (arr target low high)
  (if (> low high)
      -1
      (let* ((mid     (floor (+ low high) 2))
             (mid-val (aref arr mid)))
        (cond
          ((= mid-val target) mid)
          ((< mid-val target)
           (binary-search-recursive arr target (+ mid 1) high))
          (t
           (binary-search-recursive arr target low (- mid 1)))))))
```

This function takes four arguments: the array, the target value, and the current search boundaries `low` and `high`.

#### Parameters as State

This is the most important concept in the implementation. In an imperative language, `low` and `high` are **mutable variables** updated by the loop on each iteration. In this Lisp implementation, they are **function arguments** — immutable within a given call, and updated by passing new values into the next recursive call.

Each recursive call represents one iteration of the search. The "state" of the search at any moment is encoded entirely in the values of `low` and `high` sitting on the current **call stack frame**.

#### Base Case: `(> low high)`

```lisp
(if (> low high) -1 ...)
```

When `low` exceeds `high`, the search range has collapsed to nothing. The target does not exist in the array. We return `-1`. This is the **termination condition** — without it, the recursion would never stop.

#### Local Binding with `let*`

```lisp
(let* ((mid     (floor (+ low high) 2))
       (mid-val (aref arr mid)))
  ...)
```

`let*` creates **local, immutable bindings**. It is critical to understand that this is not mutation — `mid` and `mid-val` are not variables being assigned; they are names bound to values for the scope of this expression only. This is fundamentally different from `setf`, which would modify a place in memory.

- `(floor (+ low high) 2)` — integer division to find the midpoint, equivalent to `(low + high) // 2`.
- `(aref arr mid)` — retrieves the element at index `mid` from the array, equivalent to `arr[mid]`.

#### The Three-Way Branch with `cond`

```lisp
(cond
  ((= mid-val target) mid)
  ((< mid-val target) (binary-search-recursive arr target (+ mid 1) high))
  (t                  (binary-search-recursive arr target low (- mid 1))))
```

`cond` evaluates conditions top-to-bottom and executes the first matching branch:

| Condition | Meaning | Action |
|---|---|---|
| `(= mid-val target)` | Found the target | Return `mid` (the index) |
| `(< mid-val target)` | Target is to the right | Recurse with `low = mid + 1` |
| `t` (else) | Target is to the left | Recurse with `high = mid - 1` |

In the recursive cases, note that we do **not** write `(setf low (+ mid 1))`. Instead, we pass the updated value directly as an argument. The current call's `low` and `high` remain unchanged — a new stack frame is created with the new values.

---

### 3. `binary-search` — The Public Entry Point

```lisp
(defun binary-search (arr target)
  (binary-search-recursive arr target 0 (- (array-length arr) 1)))
```

This wrapper function provides a clean interface. The caller only needs to provide the array and the target. This function handles the initialization of `low` (always `0`) and `high` (always the last valid index, `length - 1`), then delegates to the recursive core.

---

### 4. Test Cases

```lisp
(defvar *numbers* #(3 7 11 18 25 31 42 56 70))
```

The array is defined using `#(...)`, which creates a **vector** in Lisp — a fixed-size, indexed collection. The `*` convention around the name (`*numbers*`) is a Lisp naming convention for global variables.

| Test | Target | Expected Index | Case Type |
|---|---|---|---|
| Test 1 | 25 | 4 | Element exists in the middle |
| Test 2 | 3 | 0 | Edge case: first element |
| Test 3 | 70 | 8 | Edge case: last element |
| Test 4 | 99 | -1 | Element does not exist |

---

## Recursion Termination — Formal Proof

For the recursion to be correct and guaranteed to terminate, two things must be true:

1. **Progress**: Every recursive call reduces the search space. Either `low` increases (`mid + 1`) or `high` decreases (`mid - 1`). The search range `(high - low)` strictly shrinks on every call.

2. **Base case reachability**: Because the range shrinks on every call, eventually `low` will exceed `high`, triggering the base case and halting the recursion.

This guarantees termination in at most `O(log n)` recursive calls.

---

## Call Stack Trace — Example

Searching for `25` in `#(3 7 11 18 25 31 42 56 70)`:

```
Call 1: low=0, high=8  → mid=4, arr[4]=25 → FOUND, return 4
```

A less lucky example — searching for `31`:

```
Call 1: low=0, high=8  → mid=4, arr[4]=25 < 31 → recurse(low=5, high=8)
Call 2: low=5, high=8  → mid=6, arr[6]=42 > 31 → recurse(low=5, high=5)
Call 3: low=5, high=5  → mid=5, arr[5]=31 = 31 → FOUND, return 5
```

Each call creates a new stack frame holding its own `low`, `high`, and `mid`. When the answer is found, the return value propagates back up through each frame automatically.

---

## Tail-Call Optimization (TCO)

The recursive calls in this implementation are **in tail position** — the result of the recursive call is returned directly without any further computation. This makes it eligible for Tail-Call Optimization (TCO).

However, **Common Lisp does not guarantee TCO** as part of the standard. In practice, most Common Lisp compilers (e.g., SBCL) do optimize tail calls, but it is not required by the spec.

For Binary Search specifically, this is not a practical concern. The maximum recursion depth is `O(log n)`. Even for an array of 1,000,000 elements, the maximum stack depth is only ~20 frames. The stack overflow risk that would affect a linear recursion does not apply here.

---

## Rubric Compliance Summary

| Constraint | Status | Evidence |
|---|---|---|
| No `loop`, `do`, `dotimes`, `while` | ✅ Compliant | Only `if`, `cond`, and recursion used |
| No `setf`, `setq`, or mutation | ✅ Compliant | `let*` used for immutable local bindings only |
| Pure recursion | ✅ Compliant | All iteration expressed as recursive calls |
| Explicit base cases | ✅ Compliant | `(> low high)` terminates the recursion |
| State management | ✅ Compliant | State passed as arguments, lives on call stack |