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
    
    public var moves: [String]
    
    public var winners: [Int]? {
        return goal == current ? [0] : nil
    }
    
    public var description: String {
        return "\(current)"
    }
    
    var initial: Int
    var movesTaken: Int = 0
    var maxMoves: Int
    var goal: Int
    var current: Int
    var operations: [Operation] = []
    var portal = Portal(inPos: Int.max, outPos: 0)
    
    static let maxLen = 7
    static let error = Int.max
    
    public convenience init(initial: Int, maxMoves: Int, goal: Int, 
                            ops: [String]) {
        self.init(initial: initial, maxMoves: maxMoves, goal: goal, 
                  ops: ops.compactMap(CalculatorTheGame.getOperation))
    }
    
    init(initial: Int, maxMoves: Int, goal: Int, ops: [Operation]) {
        self.initial = initial;
        self.maxMoves = maxMoves;
        self.goal = goal;
        self.current = initial;
        self.operations = ops
        self.moves = []
        for op in ops {
            if let port = op as? Portal {
                portal = port
                continue
            }
            self.moves.append("\(op)")
            if op is Store {
                self.moves.append("\(Paste(op.const))")
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
            parser: CalculatorTheGame.getOperation, 
            terminateCondition: { input, parsed in input == "" },
            inputStream: input)
        self.init(initial: initial, maxMoves: maxMoves, goal: goal, ops: ops)
    }
    
    public func playerSymbol(player: Int) -> String? {
        return "Player"
    }
    
    public func move(player: Int, move: String) -> CalculatorTheGame? {
        if !isValidMove(move: move) { 
            return nil
        }
        guard let op = CalculatorTheGame.getOperation(input: move) else {
            return nil
        }
        let newState = CalculatorTheGame(initial: initial, maxMoves: maxMoves, goal: goal, ops: operations)
        newState.movesTaken = movesTaken + (op is Store ? 0 : 1)
        if newState.movesTaken > newState.maxMoves {
            return nil
        }
        var num = op.operate(current)
        if num == CalculatorTheGame.error {
            return nil
        }
        var portaled = portal.operate(num)
        while portaled != num {
            num = portaled
            portaled = portal.operate(num)
        }
        newState.current = num
        if op is Increment {
            for o in newState.operations {
                if !(o is Increment){
                    o.const += op.const
                }
            }
        }
        return newState
    }
    
    class Operation: CustomStringConvertible {
        
        var description: String {
            return ""
        }
        
        var const: Int
        
        init() {
            const = 0
        }
        
        init(_ const: Int) {
            self.const = const
        }
        
        func operate(_ num: Int) -> Int {
            return num
        }
    }
    
    // /1
    class Divide: Operation{
        
        override var description: String {
            return "/\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            if num % const != 0 {
                return error
            }
            return num / const
        }
    }

    // *1
    class Multiply: Operation{
        
        override var description: String {
            return "*\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            return num * const
        }
    }

    // +1
    class Add: Operation{
        
        override var description: String {
            return "+\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            return num + const
        }
    }

    // -1
    class Subtract: Operation{
        
        override var description: String {
            return "-\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            return num - const
        }
        
    }

    // <<
    class Delete: Operation{
        
        override var description: String {
            return "<<"
        }
        
        override func operate(_ num: Int) -> Int {
            var str = String(num)
            str.removeLast()
            return Int(str) ?? 0
        }
        
    }

    // 1
    class Append: Operation{
        
        override var description: String {
            return "\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            let str = String(num) + String(const)
            return str.count > maxLen ? error : Int(str)!
        }
        
    }

    // ^1 (x^1 in the game)
    class Power: Operation{
        
        override var description: String {
            return "^\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            let result = pow(Double(num), Double(const))
            return result.magnitude > Double(Int.max) ? error : Int(result)
        }
        
    }

    // +- (+/- in the game)
    class Sign: Operation{
        
        override var description: String {
            return "+-"
        }
        
        override func operate(_ num: Int) -> Int {
            return -num
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
        
        override var description: String {
            return "\(ori)>\(target)"
        }
        
        override func operate(_ num: Int) -> Int {
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
        
        override func operate(_ num: Int) -> Int {
            return Int(String("\(num.magnitude)".reversed()))! * num.signum()
        }
        
    }

    // sum
    class Sum: Operation{
        
        override var description: String {
            return "sum"
        }
        
        override func operate(_ num: Int) -> Int {
            var sum = 0
            for i in "\(num)" {
                sum += Int("\(i)") ?? 0
            }
            return num.signum() * sum
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
        
        override func operate(_ num: Int) -> Int {
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
        
        override func operate(_ num: Int) -> Int {
            let str = "\(num)" + String("\(num.magnitude)".reversed())
            return str.count > maxLen ? error : Int(str)!
        }
        
    }

    // ++ ([+] in the game)
    class Increment: Operation {
        
        override var description: String {
            return "++\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            return num
        }
        
    }

    // st (hold store in the game)
    class Store: Operation {
        
        override var description: String {
            return const == error ? "st" : "st\(const)"
        }
        
        override func operate(_ num: Int) -> Int {
            let mag = Int(num.magnitude)
            if mag == const {
                return error
            }
            const = mag
            return num
        }
        
    }

    // ps (tap store in the game)
    class Paste: Append {
        
        override var description: String {
            return "ps\(const)"
        }
        
    }

    // inv (inverse in the game)
    class Inverse: Operation {
        
        override var description: String {
            return "inv"
        }
        
        override func operate(_ num: Int) -> Int {
            let str = "\(num)"
            var result = ""
            for c in str {
                result += c == "-" ? "-" : String((10 - Int("\(c)")!) % 10)
            }
            return Int(result)!
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
        
        override var description: String {
            return "\(inPos)-\(outPos)"
        }
        
        override func operate(_ num: Int) -> Int {
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
    
    static func getOperation(input: String) -> Operation?{
        var str = input
        if str == "" {
            return nil
        }
        switch str {
        case "<<":
            return Delete()
        case "+-":
            return Sign()
        case "r":
            return Reverse()
        case "sum":
            return Sum()
        case "m":
            return Mirror()
        case "inv":
            return Inverse()
        default:
            break;
        }
        switch str.first!{
        case "+":
            str.removeFirst()
            if str.first! == "+" {
                str.removeFirst()
                return Increment(Int(str) ?? 0)
            }
            return Add(Int(str) ?? 0)
        case "-":
            str.removeFirst()
            return Subtract(Int(str) ?? 0)
        case "*":
            str.removeFirst()
            return Multiply(Int(str) ?? 0)
        case "/":
            str.removeFirst()
            return Divide(Int(str) ?? 0)
        case "^":
            str.removeFirst()
            return Power(Int(str) ?? 0)
        case "<":
            return Shift(shiftLeft: true)
        case ">":
            return Shift(shiftLeft: false)
        case "s":
            str.removeFirst()
            if str == "t" {
                return Store(CalculatorTheGame.error)
            }
            if str == "" {
                return nil
            }
            str.removeFirst()
            return Store(Int(str) ?? 0)
        default:
            if let num = Int(str) {
                return Append(num)
            } else if str.contains(">"){
                let splited = str.split(separator: ">")
                if splited.count == 2 {
                    return Replace(ori: String(splited[0]),
                                   target: String(splited[1]))
                }
            } else if str.contains("-"){
                let splited = str.split(separator: "-")
                if splited.count == 2 {
                    return Portal(inPos: Int(splited[0]) ?? CalculatorTheGame.error,
                                    outPos: Int(splited[1]) ?? 0)
                }
            }
        }
        return nil
    }
    
    static func playLoop() {
        while true {
            let game: GameState = CalculatorTheGame(input: { readLine() })!
            let algorithm = BFS(game: game, 
                heuristic: WinLoseH(game: game)!)
            algorithm.computePath(game: game)
            print(algorithm.path)
        }
    }
}
