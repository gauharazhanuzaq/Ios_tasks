// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":"),
          sensor.isEmpty==false,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else { return nil }
    return (sensor: sensor, value: value)
}
print(parseReading("02:87")as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsed = parseLog(rawLog)
print(parsed.valid.count, parsed.invalidCount)
print(parseLog(["O2:1", "junk"]))

let A = parsed.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
print(values(of: o2Readings))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var lowest = first
    var highest = first
    var sum = 0
    for v in values {
        if v < lowest { lowest = v }
        if v > highest { highest = v }
        sum += v
    }
    return (min: lowest, max: highest, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let readings = parsed.valid

let s1 = readings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let s2 = readings.sorted(by: { a, b in return a.value > b.value })
let s3 = readings.sorted(by: { a, b in a.value > b.value })
let s4 = readings.sorted(by: { $0.value > $1.value })
let s5 = readings.sorted { $0.value > $1.value }

let base = values(of: s1)
print(base)
print(base == values(of: s2), base == values(of: s3),
      base == values(of: s4), base == values(of: s5))


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: temp >= 18 && temp <= 24)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempReadings = select(parsed.valid) { $0.sensor == "TEMP" }
let lowestTemp = stats(of: values(of: tempReadings))?.min ?? 21
let C = runUntilStable(from: lowestTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? { member.module?.oxygenTank?.level }

// 4.2
func status(of member: CrewMember) -> String {
    let place = member.module?.name ?? "open space"
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(place))"
    }
    let label = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(label)"
}

for member in crew { print(status(of: member)) }

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let moved = min(amount, source, 100 - target)
    guard moved > 0 else { return 0 }
    source -= moved
    target += moved
    return moved
}

var x = 70, y = 90
print(transferOxygen(from: &x, to: &y, amount: 30), x, y)
print(transferOxygen(from: &x, to: &y, amount: -5), x, y)

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
} else {
    print("Tank missing, transfer skipped")
}

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    found.sort { $0.priority < $1.priority }
    var result: [String] = []
    for member in found { result.append(member.name) }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder(roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
 
 member.module! crashes when the member has no module.
 Data: Nurlan (module == nil, open space).
 Result: runtime crash "Unexpectedly found nil while unwrapping an Optional value".
 oxygenTank! crashes when the module has no tank.
 Data: Dana (Dock has oxygenTank == nil).
 Result: the same crash. Also, two ! in one line, so you can't even tell which one failed.
 
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
 oxygenLevel(of:) returns nil when there is no data.
 Data: Dana (no tank) or Nurlan (no module).
 Result: crash. With the starter data the crew order is
 Timur, Dana, ... so it crashes on the 2nd iteration
 and never even reaches Aigerim.
 
            result = member.name
 
 (LOGIC BUG, no crash): no return/break after the match,
 so the loop keeps going and result is overwritten.
 Data: [Aigerim 5%, Timur 10%] -> returns "Timur" (the LAST
 critical one), but the function is called "firstCritical".
 Hidden in the starter data: only Aigerim is critical, and the
 crash from problem 3 happens before that anyway.
 
        }
    }
    return result!
 result is nil when nobody is critical.
 Data: empty array, or everyone has 20%+ (e.g. after the transfer Aigerim has 42%).
 Result: crash.
 
 (design): the return type String cannot say "nobody found".
 That is the root cause of problem 5: the author was forced to use !
 instead of returning String?. Also unclear: is "no data" critical or
 not? The fix treats it as "not critical" (we dont know).
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

let t1 = CrewMember(name: "First",  role: "Test", priority: 1, module: Module(name: "T1", oxygenTank: Tank(level: 5)))
let t2 = CrewMember(name: "Second", role: "Test", priority: 2, module: Module(name: "T2", oxygenTank: Tank(level: 10)))
let t3 = CrewMember(name: "Ghost",  role: "Test", priority: 3, module: nil)
print(firstCritical(in: [t3, t1, t2]) == "First")
print(firstCritical(in: [t3]) == nil)
print(firstCritical(in: []) == nil)

// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12), alarm(40), alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
 
 With if let, the variable is available only inside the if block.
 With guard let, the variable is available for the rest of the function. If the condition fails, else must exit the function.
 So, guard is useful for checking requirements first and keeping the main code simple.
 Example where if let is worse: several optionals in a row.

 // with if let: nested, "pyramid"
 func userEmail(of user: User) -> String {
     if let profile = user.profile {
         if let email = profile.email {
             return email
         } else {
             return "No email"
         }
     } else {
         return "No profile"
     }
 }

 // with guard let: flat, each failure is next to its check
 func userEmail(of user: User) -> String {
     guard let profile = user.profile else { return "No profile" }
     guard let email = profile.email else { return "No email" }

     return email
 }

 With 4-5 optionals the if let version becomes hard to read.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 
 A variadic parameter accepts separate values:
 stats(3, 8, 1)
 But an array is one value of type [Int]:
 let numbers = [3, 8, 1]
 stats(numbers) // doesnt work
 Swift can put separate values into an array inside the function, but it cannot unpack an array back into separate arguments.
 That’s why we use a separate function for arrays:
 stats(of: numbers)

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
 
 Swift doesnt allow the same variable to be passed as inout twice:
 transferOxygen(from: &x, to: &x, amount: 5) // doesnt work
 This is because both parameters would try to modify the same memory at the same time.
 Swift prevents this with its exclusive access to memory rule.
 It also prevents a logical problem: the source and target are the same variable.
 The function could subtract from it and then add to it, causing an incorrect result.
 So, Swift simply rejects this code to avoid overlapping memory access.
 
 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 
 oxygenLevel returns an Int?, so ?? needs an Int as the default value.
 let level = oxygenLevel(of: dana) ?? 0
 "no data" is a String, so it doesn't work because the types don't match.
 To print "no data", need to use if let:
 if let level = oxygenLevel(of: dana) {
     print("\(level)%")
 } else {
     print("no data")
 }
 So, ?? is for providing a default value of the same type, while if let lets you handle different cases.

 5. Full type of chooseProtocol and how to read it:
 
 (Int) -> (Int) -> Int means a function that:
 1. Takes an Int.
 2. Returns another function.
 3. That function takes an Int and returns an Int.
 For example:
 chooseProtocol(for: 10)(10)
 First, 10 chooses the protocol for the temperature. Then the second 10 is passed to that protocol.
 The for label is not part of the function type.

 Bonus. Where does the alarm counter live after makeAlarm returns?
 Сount is captured by the closure, so Swift keeps it in heap memory instead of on the stack.
 It stays alive while the closure exists. Each makeAlarm call creates its own counter.

*/
