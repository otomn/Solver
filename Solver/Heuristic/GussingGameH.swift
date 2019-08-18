//
//  GussingGameH.swift
//  Solver
//
//  Created by Toby on 2019-08-12.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

final public class GussingGameH: GameHeuristic{
    
    public typealias ModelType = GussingGame
    
    public func getScore(game: GussingGame, player: Int) -> Float {
        return Float(game.minNum - game.maxNum)
    }
    
    public func isVisited(game: GussingGame) -> Bool {
        return false
    }
    
}
