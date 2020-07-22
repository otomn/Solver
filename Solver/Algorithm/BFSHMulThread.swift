//
//  BFS.swift
//  Solver
//
//  Created by Toby on 2019-09-08.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Don't run this in the editor
public final class BFSHMulThread: GameAlgorithm{
    
    var depth: Int
    var path: [String] = []
    let heuristic: GameHeuristic
    var isRunning = true
    let pathLock = NSLock()
    let group = DispatchGroup()
    
    public init?(game: GameState, input: () -> String?) {
        guard let depth = getInput(
            prompt: pure1("Please type max search depth: "), 
            failedMessage: "Invalid number", 
            parser: Int.init, 
            terminateCondition: pure2(true),
            inputStream: input).first else { return nil }
        self.depth = depth
        
        guard let heuristicType: GameHeuristic.Type = getInput(
            prompt: pure1("Please type a heuristic name: "),
            failedMessage: "Cannot find the heuristic",
            parser: Main.findClass,
            terminateCondition: pure2(true),
            inputStream: input
            ).first else { return nil }
        guard let heuristic = heuristicType.init(game: game) else {
            return nil
        }
        self.heuristic = heuristic
    }
    
    public init(game: GameState, heuristic: GameHeuristic) {
        depth = Int.max
        self.heuristic = heuristic
    }
    
    public func makeMove(_ game: GameState) -> GameState? {
        if path.isEmpty || !game.isValidMove(move: path[0]){
            computePath(game: game)
            if path.isEmpty || !game.isValidMove(move: path[0]){
                print("No result")
                return nil
            }
            print(path)
        }
        return game.move(move: path.removeFirst())
    }
    
    public func computePath(game: GameState){
        isRunning = true
        computePath(game: game, path: [], queue: DispatchQueue.global(), depth: 0)
        group.wait()
    }
    
    public func computePath(game: GameState, path: [String], 
                            queue: DispatchQueue, depth: Int){
        if !self.isRunning || depth > self.depth { return }
        if heuristic.visit(game: game, cost: depth) { return }
        if game.winners != nil {
            pathLock.lock()
            self.path = path
            pathLock.unlock()
            self.isRunning = false
            return
        }
        for move in game.moves {
            self.group.enter()
            queue.async {
                defer {
                    self.group.leave()
                }
                guard let newGame = game.move(move: move) else { return }
                self.computePath(game: newGame, path: path + [move], 
                                 queue: queue, depth: depth + 1)
            }
        }
    }
}
