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
/// Number of players: > 0
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
        return minNum > maxNum ? [player] : nil
    }
    
    public var description: String {
        return "\(minNum)...\(maxNum)"
    }
    
    init(playerSymbols: [String], min: Int, max: Int, num: Int) {
        self.playerSymbols = playerSymbols
        minNum = min
        maxNum = max
        theNum = num
    }
    
    public convenience init?(input: () -> String?) {
        print("Begin recording player symbols")
        print("If finished, input empty string")
        let symbols = getInput(
            prompt: { return "Please type symbol for player \($0.count + 1): " },
            failedMessage: "",
            parser: pure,
            terminateCondition: {input, _ in input.isEmpty },
            inputStream: input
            ).dropLast()
        if symbols.isEmpty {
            print("No enough players")
            return nil
        }
        guard let min = getInput(
            prompt: pure1("Minimum number: "),
            failedMessage: "Must be an integer",
            parser: Int.init,
            inputStream: input
            ).first else { return nil }
        guard let max: Int = getInput(
            prompt: pure1("Maximum number: "),
            failedMessage: "Must be an interger greater than \(min)",
            parser: {
                if let i = Int($0) {
                    if i > min { return i }
                }
                return nil
            },
            inputStream: input
            ).first else { return nil }
        guard let num: Int = getInput(
            prompt: pure1("The goal number: "),
            failedMessage: "Must be an interger between \(min) and \(max)",
            parser: {
                if let i = Int($0) {
                    if i >= min && i <= max { return i }
                }
                return nil
            },
            inputStream: input
            ).first else { return nil }
        self.init(playerSymbols: Array(symbols), min: min, max: max, num: num)
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
    
    public func move(player: Int, move: String) -> GuessingGame? {
        if !isValidMove(move: move) || player != self.player { return nil }
        guard let num = Int(move) else { return nil }
        var max = maxNum
        var min = minNum
        var nextPlayer = (player + 1) % numPlayer
        if num == theNum {
            max = theNum - 1
            min = theNum + 1
            nextPlayer -= 1
        } else if num < theNum {
            min = num + 1
        } else {
            max = num - 1
        }
        let newState = GuessingGame(playerSymbols: playerSymbols,
                                   min: min, max: max, num: theNum)
        newState.player = nextPlayer
        return newState
    }
    
}
