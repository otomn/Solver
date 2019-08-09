//
//  Protocols.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

protocol GameState: CustomStringConvertible {
    var player: Int {get}
    var numPlayer: Int {get}
    init?()
    func playerSymbol(player: Int) -> String?
    func playerSymbol() -> String
    func moves() -> [String]
    func isValidMove(move: String) -> Bool
    func move(move: String) -> Self?
    func move(player: Int, move: String) -> Self?
    func winners() -> [Int]?
}

protocol GameHeuristic {
    associatedtype modelType: GameState
    func getScore(game: modelType) -> Float
    func isVisited(game: modelType) -> Bool
}

protocol GameAlgorithm{
    init()
    func makeMove(_ game: GameState) -> GameState?
}
