//
//  CalculatorTheGame.swift
//  Solver
//
//  Created by Toby on 2020-07-19.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

final public class CalculatorTheGame: GameState{
    
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
    
    init(value: Int, movesLeft: Int, goal: Int, ops: [Operation]) {
        self.current = value;
        self.movesLeft = movesLeft;
        self.goal = goal;
        self.operations = ops
        if !ops.reduce(false, { $0 || $1 is Paste })
            && ops.reduce(false, { $0 || $1 is Store }){
            operations.append(Paste())
        }
        for op in ops {
            if let port = op as? Portal {
                portal = port
                break
            }
        }
    }
    
    public convenience init?(input: () -> String?) {
        guard let initial = getInput(
            prompt: pure1("Initial: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            terminateCondition: pure2(true),
            inputStream: input).first else { return nil }
        guard let maxMoves = getInput(
            prompt: pure1("Moves: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            terminateCondition: pure2(true),
            inputStream: input).first else { return nil }
        guard let goal = getInput(
            prompt: pure1("Goal: "), 
            failedMessage: "Not a number", 
            parser: Int.init, 
            terminateCondition: pure2(true),
            inputStream: input).first else { return nil }
        let ops = getInput(
            prompt: pure1("Operation: "), 
            failedMessage: "Invalid operation", 
            parser: Operation.parse, 
            terminateCondition: { input, parsed in input == "" },
            inputStream: input)
        self.init(value: initial, movesLeft: maxMoves, goal: goal, ops: ops)
    }
    
    public func playerSymbol(player: Int) -> String? {
        return "Player"
    }
    
    public func move(player: Int, move: String) -> CalculatorTheGame? {
        if !isValidMove(move: move) { 
            return nil
        }
        guard let op = operations.first(where: { "\($0)" == move }) else {
            return nil
        }
        let newOps = operations.map{ $0.copy() }
        let newState = CalculatorTheGame(
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
            let algorithm = BFS(game: game, 
                heuristic: CalculatorTheGameH(game: game)!)
            let start = Date()
            algorithm.computePath(game: game)
            let end = Date()
            print(end.timeIntervalSince(start))
            print(algorithm.path)
        }
    }
}

protocol OperationP: LosslessStringConvertible {
    func operate(state: CalculatorTheGame)
    func operate(num: Int) -> Int
    static func parse(_ description: String) -> Operation?
}

class Operation: OperationP {
    
    var description: String {
        return ""
    }
    
    var const: Int
    static let maxLen = 7
    static let error = Int.max
    
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
    
    func copy() -> Operation {
        return Self.init(description)!
    }
    
    static func parse(_ description: String) -> Operation?{
        let allSubClasses = [
            Add.self, Subtract.self,
            Multiply.self, Divide.self,
            Append.self, Delete.self,
            Power.self, Sign.self,
            Replace.self, Reverse.self,
            Sum.self, Shift.self,
            Mirror.self, Increment.self,
            Store.self, Paste.self,
            Inverse.self, Portal.self
        ] as [Operation.Type]
        for c in allSubClasses {
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
    
    static func parseBinaryString(sep: Character, value: String)
        -> (String, String)?{
        let splited = value.split(separator: sep).map(String.init)
        if splited.count == 2 {
            return (splited[0], splited[1])
        }
        return nil
    }
    
    static func parseBinary(sep: Character, value: String)
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
    
    override var description: String {
        return "/\(const)"
    }
    
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
    
    override var description: String {
        return "*\(const)"
    }
    
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
    
    override var description: String {
        return "+\(const)"
    }
    
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
    
    override var description: String {
        return "-\(const)"
    }
    
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
    
    override var description: String {
        return "<<"
    }
    
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
    
    override var description: String {
        return "\(const)"
    }
    
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
    
    override var description: String {
        return "^\(const)"
    }
    
    override func operate(num: Int) -> Int {
        let result = pow(Double(num), Double(const))
        return result.magnitude >= Double(Int.max) ? Operation.error : Int(result)
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
    
    override var description: String {
        return "+-"
    }
    
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
        if let p = Operation.parseBinaryString(sep: ">", value: description) {
            self.init(ori:p.0, target: p.1)
        } else {
            return nil
        }
    }
    
    override var description: String {
        return "\(ori)>\(target)"
    }
    
    override func operate(num: Int) -> Int {
        let key = ori
        var str = "\(num)"
        var result = ""
        while str != "" {
            if findMatch(str: str){
                let start = str[key.count]
                let end = str.endIndex
                str = String(str[start ..< end])
                result.append(target)
            } else {
                result.append(str.removeFirst())
            }
        }
        return Int(result)!
    }
    
    func findMatch(str: String) -> Bool {
        let key = ori
        if str.count < key.count {
            return false
        }
        let start = str.startIndex
        let end = str.index(str.startIndex, offsetBy: key.count)
        return str[start ..< end] == key
    }
}

// r (Reverse in the game)
class Reverse: Operation{
    
    override var description: String {
        return "r"
    }
    
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
    
    override var description: String {
        return "sum"
    }
    
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
    
    override var description: String {
        return left ? "<" : ">"
    }
    
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
    
    override var description: String {
        return "m"
    }
    
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
    
    override var description: String {
        return "++\(const)"
    }
    
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
    
    override var description: String {
        return "st"
    }
    
    override func operate(state: CalculatorTheGame) {
        state.operations.forEach{ if $0 is Paste { $0.const = state.current } }
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
    
    override var description: String {
        return "ps\(const)"
    }
    
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
    
    override var description: String {
        return "inv"
    }
    
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
class Portal: Operation {
    
    let inPos: Int
    let outPos: Int
    
    init(inPos: Int, outPos: Int) {
        self.inPos = inPos
        self.outPos = outPos
        super.init()
    }
    
    required convenience init?(_ description: String) {
        if let p = Operation.parseBinary(sep: "-", value: description) {
            self.init(inPos: p.0, outPos: p.1)
        } else {
            return nil
        }
    }
    
    override var description: String {
        return "\(inPos)-\(outPos)"
    }
    
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
        let first = str[str[0]..<str[pos]]
        let d = str[str[pos]]
        let last = str[str[pos + 1]...str[str.count - 1]]
        return Int(first + last)! + Int("\(d)")! * pow10(mag: outPos)
    }
    
    func pow10(mag: Int) -> Int {
        var result = "1"
        for _ in 0 ..< mag {
            result += "0"
        }
        return Int(result)!
    }
}
