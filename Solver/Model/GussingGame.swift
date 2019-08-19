//
//  GussingGame.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// A gussing game model
///
/// Number of players: >0
///
/// Game starts with an upper bound, a lower bound, and a secret number
///
/// Players take turns to guess the secret number
/// 
/// If the guessed number is the secret number, the player wins
///
/// If the guessed number is lower than the secret number, 
/// the lower bound will be set to the guessed number plus one
///
/// If the guessed number if higher than the secret number,
/// the upper bound will be set to the guessed number minus one
final public class GuessingGame: GameState {
    
    private(set) public var player: Int = 0
    
    let playerSymbols: [String]
    
    var minNum: Int
    
    var maxNum: Int
    
    let theNum: Int
    
    public var numPlayer: Int {
        return playerSymbols.count
    }
    
    public var moveDescription: String{
        return "\(minNum) - \(maxNum)"
    }
    
    public var moves: [String]{
        return Array(minNum...maxNum).map(String.init)
    }
    
    public var winners: [Int]? {
        return minNum == maxNum ? [player] : nil
    }
    
    public var description: String {
        return "\(minNum)...\(maxNum)"
    }
    
    init(playerSymbols: [String], min: Int, max: Int, num: Int) {
        assert(!playerSymbols.isEmpty, "Number of Players must be positive")
        assert(min <= num, "num must be greater than or equal to min")
        assert(num <= max, "num must be less than or equal to max")
        self.playerSymbols = playerSymbols
        minNum = min
        maxNum = max
        theNum = num
    }
    
    public convenience init?() {
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
    
    public func playerSymbol() -> String {
        return playerSymbol(player: player)!
    }
    
    public func playerSymbol(player: Int) -> String? {
        return player < playerSymbols.count ? playerSymbols[player] : nil
    }
    
    public func isValidMove(move: String) -> Bool {
        if let num = Int(move) {
            return num <= maxNum && num >= minNum
        }
        return false
    }
    
    public func move(move: String) -> GuessingGame? {
        return self.move(player: player, move: move)
    }
    
    public func move(player: Int, move: String) -> GuessingGame? {
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
        let newState = GuessingGame(playerSymbols: playerSymbols,
                                   min: min, max: max, num: theNum)
        newState.player = (player + 1) % numPlayer
        return newState
    }
    
}
