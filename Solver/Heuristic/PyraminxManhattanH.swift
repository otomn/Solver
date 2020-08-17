//
//  PyraminxManhattanH.swift
//  Solver
//
//  Created by Toby on 2019-09-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

public final class PyraminxManhattanH: GameHeuristic{
    
    /// A lock for dictionary `visited`
    private var dicLock = NSLock()
    
    private var visited: [UInt64:Bool] = [:]
    
    public var supportMulThread: Bool = true
    
    public init?(game: GameState) {
        if !(game is Pyraminx) {
            print("Heuristic Cannot run on this game")
            return nil
        }
    }
    
    public func getScore(game: GameState, player: Int) -> Float {
        return getScore(game: game as! Pyraminx, player: player)
    }
    
    public func getScore(game: Pyraminx, player: Int) -> Float {
        return -game.faces.reduce(0) {
            result, face in
            result + face.tiles.reduce(0) { $0 + ($1 == face.id ? 0 : 1) }
        }
    }
    
    public func visit(game: GameState, cost: Int, register: Bool) -> Bool {
        let uid = getUid(game: game as! Pyraminx)
        dicLock.lock()
        defer {
            if register{
                visited[uid] = true
            }
            dicLock.unlock()
        }
        return visited[uid] ?? false
    }
    
    public func getUid(game: Pyraminx) -> UInt64{
        var uid: UInt64 = 0
        for i in 0 ... 3{
            uid += UInt64(game.faces[i].tiles.rawValue) << (i * 16)
        }
        return uid
    }
    
}
