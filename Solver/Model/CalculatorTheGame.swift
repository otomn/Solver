//
//  CalculatorTheGame.swift
//  Solver
//
//  Created by Toby on 2020-07-19.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

public class CalculatorTheGame: GameState{
    
    public var player: Int = 0
    
    public var numPlayer: Int = 1
    
    public var moves: [String] {
        return operations.map(String.init)
    }
    
    public var winners: [Int]? {
        return goal == current ? [0] : nil
    }
    
    public var description: String {
        return "\(current)"
    }
    
    var movesLeft: Int
    var current: Int
    var goal: Int
    var operations: [Operation] = []
    var portal: Portal?
    
    public convenience init(value: Int, movesLeft: Int, goal: Int, 
                            ops: [String]) {
        self.init(value: value, movesLeft: movesLeft, goal: goal, 
                  ops: ops.compactMap(Operation.parse))
    }
    
    required init(value: Int, movesLeft: Int, goal: Int, ops: [Operation]) {
        self.current = value;
        self.movesLeft = movesLeft;
        self.goal = goal;
        self.operations = ops
        self.operations.forEach{ $0.parseExpand(state: self) }
        for op in ops {
            if let port = op as? Portal {
                portal = port
                break
            }
        }
    }
    
    public required convenience init?(input: () -> String?) {
        guard let initial = getInput(
            prompt: pure1("Initial: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            inputStream: input).first else { return nil }
        guard let maxMoves = getInput(
            prompt: pure1("Moves: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            inputStream: input).first else { return nil }
        guard let goal = getInput(
            prompt: pure1("Goal: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            inputStream: input).first else { return nil }
        let ops = getInput(
            prompt: pure1("Operation: "), 
            failedMessage: "Invalid operation", 
            parser: Operation.parse, 
            terminateCondition: { input, _ in input == "" },
            inputStream: input)
        self.init(value: initial, movesLeft: maxMoves, goal: goal, ops: ops)
    }
    
    public func playerSymbol(player: Int) -> String? {
        return "Player"
    }
    
    public func move(player: Int, move: String) -> Self? {
        if !isValidMove(move: move) { 
            return nil
        }
        guard let op = operations.first(where: { "\($0)" == move }) else {
            return nil
        }
        let newOps = operations.map{ $0.copy() }
        let newState = Self.init(
            value: current, movesLeft: movesLeft - 1, goal: goal, ops: newOps)
        op.operate(state: newState)
        if newState.current == Operation.error || newState.movesLeft < 0 {
            return nil
        }
        portal?.operate(state: newState)
        return newState
    }
    
    static func playLoop() {
        while true {
            guard let game: GameState = CalculatorTheGame(input: { readLine() }) else { continue }
            // CalculatorTheGameH is not designed to find all solutions
            let heuristic = WinLoseH(game: game)!, allPaths = true
//            let heuristic = CalculatorTheGameH(game: game)!, allPaths = false 
            let algorithm = BFSHMulThread(game: game, heuristic: heuristic)
            let start = Date()
            algorithm.computePath(game: game, allPaths: allPaths)
            let end = Date()
            print("Time taken: \(end.timeIntervalSince(start))")
            print("Solutions:")
            algorithm.paths.sorted(by: { $0.count < $1.count }).forEach{
                print("[\($0.count)]:", terminator: " ")
                $0.forEach{ print($0, terminator: " ") }
                print()
            }
        }
    }
}

class Operation: LosslessStringConvertible {
    
    var description: String { "" }
    
    var const: Int
    static let maxLen = 7
    static let error = Int.max
    private static let operationSet: [Operation.Type] = [
        Add.self, Subtract.self,
        Multiply.self, Divide.self,
        Append.self, Delete.self,
        Power.self, Sign.self,
        Replace.self, Reverse.self,
        Sum.self, Shift.self,
        Mirror.self, Increment.self,
        Store.self, Paste.self,
        Inverse.self, Portal.self
    ]
    
    init() {
        const = 0
    }
    
    init(_ const: Int) {
        self.const = const
    }
    
    required init?(_ description: String) {
        const = 0
    }
    
    func operate(state: CalculatorTheGame) {
        state.current = operate(num: state.current)
    }
    
    func operate(num: Int) -> Int {
        return num
    }
    
    /// Executed when a list of operations is parsed for the state
    /// - Parameter state: The state to be updated
    func parseExpand(state: CalculatorTheGame){
    }
    
    func copy() -> Operation {
        return Self.init(description)!
    }
    
    static func parse(_ description: String) -> Operation? {
        return parse(description: description, in: operationSet)
    }
    
    static func parse(description: String, in set: [Operation.Type]) -> Operation?{
        for c in set {
            if let op = c.init(description) {
                if "\(op)" == description {
                    return op
                }
            }
        }
        return nil
    }
    
    static func parseUnaryString(target: String, value: String) -> String? {
        return value.starts(with: target) ? 
            String(value[value[target.count]...]) : nil
    }
    
    static func parseUnary(target: String, value: String) -> Int? {
        if let s = parseUnaryString(target: target, value: value) {
            return Int(s)
        }
        return nil
    }
    
    static func parseBinaryString(sep: String, value: String)
        -> (String, String)?{
        let splited = 
            value.split(separatorString: sep, omittingEmptySubsequences: false)
        if splited.count == 2 {
            return (splited[0], splited[1])
        }
        return nil
    }
    
    static func parseBinary(sep: String, value: String)
        -> (Int, Int)?{
        if let p = parseBinaryString(sep: sep, value: value) {
            if let a = Int(p.0), let b = Int(p.1) {
                return (a, b)
            }
        }
        return nil
    }
}

// /1
class Divide: Operation{
    
    override var description: String { "/\(const)" }
    
    override func operate(num: Int) -> Int {
        if num % const != 0 {
            return Operation.error
        }
        return num / const
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "/", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// *1
class Multiply: Operation{
    
    override var description: String { "*\(const)" }
    
    override func operate(num: Int) -> Int {
        return num * const
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "*", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// +1
class Add: Operation{
    
    override var description: String { "+\(const)" }
    
    override func operate(num: Int) -> Int {
        return num + const
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "+", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// -1
class Subtract: Operation{
    
    override var description: String { "-\(const)" }
    
    override func operate(num: Int) -> Int {
        return num - const
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "-", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// <<
class Delete: Operation{
    
    override var description: String { "<<" }
    
    override func operate(num: Int) -> Int {
        var str = String(num)
        str.removeLast()
        return Int(str) ?? 0
    }
    
    required init?(_ description: String) {
        if description == "<<" {
            super.init()
        } else {
            return nil
        }
    }
}

// 1
class Append: Operation{
    
    override var description: String { "\(const)" }
    
    override func operate(num: Int) -> Int {
        if const < 0 { 
            return num
        }
        let str = String(num) + String(const)
        return str.count > Operation.maxLen ? Operation.error : Int(str)!
    }
    
    override init(_ const: Int) {
        super.init(const)
    }
    
    required init?(_ description: String) {
        if let i = Int(description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// ^1 (x^1 in the game)
class Power: Operation{
    
    override var description: String { "^\(const)" }
    
    override func operate(num: Int) -> Int {
        return pow(num, const) ?? Operation.error
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "^", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// +- (+/- in the game)
class Sign: Operation{
    
    override var description: String { "+-" }
    
    override func operate(num: Int) -> Int {
        return -num
    }
    
    required init?(_ description: String) {
        if description == "+-" {
            super.init()
        } else {
            return nil
        }
    }
}

// 1>2 (1=>2 in the game)
class Replace: Operation{
    
    var ori: String
    var target: String
    
    init(ori: String, target: String) {
        self.target = target
        self.ori = ori
        super.init()
    }
    
    required convenience init?(_ description: String) {
        if let (o, t) = Operation.parseBinaryString(sep: ">", value: description) {
            if Int(o) != nil && Int(t) != nil {
                self.init(ori: o, target: t)
                return
            }
        }
        return nil
    }
    
    override var description: String { "\(ori)>\(target)" }
    
    override func operate(num: Int) -> Int {
        return Int("\(num)"
            .split(separatorString: ori, omittingEmptySubsequences: false)
            .joined(separator: target)) ?? 0
        // if the number is no longer valid, that means there is no digit left
    }
}

// r (Reverse in the game)
class Reverse: Operation{
    
    override var description: String { "r" }
    
    override func operate(num: Int) -> Int {
        return Int(String("\(num.magnitude)".reversed()))! * num.signum()
    }
    
    required init?(_ description: String) {
        if description == "r" {
            super.init()
        } else {
            return nil
        }
    }
}

// sum
class Sum: Operation{
    
    override var description: String { "sum" }
    
    override func operate(num: Int) -> Int {
        var sum = 0
        for i in "\(num)" {
            sum += Int("\(i)") ?? 0
        }
        return num.signum() * sum
    }
    
    required init?(_ description: String) {
        if description == "sum" {
            super.init()
        } else {
            return nil
        }
    }
}

// < or > (shift< or shift> in the game)
class Shift: Operation{
    
    var left: Bool
    
    init(shiftLeft: Bool) {
        left = shiftLeft
        super.init()
    }
    
    override var description: String { left ? "<" : ">" }
    
    required convenience init?(_ description: String) {
        if description == "<" {
            self.init(shiftLeft: true)
        } else if description == ">" {
            self.init(shiftLeft: false)
        } else {
            return nil
        }
    }
    
    override func operate(num: Int) -> Int {
        var str = "\(num.magnitude)"
        if left {
            str = str + "\(str.first!)"
            str.removeFirst()
        } else {
            str = "\(str.last!)" + str
            str.removeLast()
        }
        return num.signum() * (Int(str) ?? 0)
    }
    
}

// m (Mirror in the game)
class Mirror: Operation {
    
    override var description: String { "m" }
    
    override func operate(num: Int) -> Int {
        let str = "\(num)" + String("\(num.magnitude)".reversed())
        return str.count > Operation.maxLen ? Operation.error : Int(str)!
    }
    
    required init?(_ description: String) {
        if description == "m" {
            super.init()
        } else {
            return nil
        }
    }
}

// ++ ([+] in the game)
class Increment: Operation {
    
    override var description: String { "++\(const)" }
    
    override func operate(state: CalculatorTheGame) {
        state.operations.forEach{ if !($0 is Increment) { $0.const += const } }
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "++", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// st (hold store in the game)
class Store: Operation {
    
    override var description: String { "st" }
    
    override func operate(state: CalculatorTheGame) {
        state.operations.forEach{ if $0 is Paste { $0.const = state.current } }
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if !state.operations.contains(where: { $0 is Paste }){
            state.operations.append(Paste())
        }
    }
    
    required init?(_ description: String) {
        if description == "st" {
            super.init()
        } else {
            return nil
        }
    }
}

// ps (tap store in the game)
class Paste: Append {
    
    override var description: String { "ps\(const)" }
    
    init() {
        super.init(-1)
    }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnary(target: "ps", value: description) {
            super.init(i)
        } else {
            return nil
        }
    }
}

// inv (inverse in the game)
class Inverse: Operation {
    
    override var description: String { "inv" }
    
    override func operate(num: Int) -> Int {
        let str = "\(num)"
        var result = ""
        for c in str {
            result += c == "-" ? "-" : String((10 - Int("\(c)")!) % 10)
        }
        return Int(result)!
    }
    
    required init?(_ description: String) {
        if description == "inv" {
            super.init()
        } else {
            return nil
        }
    }
}

// 1-0 (portals in the game)
// Count from right to left starting from 0
class Portal: Operation {
    
    let inPos: Int
    let outPos: Int
    
    init(inPos: Int, outPos: Int) {
        self.inPos = inPos
        self.outPos = outPos
        super.init()
    }
    
    required convenience init?(_ description: String) {
        if let (i, o) = Operation.parseBinary(sep: "-", value: description) {
            if o >= 0 && i > o {
                self.init(inPos: i, outPos: o)
                return
            }
        }
        return nil
    }
    
    override var description: String { "\(inPos)-\(outPos)" }
    
    override func operate(state: CalculatorTheGame) {
        var portaled = operate(num: state.current)
        while portaled != state.current {
            state.current = portaled
            portaled = operate(num: portaled)
        }
    }
    
    override func operate(num: Int) -> Int {
        let str = String(num.magnitude)
        if str.count <= inPos {
            return num
        }
        return num.signum() * processPortal(str)
    }
    
    func processPortal(_ str: String) -> Int {
        let pos = str.count - inPos - 1
        let first = str[str.startIndex ..< str[pos]]
        let d = str[str[pos]]
        let last = str[str[pos + 1] ..< str.endIndex]
        return Int(first + last)! + Int("\(d)")! * pow(10, outPos)!
    }
}
