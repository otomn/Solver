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
        let charCodes = input.uppercased().unicodeScalars.map{ $0.value - 65 }
        if charCodes.reduce(false, { $0 || $1 > 25 || $1 < 0 }){
            return nil
        }
        var result = 0
        for i in 0..<charCodes.count {
            result += pow(10, i)! * (Int(charCodes[i]) / 3 + 1)
        }
        return (result, true)
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
        Sort.self, ToChar.self,
        Cut.self, DeleteAt.self
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

// abc (does nothing in this modal)
class ToChar: Operation {
    override var description: String { "abc" }
    
    required init?(_ description: String) {
        if description != "abc" {
            return nil
        }
        super.init()
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

// delete
// Count from right to left starting from 0
class DeleteAt: Operation {
    override var description: String { "delete" + (const < 0 ? "" : "\(const)") }
    
    required override init(_ const: Int) {
        super.init(const)
    }
    
    required convenience init?(_ description: String) {
        if let s = Operation.parseUnaryString(target: "delete", value: description) {
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
                (0..<Operation.maxLen).map(DeleteAt.init))
        }
    }
}
