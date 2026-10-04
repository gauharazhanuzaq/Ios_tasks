// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A battery is one physical object with identity: the drone and anyone else holding
// the cell must see the same charge, and spend/recharge change it in place, which a
// copied-on-assignment struct would not do.

final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)      // clamp into 0...100
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge += min(amount, 100 - charge)         // never above 100 (and no overflow)
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error:


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> It guarantees that no subclass can replace the shift ritual (spend first, do nothing on
// failure, then work), so subclasses can change only the cost and the work, never the rules.

class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }                       // overridable

    var statusLine: String {                        // "W-1: 80% ########.."
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var canRunOnce: Bool { cell.level() >= powerCost }

    func performTask() -> Int { 0 }                 // a bare drone does nothing

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

func buildFleet(from records: [(kind: String, id: String, charge: Int)]) -> [Drone] {
    var result: [Drone] = []
    for record in records {
        if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
            result.append(drone)
        } else {
            print("WARNING: skipped record \(record.id) - unknown drone kind '\(record.kind)'")
        }
    }
    return result
}

let fleet: [Drone] = buildFleet(from: fleetData)
print("Fleet built: \(fleet.count) drones.")


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()                // one call, different behaviour per object
        }
    }
    return total
}

func totalCharge(_ fleet: [Drone]) -> Int {
    var sum = 0
    for drone in fleet { sum += drone.cell.level() }
    return sum
}

func countReady(_ fleet: [Drone]) -> Int {
    var count = 0
    for drone in fleet where drone.canRunOnce { count += 1 }
    return count
}

let A = runShift(fleet, rounds: 3)
print("Shift finished: \(A) work units.")
for drone in fleet { print("  \(drone.statusLine)") }
let C = countReady(fleet)
print("Drones with enough charge for one more task: \(C)")
let B = totalCharge(fleet)


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class (a reference type): a method can change the object's properties
// through the reference without replacing `self`, so `mutating` has no meaning for classes.
// A struct is a value type and its methods get an immutable `self`, so a method that changes
// a property must say `mutating`.

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }   // rule lives in the protocol extension

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = PowerCell(charge: chargeLevel).level()   // reuse the clamping rule
    }

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        let cell = PowerCell(charge: chargeLevel)   // reuse the recharge rule, no copy-paste
        cell.recharge(by: amount)
        chargeLevel = cell.level()
    }
}

// 4.3
// Why could [Drone] never have held the sensors?  -> Because SensorModule is a struct and cannot inherit from the Drone class; only a protocol
// can be the common type of a class and a struct.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }

print("\n--- Diagnostics (drones + sensors) ---")
print(diagnosticsReport(components))

// Small demos of the two `recharge(by:)` flavours (they do not touch the fleet above):
let spareDrone = WelderDrone(id: "W-spare", cell: PowerCell(charge: 10))
spareDrone.recharge(by: 30)                         // `let` is fine: class, no `mutating`
var spareSensor = sensors[0]                        // a copy, because SensorModule is a struct
spareSensor.recharge(by: 50)                        // needs `var`: the method is `mutating`
print("Demo: spare drone \(spareDrone.cell.level())%, spare sensor \(spareSensor.chargeLevel)%")


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "[LEGACY HARDWARE] \(componentID): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print("\n--- Diagnostics (drones + sensors + beacon) ---")
print(diagnosticsReport(components))

func totalStatusCode(_ components: [Diagnosable]) -> Int {
    var sum = 0
    for component in components { sum += component.statusCode }
    return sum
}

let D = totalStatusCode(components)

