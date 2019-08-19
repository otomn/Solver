//
//  GussingGameH.swift
//  Solver
//
//  Created by Toby on 2019-08-12.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Heuristic for a GuessingGame
/// 
/// Score is the difference between lower bound and upper bound
///
/// Mainly for testing purpose
final public class GuessingGameH: GameHeuristic{
    
    public typealias ModelType = GuessingGame
    
    public func getScore(game: GuessingGame, player: Int) -> Float {
        return Float(game.minNum - game.maxNum)
    }
    
    public func isVisited(game: GuessingGame) -> Bool {
        return false
    }
    
}
