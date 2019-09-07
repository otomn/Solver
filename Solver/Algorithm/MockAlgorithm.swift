//
//  MockAlgorithm.swift
//  Solver
//
//  Created by Toby on 2019-08-14.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation


/// A mock algorhtm for testing
///
/// The public init will define all the moves
public final class MockAlgorithm: GameAlgorithm{
    
    var moveCount = 0
    var moves: [String]
    
    public init?(game: GameState) {
        return nil
    }
    
    public init?(game: GameState, input: () -> String?) {
        return nil
    }
    
    public init(moves: [String]) {
        self.moves = moves
    }
    
    public func makeMove<T>(_ game: T) -> T? where T : GameState {
        return makeMove(game as GameState) as! T?
    }
    
    public func makeMove(_ game: GameState) -> GameState? {
        defer {
            moveCount += 1
        }
        return game.move(move: moves[moveCount])
    }
    
}
