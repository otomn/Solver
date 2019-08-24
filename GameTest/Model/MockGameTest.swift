//
//  GameTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-12.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class MockGameTest: XCTestCase {

    var game: MockGame!
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
    
    func testPlayer(){
        let state: MockGame! = game
        XCTAssertEqual(state.player, 0)
        XCTAssertNil(state.move(player: 1, move: "1"))
        XCTAssertEqual(state.move(move: "1")?.player, 1)
    }

    func testMoves() {
        var state: MockGame! = game
        for i in 0..<4 {
            XCTAssertEqual(state.moves, states[i].moves)
            for move in states[i].moves{
                XCTAssertTrue(state.isValidMove(move: move))
                XCTAssertEqual(state.player, i % 2)
                XCTAssertEqual(state.winners, states[i].winners)
            }
            state = state.move(move: "2")
            if i < 3 {
                XCTAssertNotNil(state)
                XCTAssertNil(state.move(move: "1"))
            }
        }
    }

}
