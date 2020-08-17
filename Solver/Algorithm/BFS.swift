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
        var first = paths.first?.first
        if first == nil || !game.isValidMove(move: first!){
            computePath(game: game)
            first = paths.first?.first
            if first == nil || !game.isValidMove(move: first!){
                print("No result")
                return nil
            }
            print(paths.first!)
        }
        return game.move(move: paths[0].removeFirst())
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
