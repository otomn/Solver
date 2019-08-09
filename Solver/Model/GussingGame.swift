//
//  GussingGame.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

final class GussingGame: GameState {
    
    private(set) var player: Int = 0
    let playerSymbols: [String]
    var minNum: Int
    var maxNum: Int
    let theNum: Int
    var numPlayer: Int {
        return playerSymbols.count
    }
    
    init(playerSymbols: [String], min: Int, max: Int, num: Int) {
        precondition(!playerSymbols.isEmpty, "Number of Players must be positive")
        precondition(min <= num, "num must be greater than or equal to min")
        precondition(num <= max, "num must be less than or equal to max")
        self.playerSymbols = playerSymbols
        minNum = min
        maxNum = max
        theNum = num
    }
    
    convenience init?() {
        print("Begin recording player symbols")
        print("If finished, input empty string")
        var count = 0
        let symbols = getInput(
            prompt: {
                count += 1
                return "Please type symbol for player \(count): "
            },
            failedMessage: "",
            parser: pure,
            terminateCondition: { $0.isEmpty }).dropLast()
        if symbols.isEmpty {
            print("No enough players")
            return nil
        }
        guard let min = getInput(
            prompt: pure0("Minimum number: "),
            failedMessage: "Must be an integer",
            parser: Int.init,
            terminateCondition: pure1(true)).first else { return nil }
        guard let max: Int = getInput(
            prompt: pure0("Maximum number: "),
            failedMessage: "Must be an interger greater than \(min)",
            parser: {
                if let i = Int($0) {
                    if i > min { return i }
                }
                return nil
            },
            terminateCondition: pure1(true)).first else { return nil }
        guard let num: Int = getInput(
            prompt: pure0("The goal number: "),
            failedMessage: "Must be an interger between \(min) and \(max)",
            parser: {
                if let i = Int($0) {
                    if i >= min && i <= max { return i }
                }
                return nil
            },
            terminateCondition: pure1(true)).first else { return nil }
        self.init(playerSymbols: Array(symbols), min: min, max: max, num: num)
    }
    
    func playerSymbol() -> String {
        return playerSymbol(player: player)!
    }
    
    func playerSymbol(player: Int) -> String? {
        return player < playerSymbols.count ? playerSymbols[player] : nil
    }
    
    func moves() -> [String] {
        return Array(minNum...maxNum).map(String.init)
    }
    
    func isValidMove(move: String) -> Bool {
        if let num = Int(move) {
            return num <= maxNum && num >= minNum
        }
        return false
    }
    
    func move(move: String) -> GussingGame? {
        return self.move(player: player, move: move)
    }
    
    func move(player: Int, move: String) -> GussingGame? {
        if !isValidMove(move: move) || player != self.player { return nil }
        guard let num = Int(move) else { return nil }
        var max = maxNum
        var min = minNum
        if num == theNum {
            max = theNum
            min = theNum
        } else if num < theNum {
            min = num + 1
        } else {
            max = num - 1
        }
        let newState = GussingGame(playerSymbols: playerSymbols,
                                   min: min, max: max, num: theNum)
        newState.player = (player + 1) % numPlayer
        return newState
    }
    
    func winners() -> [Int]? {
        return minNum == maxNum ? [player] : nil
    }
    
    var description: String {
        return "\(minNum)...\(maxNum)"
    }
    
}
