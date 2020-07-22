//
//  WinLoseH.swift
//  Solver
//
//  Created by Toby on 2019-08-13.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation


/// General heuristic that can be applied to all games
///
/// If game is not over, score is 0
///
/// If game has no winner, score is 0
///
/// If player is not a winner, score is -1
///
/// Otherwise score is (#players - #winners) / (#players - 1),
/// such that if everyone wins the score is 0, 
/// if player is the only winner the score is 1
///
/// - Warning: isVisited is always false
public final class WinLoseH: GameHeuristic{
    
    public var supportMulThread: Bool = true
    
    public init?(game: GameState) { }
    
    public func getScore(game: GameState, player: Int) -> Float {
        guard let winners = game.winners else { return 0 }
        if winners.isEmpty { return 0 }
        if !winners.contains(player) { return -1 }
        return Float(game.numPlayer - winners.count) / Float(game.numPlayer - 1)
    }
    
    public func visit(game: GameState, cost: Int, register: Bool) -> Bool {
        return false
    }
    
}
