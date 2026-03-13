;;; Recursive Binary Search — Common Lisp
;;; BCS 222 | Paradigm: Functional (Pure Recursion)
;;; No loops, no setf, no mutation — state lives on the call stack
;;;
;;; Sources:
;;;   https://rabbibotton.github.io/clog/cltt.pdf
;;;   https://www.geeksforgeeks.org/lisp/introduction-to-lisp/
;;;   https://www.tutorialspoint.com/lisp/index.htm


(defun array-length (arr) (length arr))

;;; Core recursive function — LOW and HIGH passed as arguments, never mutated
(defun binary-search-recursive (arr target low high)
;; Base case: search space exhausted
    (if (> low high)
        -1
      ;; Bind MID locally — let* is immutable binding, NOT mutation
      (let* ((mid (floor (+ low high) 2))
             (mid-val (aref arr mid)))
        (cond
          ;; Found
          ((= mid-val target) mid)

          ;; Target is in the right half — recurse with updated LOW
          ((< mid-val target)
           (binary-search-recursive arr target (+ mid 1) high))

          ;; Target is in the left half — recurse with updated HIGH
          (t
           (binary-search-recursive arr target low (- mid 1))))))))


;;; Public entry point — initializes LOW and HIGH automatically
(defun binary-search (arr target)
  (binary-search-recursive arr target 0 (- (array-length arr) 1)))


;;; --- Tests ---
(defvar *numbers* #(3 7 11 18 25 31 42 56 70))

(let ((result (binary-search *numbers* 25)))
  (if (/= result -1)
      (format t "Test 1 | Element 25 found at index: ~a~%" result)
      (format t "Test 1 | Element not found~%")))

(let ((result (binary-search *numbers* 3)))
  (if (/= result -1)
      (format t "Test 2 | Element 3 found at index: ~a~%" result)
      (format t "Test 2 | Element not found~%")))

(let ((result (binary-search *numbers* 70)))
  (if (/= result -1)
      (format t "Test 3 | Element 70 found at index: ~a~%" result)
      (format t "Test 3 | Element not found~%")))

(let ((result (binary-search *numbers* 99)))
  (if (/= result -1)
      (format t "Test 4 | Element 99 found at index: ~a~%" result)
      (format t "Test 4 | Element not found~%")))