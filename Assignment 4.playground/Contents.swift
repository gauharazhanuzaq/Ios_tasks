// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}
for deck in Deck.allCases {
    print("Deck \(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = max(0, min(mass / 500, AlarmLevel.red.rawValue))
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("Alarm at 0 kg: \(AlarmLevel.level(forTotalMass: 0))")
print("Alarm at 940 kg: \(AlarmLevel.level(forTotalMass: 940))")
print("Alarm at 4000 kg: \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)
    case "container":
        guard parts.count == 3,
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)
    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
    default:
        return .unknown(raw: line)
    }
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg): return massKg
    case let .container(_, massKg): return massKg
    case let .livestock(_, count, massPerUnitKg): return count * massPerUnitKg
    case .unknown: return 0
    }
}
var manifestMass = 0
var unknownManifestLines = 0
var parsedManifest: [ManifestEntry] = []
for line in rawManifest {
    let entry = parseEntry(line)
    parsedManifest.append(entry)
    manifestMass += mass(of: entry)
    if case .unknown = entry {
        unknownManifestLines += 1
    }
}
let A = manifestMass
print("Manifest total mass: \(A) kg")
print("Unknown manifest lines: \(unknownManifestLines)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
func makeCrewRoster() -> [CrewSnapshot] {
    var roster: [CrewSnapshot] = []
    for record in crewData {
        if let deck = Deck(rawValue: record.deck) {
            roster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
        } else {
            print("Warning: skipped \(record.name); unknown deck \(record.deck).")
        }
    }
    return roster
}
let crewRoster: [CrewSnapshot] = makeCrewRoster()

func breatheByValue(_ snapshot: CrewSnapshot) {
    var localSnapshot = snapshot
    localSnapshot.breathe(10)
    print("Inside plain function after breathing: \(localSnapshot.oxygen)")
}

func breatheByReference(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(10)
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
var originalForCopy = crewRoster[0]
var snapshotCopy = originalForCopy
print("Copy demonstration before: original \(originalForCopy.oxygen), copy \(snapshotCopy.oxygen)")
snapshotCopy.breathe(10)
print("Copy demonstration after: original \(originalForCopy.oxygen), copy \(snapshotCopy.oxygen)")

print("Plain function before: original \(originalForCopy.oxygen)")
breatheByValue(originalForCopy)
print("Plain function after: original \(originalForCopy.oxygen)")

print("inout function before: original \(originalForCopy.oxygen)")
breatheByReference(&originalForCopy)
print("inout function after: original \(originalForCopy.oxygen)")

var rookie = CrewSnapshot.rookie(named: "Rookie")
print("Rookie starts on \(rookie.deck.rawValue) with oxygen \(rookie.oxygen)")
rookie.move(to: .lab)
rookie.reviveInMedbay()
print("After moving and revival: \(rookie.name), \(rookie.deck.rawValue), oxygen \(rookie.oxygen)")

// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // CrewSnapshot receives a memberwise initializer; this class needs its own initializer.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard chargeLevel >= 20, let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}
func runChargeLedger() -> TeleportPod {
    let pod = TeleportPod(id: "P-1", chargeLevel: 100)

    _ = pod.load(crewRoster[0])
    print("After loading Timur: \(pod.chargeLevel)")
    _ = pod.fire()
    print("After firing Timur: \(pod.chargeLevel)")

    _ = pod.load(crewRoster[1])
    print("After loading Dana: \(pod.chargeLevel)")
    _ = pod.fire()
    print("After firing Dana: \(pod.chargeLevel)")

    _ = pod.load(crewRoster[3])
    print("After loading Nurlan: \(pod.chargeLevel)")
    _ = pod.fire()
    print("After firing Nurlan: \(pod.chargeLevel)")

    _ = pod.fire()
    print("After firing the empty pod: \(pod.chargeLevel)")
    return pod
}

let pod = runChargeLedger()

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
let C = pod.chargeLevel
let secondPodReference = pod
secondPodReference.chargeLevel = 25
print("Charge through first pod reference: \(pod.chargeLevel)")
print("Charge through second pod reference: \(secondPodReference.chargeLevel)")

// 4.3 · Reference-semantics demonstration

var crewValue = crewRoster[0]
var copiedCrewValue = crewValue
copiedCrewValue.oxygen = 30
print("Crew value original oxygen: \(crewValue.oxygen)")
print("Crew value copy oxygen: \(copiedCrewValue.oxygen)")

// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    var hullIntegrity: Int {
        willSet {
            print("Hull integrity transition: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): \(self.oxygenByDeck.count) decks, \(self.totalOxygen) oxygen."
    }()
    var oxygenByDeck: [Deck: Int]

    var totalOxygen: Int {
        var total = 0
        for oxygen in oxygenByDeck.values {
            total += oxygen
        }
        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            let decks = Array(oxygenByDeck.keys)
            for deck in decks {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, deckReadings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var validReadings: [Deck: Int] = [:]
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                validReadings[deck] = reading.oxygen
            } else {
                print("Warning: skipped oxygen reading for unknown deck \(reading.deck).")
            }
        }
        self.oxygenByDeck = validReadings
    }
}

var station = Station(callSign: "ALMA-7", deckReadings: deckReadings)
let B = station.averageOxygen
print("Starting average oxygen: \(B)")
print("Starting total oxygen: \(station.totalOxygen)")

station.averageOxygen = 60
print("Average after setting every deck to 60: \(station.averageOxygen)")
print("Total after setting every deck to 60: \(station.totalOxygen)")

print("Diagnostics have not run before the first access.")
print("First diagnostics access: \(station.fullDiagnostics)")
print("Second diagnostics access: \(station.fullDiagnostics)")
let unscannedStation = Station(callSign: "ALMA-7-B", deckReadings: [])
print("Diagnostics remain unrun for untouched station \(unscannedStation.callSign).")

// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

// Report 1: The author expected every crew member to lose 10 oxygen.
 // Actual: roster[0] is unchanged because each loop variable is a value copy.
 // Rule: assigning a value type to the loop variable does not write it back.
 // Fix: use indices and mutate the array elements directly.
//var roster = crewRoster
//for var member in roster {
//    member.oxygen -= 10
//}
//print(roster[0].oxygen)   // author expected the crew to have lost oxygen
// Fixed:
 var fixedRoster = crewRoster
 for index in fixedRoster.indices {
     fixedRoster[index].breathe(10)
 }
 print("Report 1 fixed roster first oxygen: \(fixedRoster[0].oxygen)")
 print("Report 1 original roster first oxygen: \(crewRoster[0].oxygen)")

// Report 2: The author expected podA to stay at 100.
 // Actual: podA.chargeLevel becomes 0 because both names refer to one object.
 // Rule: class assignment copies the reference. Fix: make a new TeleportPod.
// let podA = TeleportPod(id: "A", chargeLevel: 100)
// let podB = podA
// podB.chargeLevel = 0
// print(podA.chargeLevel)   // author expected 100
 
 // Fixed:
 
 let independentPodA = TeleportPod(id: "A1", chargeLevel: 100)
 let independentPodB = TeleportPod(id: "A2", chargeLevel: independentPodA.chargeLevel)
 independentPodB.chargeLevel = 0
 print("Report 2 independent pod A: \(independentPodA.chargeLevel)")
 print("Report 2 independent pod B: \(independentPodB.chargeLevel)")


// Report 3: The author expected Logbook.add to append an entry.
 // Actual: it does not compile because entries is changed in a nonmutating method.
 // Rule: a struct method that changes stored properties must be marked mutating.

//struct Logbook {
//    var entries: [String] = []
//    func add(_ entry: String) {
//        entries.append(entry)
//    }
//}
// Fixed:
struct Logbook {
 var entries: [String] = []
 mutating func add(_ entry: String) { entries.append(entry) }
 }
var logbook = Logbook()
logbook.add("Manifest checked")
print("Logbook after first entry: \(logbook.entries)")

logbook.add("Oxygen checked")
print("Logbook after second entry: \(logbook.entries)")
// Report 4: The author expected both assignments to compile.
 // Actual: snapshot.oxygen = 40 does not compile; pod.chargeLevel = 10 does.
 // Rule: let freezes a struct value and all its stored properties. For a class,
 // let freezes the reference binding, while mutable properties of that object remain mutable.
// let snapshot = CrewSnapshot.rookie(named: "Dana")
// snapshot.oxygen = 40
//
// let pod = TeleportPod(id: "B", chargeLevel: 50)
// pod.chargeLevel = 10
 // Fixed:
 
 var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
 fixedSnapshot.oxygen = 40
 print("Report 4 fixed struct snapshot oxygen: \(fixedSnapshot.oxygen)")
 let reportPod = TeleportPod(id: "B", chargeLevel: 50)
 reportPod.chargeLevel = 10
 print("Report 4 let class reference allows charge change: \(reportPod.chargeLevel)")

// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

final class FlightRecorder {
    // private blocks outside code from replacing or clearing the entry list.
    private var entries: [String] = []

    // private(set) blocks outside code from changing isSealed back to false.
    private(set) var isSealed = false

    // fileprivate blocks access to this helper from other source files.
    fileprivate func entriesForAudit() -> [String] {
        entries
    }

    // internal blocks clients outside this module from reading the entry count.
    internal var entryCount: Int {
        entries.count
    }

    // internal blocks clients outside this module from reading the formatted transcript.
    internal var formattedTranscript: String {
        var lines: [String] = []
        for entry in entries {
            lines.append("- \(entry)")
        }
        return lines.joined(separator: "\n")
    }

    // internal blocks clients outside this module from calling the guarded add method.
    internal func addEntry(_ entry: String) {
        guard isSealed == false else { return }
        entries.append(entry)
    }

    // internal blocks clients outside this module from calling seal.
    internal func seal() {
        isSealed = true
    }
}

// A free function elsewhere in the file that uses your fileprivate helper:
internal func auditTranscript(of recorder: FlightRecorder) -> String {
    recorder.entriesForAudit().joined(separator: "\n")
}

let recorder = FlightRecorder()
recorder.addEntry("Manifest checked")
recorder.addEntry("Oxygen readings checked")
print("Recorder entry count: \(recorder.entryCount)")
print("Recorder formatted transcript:\n\(recorder.formattedTranscript)")
print("Audit transcript:\n\(auditTranscript(of: recorder))")
recorder.seal()
recorder.addEntry("This entry is blocked after sealing")
print("Recorder sealed: \(recorder.isSealed)")
print("Entry count after attempted post-seal append: \(recorder.entryCount)")

// recorder.entries = []
// Compiler error: 'entries' is inaccessible due to 'private' protection level.

// recorder.entries.removeAll()
// Compiler error: 'entries' is inaccessible due to 'private' protection level.

// recorder.isSealed = false
// Compiler error: cannot assign to property: 'isSealed' setter is inaccessible.

// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity
func occupantsHaveSameContents(_ first: CrewSnapshot?, _ second: CrewSnapshot?) -> Bool {
    switch (first, second) {
    case (nil, nil):
        return true
    case let (left?, right?):
        return left.name == right.name &&
            left.deck.rawValue == right.deck.rawValue &&
            left.oxygen == right.oxygen
    default:
        return false
    }
}

func podRelationship(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "Same pod instance."
    }
    if first.id == second.id &&
        first.chargeLevel == second.chargeLevel &&
        occupantsHaveSameContents(first.occupant, second.occupant) {
        return "Different pods with equal contents."
    }
    return "Different pods with different contents."
}

