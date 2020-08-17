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
                let heuristic = WinLoseH(game: game)!, allPaths = true
//                let heuristic = CalculatorTheGameH(game: game)!, allPaths = false 
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
        Sum.self, Shift.self,
        Mirror.self, Increment.self,
        Store.self, Paste.self,
        Inverse.self, Portal.self,
        Sort.self, Cut.self,
        DeleteAt.self, InsertAt.self
    ]
    
    static func parse2(_ description: String) -> Operation? {
        return parse(description: description, in: operationSet2)
    }
}

// sort< or sort> (sort< or sort> in the game)
class Sort: Operation{
    
    var desc: Bool
    
    init(desc: Bool) {
        self.desc = desc
        super.init()
    }
    
    override var description: String { desc ? "sort<" : "sort>" }
    
    required convenience init?(_ description: String) {
        if description == "sort<" {
            self.init(desc: true)
        } else if description == "sort>" {
            self.init(desc: false)
        } else {
            return nil
        }
    }
    
    override func operate(num: Int) -> Int {
        var str = "\(num.magnitude)".sorted()
        if desc {
            str.reverse()
        }
        return num.signum() * (Int(String(str)) ?? 0)
    }
    
}

// cut0
class Cut: Replace {
    override var description: String { "cut\(ori)" }
    
    required init?(_ description: String) {
        if let i = Operation.parseUnaryString(target: "cut", value: description) {
            if Int(i) != nil {
                super.init(ori: i, target: "")
                return
            }
        } 
        return nil
    }
}

// input as d
// steps shown as d1
// delete 1 in the game
// Count from right to left starting from 0
class DeleteAt: Operation {
    override var description: String { "d" + (const < 0 ? "" : "\(const)") }
    
    required override init(_ const: Int) {
        super.init(const)
    }
    
    required convenience init?(_ description: String) {
        if let s = Operation.parseUnaryString(target: "d", value: description) {
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
        var s = "\(num)"
        if s.count > const {
            s.remove(at: s[s.count - const - 1])
            return Int(s) ?? Operation.error
        }
        return Operation.error
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if const == -1 {
            state.operations.removeAll(where: { $0 is DeleteAt })
            state.operations.append(contentsOf: 
                (0 ..< Operation.maxLen).map(DeleteAt.init))
        }
    }
}

// input as i2
// steps shown as i2at2 as insert 2 at position 2
// insert 2 in the game
// Count from right to left starting from 0
class InsertAt: Operation{
    
    let pos: Int
    
    override var description: String {
        "i\(const)" + (pos < 0 ? "" : "at\(pos)")
    }
    
    init(insert const: Int, at pos: Int){
        self.pos = pos
        super.init(const)
    }
    
    required convenience init?(_ description: String) {
        guard let constAtPos = 
            Operation.parseUnaryString(target: "i", value: description) else {
            return nil
        }
        if let const = Int(constAtPos) {
            self.init(insert: const, at: -1)
            return
        }
        if let (const, pos) = Operation.parseBinary(sep: "at", value: constAtPos){
            self.init(insert: const, at: pos)
            return
        }
        return nil
    }
    
    override func operate(num: Int) -> Int {
        let s = "\(num)"
        if s.count >= pos {
            let front = s[s.startIndex ..< s[s.count - pos]]
            let back = s[s[s.count - pos] ..< s.endIndex ]
            return Int(String(front + "\(const)" + back)) ?? Operation.error
        }
        return Operation.error
    }
    
    override func parseExpand(state: CalculatorTheGame) {
        if pos == -1 {
            state.operations.removeAll{ $0 is InsertAt && $0.const == const }
            state.operations.append(contentsOf: 
                (0 ..< Operation.maxLen).map{ InsertAt.init(insert: const, at: $0) })
        }
    }
}
