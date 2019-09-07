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
    
    /// Get the symbol representing the current player
    ///
    /// - Returns: Symbole representing the current player
    func playerSymbol() -> String
    
    /// Check whether the string is a valid move for the current state
    ///
    /// - Parameter move: A string representing a move
    /// - Returns: True iff `move` string is valid for the current state
    func isValidMove(move: String) -> Bool
    
    /// Generate a new state from the current state according to the move specified
    ///
    /// - Parameter move: A string representing a move
    /// - Returns: The state after the move, nil if the move is invalid
    func move(move: String) -> Self?
    
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

/// Generates heuristics of GameStates for GameAlgorithms to use
public protocol GameHeuristic {
    
    // TODO: Make this GameState
    /// The type of game this heuristic is designed for
    associatedtype ModelType
    
    /// Generate a score of the current state for the player, the higher the better
    ///
    /// - Parameters:
    ///   - game: Game state to evaluate
    ///   - player: The player contect
    /// - Returns: A score of the current state for the player
    func getScore(game: ModelType, player: Int) -> Float
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
    
    /// Make a move, return the new resulting game state
    ///
    /// - Parameter game: The current game state
    /// - Returns: The resulting game state after the move
    func makeMove<T: GameState>(_ game: T) -> T?
    
    // TODO: find a way to remove this
    /// Make a move, return the new resulting game state
    ///
    /// - Parameter game: The current game state
    /// - Returns: The resulting game state after the move
    func makeMove(_ game: GameState) -> GameState?
}
