import Foundation

// MARK: - Easy Tasks

// 1. Array creation and access
let fruits = ["Apple", "Banana", "Strawberry", "Watermelon", "Orange"]
print(fruits[2])

// 2. Set creation and manipulation
var favoriteNumbers: Set<Int> = [11, 95, 27, 82]
favoriteNumbers.insert(7)
print(favoriteNumbers)

// 3. Dictionary creation and access
let releaseYears = [
    "Swift": 2014,
    "Microsoft": 1985,
    "Apple": 1980
]
print("Swift release year: \(releaseYears["Swift"]!)")

// 4. Array element update
var colors = ["Red", "Blue", "Green", "Yellow"]
colors[1] = "Purple"
print("Easy 4 - Updated colors: \(colors)")

// MARK: - Medium Tasks

// 1. Set intersection
let firstIntegers: Set<Int> = [1, 2, 3, 4]
let secondIntegers: Set<Int> = [3, 4, 5, 6]
print(firstIntegers.intersection(secondIntegers))

// 2. Dictionary update
var students = ["Gauhar": 87, "Leila": 91, "Milana": 55]
students.updateValue(95, forKey: "Moldir")
print(students)

// 3. Array merge
let firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "date"]
print(firstFruits + secondFruits)

// MARK: - Hard Tasks

// 1. Dictionary key addition
var countryPopulations = ["Kazakhstan": 21_133_071, "China": 1_410_000_000]
countryPopulations["Monaco"] = 38_980
print(countryPopulations)

// 2. Set union and subtract
let first: Set<String> = ["cat", "dog"]
let second: Set<String> = ["dog", "mouse"]
let final = first.union(second).subtracting(second)
print(final)

// 3. Nested collection
let grades = [
    "Gauhar": [87, 85, 90],
    "Leila": [78, 88, 91],
    "Milana": [77, 65, 80]
]
print(grades["Gauhar"]![1])
