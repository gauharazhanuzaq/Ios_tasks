import UIKit

//Step 1:
let myFirstName: String = "Gauhar"
let myLastName: String = "Zhanuzak"
let myAge: Int = 20
let myBirthYear: Int = 2005
let myBirthMonth: String = "October"
let myHeight: Double = 1.70
let myWeight: Double = 55
let city = "Almaty"
let isStudent: Bool = true

//Bonus Challenge:
let currentYear: Int = 2026
let currentAge: Int = currentYear - myBirthYear

// Step2:
let myHobby: String = "Playing piano, drawing different pictures, listening music"
let numberOfHobbies: Int = 3
let myFavoriteNumber: Int = 11
let myFavoriteColor: String = "Ocean Blue"
let myFavoriteBeverages: String = "Tea, Coffee, and Juice"
let isHobbyCreative: Bool = true

//Bonus Task:
let fututreGoals: String = "Complete a bachelor's degree. Become a senior specialist in UI/UX design"

//Emoji:
let 🔵emoji1: String = "🌊"
let emoji2: String = "🎶"
let emoji3: String = "✨"

//Step 3:
var lifeStory = "My name is \(myFirstName) \(myLastName). I'm \(currentAge). I was burn in \(myBirthYear) in \(myBirthMonth) in \(city). My height is \(myHeight) and my weight is \(myWeight). I'm currently a student: \(isStudent). I have \(numberOfHobbies) hobbies, these are \(myHobby)\(emoji2). My hobbies are creative: \(isHobbyCreative). My favorite number is \(myFavoriteNumber) and my favorite color is \(myFavoriteColor)\(🔵emoji1). Also I have some favorite beverages, these are \(myFavoriteBeverages). And finally my future goals are \(fututreGoals)\(emoji3)."

//Step 4:
print(lifeStory)
