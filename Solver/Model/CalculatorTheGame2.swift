//
//  CalculatorTheGame2.swift
//  Solver
//
//  Created by Toby on 2020-07-25.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

final public class CalculatorTheGame2: CalculatorTheGame{
    
    public convenience init(value: Int, movesLeft: Int, goal: Int, ops: [String]){
        self.init(value: value, movesLeft: movesLeft, goal: goal, 
                  ops: ops.compactMap(Operation.parse2))
    }
    
    required public convenience init?(input: () -> String?) {
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
            parser: CalculatorTheGame2.parseGoal, 
            inputStream: input).first else { return nil }
        let ops = getInput(
            prompt: pure1("Operation: "), 
            failedMessage: "Invalid operation", 
            parser: Operation.parse2, 
            terminateCondition: { input, _ in input == "" },
            inputStream: input)
        self.init(value: initial, movesLeft: goal.1 ? maxMoves - 1 : maxMoves, 
                  goal: goal.0, ops: ops)
    }
    
    private static func parseGoal(input: String) -> (Int, Bool)? {
        if input.isEmpty {
            return nil
        }
        // just a number
        if let i = Int(input) {
            return (i, false)
        }
        // convert letters to number
        let charCodes = input.uppercased().unicodeScalars.map{ Int($0.value) - 65 }
        if charCodes.reduce(false, { $0 || $1 > 25 || $1 < 0 }){
            return nil
        }
        return (Int(charCodes.map{ "\($0 / 3 + 1)" }.joined()) ?? 0, true)
    }
    
    static func playLoop2() {
        while true {
            let input = { readLine() }
            guard let initial = getInput(
                prompt: pure1("Initial: "), 
                failedMessage: "Not a number", 
                parser: Int.init, 
                inputStream: input).first else { continue }
            guard let maxMoves = getInput(
                prompt: pure1("Moves: "), 
                failedMessage: "Not a number", 
                parser: Int.init, 
                inputStream: input).first else { continue }
            let goals = getInput(
                prompt: pure1("Goal: "), 
                failedMessage: "Invalid goal", 
                parser: CalculatorTheGame2.parseGoal, 
                terminateCondition: { input, _ in input == "" },
                inputStream: input)
            let ops = getInput(
                prompt: pure1("Operation: "), 
                failedMessage: "Invalid operation", 
                parser: Operation.parse2, 
                terminateCondition: { input, _ in input == "" },
                inputStream: input)
            for goal in goals {
                let game: GameState = CalculatorTheGame(value: initial, movesLeft:  goal.1 ? maxMoves - 1 : maxMoves, goal: goal.0, ops: ops)
                // CalculatorTheGameH is not designed to find all solutions
//                let heuristic = WinLoseH(game: game)!, allPaths = true
                let heuristic = CalculatorTheGameH(game: game)!, allPaths = false 
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
}

extension Operation{
    private static let operationSet2: [Operation.Type] = [
        Add.self, Subtract.self,
        Multiply.self, Divide.self,
        Append.self, Delete.self,
        Power.self, Sign.self,
        Replace.self, Reverse.self,
        Sum.self, Cut.self,
        ShiftLeft.self, ShiftRight.self,
        Mirror.self, Increment.self,
        Store.self, Paste.self,
        Inverse.self, Portal.self,
        SortInc.self, SortDesc.self,
        DeleteAt.self, InsertAt.self,
        Round.self, ShiftN.self,
        AddAt.self, SubtractAt.self,
        ReplaceAt.self, Lock.self
    ]
    
    static func parse2(_ description: String) -> Operation? {
        return parse(description: description, in: operationSet2)
    }
}

// sort< or sort> (sort< or sort> in the game)
class SortInc: Operation{
    override class var code: String { "sort<" }
    class var desc: Bool { false }
    
    override func operate(num: Int) -> Int {
        var str = "\(num.magnitude)".sorted()
        if Self.desc {
            str.reverse()
        }
        return num.signum() * (Int(String(str)) ?? 0)
    }
}

class SortDesc: SortInc{
    override class var code: String { "sort>" }
    override class var desc: Bool { true }
}

// cut0
class Cut: Replace {
    override var description: String { "cut\(const)" }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnaryString(target: "cut", value: description) {
            if let num = Int(i) {
                super.init(ori: i, target: "")
                const = num
                return
            }
        } 
        return nil
    }
    
    override func operate(num: Int) -> Int {
        ori = "\(const)"
        return super.operate(num: num)
    }
}

class OpAt: Operation{
    
    class var ommitAt: Bool { false }
    let pos: Int
    
    override var description: String {
        "\(Self.code)"
            + (const < 0 ? "" : "\(const)")
            + (pos < 0 ? (Self.ommitAt ? "" : "at") : "at\(pos)")
    }
    
    required init(const: Int, at pos: Int) {
        self.pos = pos
        super.init(const)
    }
    
    required convenience init?(_ description: String) {
        guard let constAtPos = 
            Operation.parseUnaryString(target: Self.code, value: description) else {
            return nil
        }
        let splited = 
            constAtPos.split(separatorString: "at", omittingEmptySubsequences: false)
        if splited.count > 2 || splited.count == 1 && !Self.ommitAt {
            return nil
        }
        let constStr = splited[0]
        let posStr = splited.count == 1 ? "" : splited[1]
        let const = Int(constStr) ?? -1
        let pos = Int(posStr) ?? -1
        if const < 0 && (!Self.noConst || constStr != "")
            || pos < 0 && posStr != "" {
            return nil
        }
        self.init(const: const, at: pos)
    }
    
    override func operate(num: Int) -> Int {
        let s = "\(num)"
        let idxAfter = s.count - pos
        let idxBefore = idxAfter - 1
        if idxAfter < 0 {
            return Operation.error
        }
        var front = ""
        var digit = ""
        let back = String(s[s[idxAfter] ..< s.endIndex])
        if idxBefore >= 0 {
            front = String(s[s.startIndex ..< s[idxBefore]])
            digit = String(s[s[idxBefore] ..< s[idxAfter]])
        }
        return operate(front: front, digit: digit, back: back)
    }
    
    func operate(front: String, digit: String, back: String) -> Int {
        guard let digitNum = Int(digit) else {
            return Operation.error
        }
        let digitResult = (Self.op(digitNum, const) % 10 + 10) % 10
        return Int("\(front)\(digitResult)\(back)") ?? Operation.error
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if pos == -1 {
            state.operations.removeAll{ $0 is Self && $0.const == const}
            state.operations.append(contentsOf: 
                (0 ..< Operation.maxLen).map{ Self.init(const: const, at: $0) })
        }
    }
}

// input as d
// steps shown as dat1
// delete in the game
// Count from right to left starting from 0
class DeleteAt: OpAt {
    
    override class var ommitAt: Bool { true }
    override class var noConst: Bool { true }
    override class var code: String { "d" }
    
    override func operate(front: String, digit: String, back: String) -> Int {
        return digit == "" ? Operation.error : Int(front + back) ?? 0
    }
}

// input as i2
// steps shown as i2at2 as insert 2 at position 2
// insert 2 in the game
// Count from right to left starting from 0
class InsertAt: OpAt{
    
    override class var ommitAt: Bool { true }
    override class var code: String { "i" }
    
    override func operate(front: String, digit: String, back: String) -> Int {
        return Int(front + digit + "\(const)" + back) ?? Operation.error
    }
}

class Round: Operation{
    
    override var description: String { "round" + (const < 0 ? "" : "\(const)") }
    
    required convenience init?(_ description: String) {
        if let s = Operation.parseUnaryString(target: "round", value: description) {
            if s == "" {
                self.init(-1)
                return
            }
            if let i = Int(s) {
                self.init(i)
                return
            }
        }
        return nil
    }
    
    override func operate(num: Int) -> Int {
        guard let base = pow(10, const) else {
            return Operation.error
        }
        if num < base {
            return Operation.error
        }
        return num / base * base + ((num % base >= base / 2) ? base : 0)
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if const == -1 {
            state.operations.removeAll(where: { $0 is Round })
            state.operations.append(contentsOf: 
                (1 ..< Operation.maxLen).map(Round.init))
        }
    }
}

class AddAt: OpAt{
    override class var op: (Int, Int) -> Int { (+) }
    override class var code: String { "+" }
}

class SubtractAt: OpAt{
    override class var op: (Int, Int) -> Int { (-) }
    override class var code: String { "-" }
}

class ShiftN: ShiftLeft{
    
    override var description: String { "shift" + (const < 0 ? "" : "\(const)") }
    
    required convenience init(pos: Int) {
        self.init()
        self.const = pos
    }
    
    required convenience init?(_ description: String) {
        if let s = Operation.parseUnaryString(target: "shift", value: description) {
            let pos = Int(s) ?? -1
            if pos < 0 && s != "" {
                return nil
            }
            self.init(pos: pos)
        } else {
            return nil
        }
    }
    
    override func operate(num: Int) -> Int {
        if const >= "\(num)".count {
            return Operation.error
        }
        return (0 ..< const).reduce(num){ n,_ in super.operate(num: n) }
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if const == -1 {
            state.operations.removeAll(where: { $0 is ShiftN })
            state.operations.append(contentsOf: 
                (0 ..< Operation.maxLen).map(ShiftN.init))
        }
    }
}

class ReplaceAt: OpAt{
    override class var ommitAt: Bool { true }
    override class var code: String { "r" }
    
    override func operate(front: String, digit: String, back: String) -> Int {
        return digit == "" ? Operation.error : 
            Int(front + "\(const)" + back) ?? Operation.error
    }
}

class Lock: ReplaceAt{
    override class var ommitAt: Bool { true }
    override class var noConst: Bool { true }
    override class var code: String { "lock" }
    
    // Create a copy of self with const being the digit
    override func operate(state: CalculatorTheGame) {
        let s = "\(state.current)"
        let idx = s.count - pos - 1
        if idx < 0 || const >= 0 { // if const is not none, do not process
            state.current = Operation.error
            return
        }
        let digit = Int("\(s[s[idx] ..< s[idx + 1]])")!
        state.operations.append(Self.init(const: digit, at: pos))
    }
    
    override func postOperate(state: CalculatorTheGame) {
        if const >= 0 && state.current != Operation.error {
            state.operations.removeAll{ $0 is Self && $0.const != -1 }
            let placeHolder = pow(10, Operation.maxLen)!
            state.current = (state.current.signum() < 0 ? -1 : 1) * 
                (operate(num: placeHolder + Int(state.current.magnitude)) - placeHolder)
        }
    }
}
