//
//  Protocols.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// An object representing a game state
public protocol GameState: CustomStringConvertible {
    
    /// Player number of the current player
    var player: Int {get}
    
    /// Total number of players in this game
    var numPlayer: Int {get}
    
    /// All possible moves the current player can make
    var moves: [String] {get}
    
    /// Description of the moves the current player can make
    var moveDescription: String {get}
    
    /// A list of winners if the game state is at and end state, nil otherwise
    var winners: [Int]? {get}
    
    /// Setup the game via provided input steam
    ///
    /// - Parameter input: Source of input
    init?(input: () -> String?)
    
    /// Get the symbol representing the player specified
    ///
    /// - Parameter player: The index of the player
    /// - Returns: Symbol representing the player
    func playerSymbol(player: Int) -> String?
    
    /// Check whether the string is a valid move for the current state
    ///
    /// - Parameter move: A string representing a move
    /// - Returns: True iff `move` string is valid for the current state
    func isValidMove(move: String) -> Bool
    
    /// Generate a new state from the current state 
    /// according to the move and the player specified
    ///
    /// - Parameters:
    ///   - player: The player taking the move
    ///   - move: A string representing a move
    /// - Returns: The state after the move, 
    ///   nil if the move is invalid or the player cannot take move
    func move(player: Int, move: String) -> Self?
}

public extension GameState {
    
    /// Description of the moves the current player can make
    var moveDescription: String {
        return moves.description
    }
    
    /// Get the symbol representing the current player
    ///
    /// - Returns: Symbole representing the current player
    func playerSymbol() -> String{
        return playerSymbol(player: player)!
    } 
    
    /// Generate a new state from the current state according to the move specified
    ///
    /// - Parameter move: A string representing a move
    /// - Returns: The state after the move, nil if the move is invalid
    func move(move: String) -> Self?{
        return self.move(player: player, move: move)
    }
    
    func isValidMove(move: String) -> Bool{
        return moves.contains(move)
    }
}

/// Generates heuristics of GameStates for GameAlgorithms to use
public protocol GameHeuristic {
    
    /// True if this heuristic can support multiple threading access
    var supportMulThread: Bool {get}
    
    /// Generate a score of the current state for the player, the higher the better
    ///
    /// - Parameters:
    ///   - game: Game state to evaluate
    ///   - player: The player contect
    /// - Returns: A score of the current state for the player
    func getScore(game: GameState, player: Int) -> Float
    
    func visit(game: GameState, cost: Int, register: Bool) -> Bool
    
    init?(game: GameState)
}

public extension GameHeuristic {
    
    func getScore(game: GameState) -> Float{
        return getScore(game: game, player: game.player)
    }
    
    func visit(game: GameState, cost: Int) -> Bool {
        visit(game: game, cost: cost, register: true)
    }
    
    func isVisited(game: GameState, cost: Int) -> Bool {
        visit(game: game, cost: cost, register: false)
    }
}

/// An algorithm that can play the game
public protocol GameAlgorithm{
    
    // Setup the algorithm via user input through provided input stream
    /// Returns nil if error encountered
    ///
    /// - Parameter game: 
    /// - Parameters:
    ///   - game: The game this algorithm will be used on
    ///   - input: The input source
    init?(game: GameState, input: () -> String?)
    
    init(game: GameState, heuristic: GameHeuristic)
    
    // TODO: find a way to remove this
    /// Make a move, return the new resulting game state
    ///
    /// - Parameter game: The current game state
    /// - Returns: The resulting game state after the move
    func makeMove(_ game: GameState) -> GameState?
}

public extension GameAlgorithm{
    
    /// Make a move, return the new resulting game state
    ///
    /// - Parameter game: The current game state
    /// - Returns: The resulting game state after the move
    func makeMove<T>(_ game: T) -> T? where T : GameState {
        return makeMove(game as GameState) as! T?
    }
    
}
