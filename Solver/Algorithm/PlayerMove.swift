//
//  PlayerMove.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Ask the user to make a move through standard input
final class PlayerMove: GameAlgorithm{
    
    init?(game: GameState) { }
    
    init?(game: GameState, input: () -> String?) { }
    
    func makeMove<T>(_ game: T) -> T? where T : GameState {
        return makeMove(game as GameState) as! T?
    }
    
    func makeMove(_ game: GameState) -> GameState? {
        if let move = getInput(
            prompt: pure1("""
            \(game.moveDescription)
            \(game.playerSymbol()) move: 
            """) ,
            failedMessage: "Invalid move",
            parser: { game.isValidMove(move: $0) ? $0 : nil },
            terminateCondition: pure2(true)
            ).first {
            return game.move(move: move)
        }
        return nil
    }
    
}
