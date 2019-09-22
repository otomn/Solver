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
    
    public var supportMulThread: Bool = true
    
    public init?(game: GameState) {
        if !(game is GuessingGame) {
            print("Cannot run on this game")
            return nil
        }
    }
    
    public func getScore(game: GameState, player: Int) -> Float {
        return getScore(game: game as! GuessingGame, player: player)
    }
    
    public func getScore(game: GuessingGame, player: Int) -> Float {
        return Float(game.minNum - game.maxNum)
    }
    
    public func isVisited(uid: [UInt64]) -> Bool {
        return false
    }
    
    public func visit(uid: [UInt64]) -> Bool {
        return false
    }
    
    public func getUid(game: GameState) -> [UInt64] {
        return []
    }
    
}
