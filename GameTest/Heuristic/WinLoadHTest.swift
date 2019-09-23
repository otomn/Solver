//
//  WinLoadHTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-15.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class WinLoadHTest: XCTestCase {
    
    var heuristic: WinLoseH!

    override func setUp() {
        heuristic = WinLoseH(game: MockGame(numPlayer: 0, states: []))
        super.setUp()
    }

    override func tearDown() {
        heuristic = nil
        super.tearDown()
    }
    
    /// Build a game state for testing
    ///
    /// - Parameter winners: Winner of the state
    /// - Returns: A game state for testing
    func buildGame(winners: [Int]?) -> GameState {
        return MockGame(numPlayer: 3, states: [(winners, [])])
    }
    
    func testNotOver() {
        let game = buildGame(winners: nil)
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 1), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 2), 0)
    }

    func testNoWinner() {
        let game = buildGame(winners: [])
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 1), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 2), 0)
    }
    
    func testOneWinner() {
        let game = buildGame(winners: [0])
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 1)
        XCTAssertEqual(heuristic.getScore(game: game, player: 1), -1)
        XCTAssertEqual(heuristic.getScore(game: game, player: 2), -1)
    }
    
    func testTwoWinners() {
        let game = buildGame(winners: [0, 1])
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 0.5)
        XCTAssertEqual(heuristic.getScore(game: game, player: 1), 0.5)
        XCTAssertEqual(heuristic.getScore(game: game, player: 2), -1)
    }
    
    func testThreeWinners() {
        let game = buildGame(winners: [0, 1, 2])
        XCTAssertEqual(heuristic.getScore(game: game, player: 0), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 1), 0)
        XCTAssertEqual(heuristic.getScore(game: game, player: 2), 0)
    }

}
