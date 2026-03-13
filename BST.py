# Iterative Binary Search Implementation
# Based on algorithm descriptions from:
# - GeeksforGeeks: https://www.geeksforgeeks.org/binary-search/
# - Introduction to Algorithms (Cormen et al.)
# - Python Documentation: https://docs.python.org/3/

def binary_search(arr, target):

    low = 0
    high = len(arr) - 1

    while low <= high:

        mid = (low + high) // 2

        if arr[mid] == target:
            return mid

        elif arr[mid] < target:
            low = mid + 1

        else:
            high = mid - 1

    return -1


# Example test
numbers = [3, 7, 11, 18, 25, 31, 42, 56, 70]

target = 25

result = binary_search(numbers, target)

if result != -1:
    print("Element found at index:", result)
else:
    print("Element not found")