//
//  MockGame.swift
//  Solver
//
//  Created by Toby on 2019-08-12.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// A mock game for testing
///
/// The public init can build a game with specified number of players 
/// and a set of fixed states
public final class MockGame: GameState{
    
    public var player: Int = 0
    public var numPlayer: Int
    public var description: String {
        return "\(states[moveCount])"
    }
    public var moves: [String] {
        return states[moveCount].moves
    }
    public var winners: [Int]? {
        return states[moveCount].winners
    }
    
    public typealias State = (winners:[Int]?,moves:[String])
    var states: [State]
    var moveCount: Int = 0
    
    public init?(input: () -> String?){
        return nil
    }
    
    public init(numPlayer: Int, states: [State]){
        self.numPlayer = numPlayer
        self.states = states
    }
    
    public func playerSymbol(player: Int) -> String? {
        return "Player \(player)"
    }
    
    public func move(player: Int, move: String) -> MockGame? {
        if !isValidMove(move: move) || player != self.player { return nil }
        let newState = MockGame(numPlayer: numPlayer, states: states)
        newState.moveCount = moveCount + 1
        newState.player = (player + 1) % numPlayer
        return newState
    }
    
}
