//
//  MockAlgorithmTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-14.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class MockAlgorithmTest: XCTestCase {

    var game: MockGame!
    var algorithm: GameAlgorithm!
    var states: [MockGame.State] = [
        (nil, ["1", "2", "3"]),
        (nil, ["2", "3"]),
        (nil, ["2"]),
        ([1], [])
    ]
    
    override func setUp() {
        super.setUp()
        game = MockGame(numPlayer: 2, states: states)
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func testValidMoves() {
        algorithm = MockAlgorithm(moves: ["1", "3", "2"])
        var state: MockGame! = game
        for _ in 1...3 {
            state = algorithm.makeMove(state)
            XCTAssertNotNil(state)
        }
        XCTAssertEqual(state.winners, [1])
    }
    
    func testInvalidMove() {
        algorithm = MockAlgorithm(moves: ["0"])
        XCTAssertNil(algorithm.makeMove(game))
    }

}
