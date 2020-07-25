//
//  BFS.swift
//  Solver
//
//  Created by Toby on 2020-07-19.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

public final class BFS: GameAlgorithm{
    
    var depth: Int
    var path: [String] = []
    var paths: [[String]] = []
    let heuristic: GameHeuristic
    typealias State = (depth: Int, game: GameState, path: [String])
    
    public init?(game: GameState, input: () -> String?) {
        guard let depth = getInput(
            prompt: pure1("Please type max search depth: "), 
            failedMessage: "Invalid number", 
            parser: Int.init, 
            inputStream: input).first else { return nil }
        self.depth = depth
        
        guard let heuristicType: GameHeuristic.Type = getInput(
            prompt: pure1("Please type a heuristic name: "),
            failedMessage: "Cannot find the heuristic",
            parser: Main.findClass,
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
    
    public func computePath(game: GameState, allPaths: Bool = false){
        if game.winners != nil { return }
        var heap: [State] = [(0, game, [])]
        while !heap.isEmpty{
            let state = heap.removeFirst()
            if state.depth > depth { return }
            for move in state.game.moves {
                guard let newGame = state.game.move(move: move) else {
                    continue
                }
                let newState: State = 
                    (state.depth + 1, newGame, state.path + [move])
                if newGame.winners != nil {
                    paths.append(newState.path)
                    if !allPaths {
                        path = newState.path
                        return
                    }
                }
                if self.heuristic.visit(game: newGame, cost: newState.depth){
                    continue 
                }
                heap.append(newState)
            }
        }
    }
}