let identityPodA = TeleportPod(id: "IDENTITY", chargeLevel: 80)
let identityPodAlias = identityPodA
let identityPodB = TeleportPod(id: "IDENTITY", chargeLevel: 80)
print("Identity comparison, alias: \(podRelationship(identityPodA, identityPodAlias))")
print("Identity comparison, separate equal pod: \(podRelationship(identityPodA, identityPodB))")

var retainedPod: TeleportPod? = nil
print("Before the do block.")
do {
    let scopedPod = TeleportPod(id: "DO-BLOCK", chargeLevel: 60)
    retainedPod = scopedPod
    if let secondReference = retainedPod {
        print("Inside the do block: \(podRelationship(scopedPod, secondReference))")
    }
}
print("After the do block: DO-BLOCK is still alive because retainedPod holds a reference.")
// deinit fires on the next line when retainedPod releases the last strong reference.
retainedPod = nil
print("After releasing retainedPod.")

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 CrewSnapshot gets a synthesized memberwise initializer because I define none.
 TeleportPod needs a custom initializer to set occupant to nil.
 2. What does `mutating` do to self, and why do classes never need it?
 mutating lets a value-type method change or replace its self value.
 Classes change the referenced object, so class methods need no mutating.
 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 let freezes every stored property of a struct value. For a class, it freezes
 which object the variable refers to, but that object's var properties can change.
 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 lazy must be var because its first read stores the computed result.
 A lazy value can use configuration changed before its first access.
 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 The free auditTranscript function needs to call entriesForAudit in this file.
 private would block that function; fileprivate allows it within this file.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 O-BLOCK deinitializes when retainedPod is set to nil, after the do block.
=== compares class identity; CrewSnapshot is a struct value with no identity.


*/
