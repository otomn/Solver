//
//  GussingGameHTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-23.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

import XCTest
import Solver

class GussingGameHTest: XCTestCase {
    
    var heuristic: GuessingGameH!
    
    override func setUp() {
        heuristic = GuessingGameH(game: buildGame(min: 0, max: 0))
        super.setUp()
    }
    
    override func tearDown() {
        heuristic = nil
        super.tearDown()
    }
    
    /// Build a game state for testing
    ///
    /// - Parameters:
    ///   - min: min number
    ///   - max: max number
    /// - Returns: A game state for testing
    func buildGame(min: Int, max: Int) -> GuessingGame {
        return GuessingGame(playerSymbols: ["a"], min: min, max: max, num: max)
    }
    
    func testNotOver() {
        let game = buildGame(min: 0, max: 5)
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), -5)
    }
    
    func testNoWinner() {
        let game = buildGame(min: 0, max: 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 0)
    }
    
}
