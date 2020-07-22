//
//  CalculatorTheGameH.swift
//  Solver
//
//  Created by Toby on 2020-07-21.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

public final class CalculatorTheGameH: GameHeuristic {
    
    /// A lock for dictionary `visited`
    private var dicLock = NSLock()
    
    private var visited: [String:Int] = [:]
    
    public var supportMulThread: Bool = true
    
    public init?(game: GameState) {
        if !(game is CalculatorTheGame) {
            print("Heuristic Cannot run on this game")
            return nil
        }
    }
    
    public func getScore(game: GameState, player: Int) -> Float {
        return game.winners == nil ? 0 : 1
    }
    
    public func visit(game: GameState, cost: Int, register: Bool) -> Bool {
        var uid = getUid(game: game as! CalculatorTheGame)
        dicLock.lock()
        defer {
            if register {
                visited[uid] = cost
            }
            dicLock.unlock()
        }
        if let pastCost = visited[uid] {
            return pastCost <= cost
        }
        return false
    }
    
    public func getUid(game: CalculatorTheGame) -> String{
        return game.moves.reduce("\(game.current)"){ $0 + "\($1)" }
    }
}
