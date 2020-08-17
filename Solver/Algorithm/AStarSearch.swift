//
//  AStartSearch.swift
//  Solver
//
//  Created by Toby on 2019-09-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

public final class AStarSearch: GameAlgorithm{
    
    private let heuristic: GameHeuristic
    private var path: [String] = []
    let heapLock = NSLock()
    typealias State = (score: Float, game: GameState, path: [String])
    
    public func makeMove(_ game: GameState) -> GameState? {
        if path.isEmpty || !game.isValidMove(move: path[0]) {
            computePath(game: game)
            if path.isEmpty || !game.isValidMove(move: path[0]) {
                return nil
            }
            print(path)
        }
        return game.move(move: path.removeFirst())
    }
    
    public init(game: GameState, heuristic: GameHeuristic) {
        self.heuristic = heuristic
    }
    
    public init?(game: GameState, input: () -> String?) {
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
    
    private func computePath(game: GameState){
        var heap: [[State]] = [[(heuristic.getScore(game: game), game, [])]]
        var queues: [String:DispatchQueue] = [:]
        let group = DispatchGroup()
        for move in game.moves{
            queues[move] = DispatchQueue(label: move)
        }
        while !heap.isEmpty{
            let state = popMin(heap: &heap)
            if state.game.winners != nil {
                path = state.path
                return
            }
            for move in state.game.moves {
                group.enter()
                queues[move]!.async {
                    defer{
                        group.leave()
                    }
                    guard let newGame = state.game.move(move: move) else {
                        return
                    }
                    if self.heuristic.visit(game: newGame, cost: 0) {
                        // Don't care about the cost, if the state is visited, skip
                        return
                    }
                    let score = self.heuristic.getScore(game: newGame)
                    self.insertOrdered(heap: &heap, state: (score, newGame, state.path + [move]))
                }
            }
            group.wait()
        }
    }
    
    private func popMin(heap: inout [[State]]) -> State{
        heapLock.lock()
        defer{
            heap[0].removeFirst()
            if heap[0].isEmpty{
                heap.removeFirst()
            }
            heapLock.unlock()
        }
        return heap[0][0]
    }
    
    /// Insert the state in decreasing order
    private func insertOrdered(heap: inout [[State]], state: State){
        heapLock.lock()
        defer{
            heapLock.unlock()
        }
        for i in 0 ..< heap.count{
            /// All states before i are greater than the score, insert here
            if heap[i][0].score < state.score {
                heap.insert([state], at: i)
                return
            }
            /// Insert into the same bucket
            if heap[i][0].score == state.score {
                heap[i].append(state)
                return
            }
        }
        /// Insert at the end
        heap.append([state])
    }
    
}