// 5.3
extension Int {
    var powerBar: String {                          // 42 -> "####......"
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        return String(repeating: "#", count: filled)
             + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// ---- Analysis ----------------------------------------------------------------------
//
// Report 1  (does NOT compile)
//   Expected: PatchDrone is a new drone type that produces 30 work units per task.
//   Actual:   error: overriding declaration requires an 'override' keyword.
//             Drone already has performTask(), so this is an override, not a new method.
//   Rule:     overrides must be written explicitly with `override`, so an accidental name
//             clash (or a typo meant to be an override) is caught by the compiler.
//   Fix:      override func performTask() -> Int { 30 }
//
// Report 2  (does NOT compile)
//   Expected: a stronger welder whose runOnce() returns 999.
//   Actual:   errors: inheritance from a final class 'WelderDrone', and
//             instance method overrides a 'final' instance method (runOnce is final in Drone).
//   Rule:     `final` on a class forbids subclassing it; `final` on a member forbids overriding.
//   Fix:      do not touch runOnce(); change cost/work through the allowed hooks, e.g.
//             final class HeavyWelder: Drone {
//                 override var powerCost: Int { 40 }
//                 override func performTask() -> Int { 999 }
//             }
//
// Report 3  (does NOT compile)
//   Expected: the first element is a WelderDrone, so weldSeam() should work.
//   Actual:   error: value of type 'Drone' has no member 'weldSeam'.
//   Rule:     the compiler checks members against the static type (Drone, the array's element
//             type), not against the real object that is in it at runtime.
//   Fix:      if let welder = first as? WelderDrone { print(welder.weldSeam()) }
//             `as?` returns an optional because the cast can fail at runtime: the object might
//             be a ScannerDrone or CargoDrone, and then the result is nil.
//
// Report 4  (compiles and lies)
//   Expected: "thruster T-1", because Thruster defines its own label().
//   Actual:   prints "generic component".
//   Rule:     label() is not a requirement of Labelled, it exists only in the protocol extension.
//             Calls on a protocol-typed value to such a method are bound statically to the
//             extension implementation; only requirements are dispatched dynamically through
//             the protocol witness table. Thruster.label() is just an unrelated method that
//             is used only when the static type is Thruster.
//   Fix:      make label() a requirement - one line in the protocol:
//             protocol Labelled { var componentID: String { get }; func label() -> String }
//             (the extension then only supplies the default).
//

// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.

// Way 1 - fails at RUNTIME: refuse to run when the dynamic type is the base class itself.
// (put at the end of Drone.init, after the properties are assigned)
//     if type(of: self) == Drone.self { fatalError("Drone is abstract: use a subclass") }
// Optionally also make performTask() { fatalError("subclass must override") }.
//
// Way 2 - fails at COMPILE time: a protocol requirement with no default. A type that does not
// implement performTask() simply does not build, and nobody can create "a bare RepairDrone",
// because a protocol cannot be instantiated.

protocol RepairDrone: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int                       // no default: every drone must supply it
}

extension RepairDrone {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }

    // Not a requirement, so it cannot be overridden through the protocol: acts like `final`.
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: RepairDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

struct ScannerUnit: RepairDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 10 }
    func performTask() -> Int { 15 }
}

let unitFleet: [RepairDrone] = [
    WelderUnit(id: "WU-1", cell: PowerCell(charge: 100)),
    ScannerUnit(id: "SU-1", cell: PowerCell(charge: 60))
]
var bonusWork = 0
for unit in unitFleet { bonusWork += unit.runOnce() }
print("Bonus: protocol-based fleet produced \(bonusWork) work units")

// Comparison:
// The class design shares one implementation and one stored state through a single base class,
// but the "abstract" Drone can only be guarded at runtime. The protocol design is checked by the
// compiler (a missing performTask() will not build), works for structs and for types we do not
// own (like LegacyBeacon), and has no accidental instantiation. For this station I would pick the
// protocol design; if the drones had to share mutable state, I would keep a class (reference
// semantics, like PowerCell) or constrain the protocol to AnyObject, because struct copies would
// drift apart and every mutating call would need `mutating` and `var`.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?

    A class is a reference type: its methods modify the stored properties through the reference
    and never need to replace `self`, so `mutating` does not exist for classes and a plain method
    satisfies the requirement. A struct is a value type: inside its methods `self` is immutable
    unless the method is marked `mutating`, which lets it modify (replace) `self`. SensorModule
    changes chargeLevel, so its recharge(by:) must be `mutating`.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:

    Inheritance: a subclass gets the parent's stored properties, initializer and implementation
    (and can call `super`); a protocol cannot have stored properties or share state.
    Protocols: they unite unrelated types - classes, structs, enums, even types we cannot edit
    (LegacyBeacon via an extension) - and a type can adopt several of them, while a class can
    inherit from only one superclass and a struct cannot inherit at all.

 3. What does `final` prevent, and what did it protect in runOnce()?

    `final` forbids overriding a member (or, on a class, subclassing it). Marking runOnce() final
    protects the shift ritual - spend powerCost first, return 0 on failure, only then performTask() -
    so no subclass can skip paying for a task or change the result (like the 999 in Report 2).

 4. In Report 4, why did the protocol extension's method win?

    label() is declared only in the protocol extension, not as a protocol requirement, so a call
    through the protocol type is resolved statically to the extension's method. Thruster's own
    label() is not part of the protocol's witness table; it is used only when the static type is
    Thruster. Declaring `func label() -> String` in the protocol makes it a requirement and
    dynamic dispatch picks Thruster's version.

*/
