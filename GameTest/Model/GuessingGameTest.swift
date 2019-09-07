//
//  GuessingGameTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-23.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class GuessingGameTest: XCTestCase {
    
    func testPlayer(){
        var state = GuessingGame(playerSymbols: ["a", "b"], min: 0, max: 100, num: 50)
        XCTAssertEqual(state.player, 0)
        XCTAssertEqual(state.playerSymbol(), "a")
        XCTAssertNil(state.move(player: 1, move: "1"))
        if state.move(player: 0, move: "1") == nil {
            XCTFail()
            return
        }
        state = state.move(player: 0, move: "1")!
        XCTAssertEqual(state.player, 1)
        XCTAssertEqual(state.playerSymbol(), "b")
    }
    
    func testInit(){
        var input = [
            "a", "b", "", // player sysmbol
            "0", "100", "50" // min, max, goal
        ]
        guard let state = GuessingGame(input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        XCTAssertEqual(state.minNum, 0)
        XCTAssertEqual(state.maxNum, 100)
        XCTAssertEqual(state.theNum, 50)
        XCTAssertEqual(state.playerSymbols, ["a", "b"])
        XCTAssertEqual(state.numPlayer, 2)
    }
    
    func testMoves() {
        let state = GuessingGame(playerSymbols: ["a", "b"], min: 0, max: 100, num: 50)
        XCTAssertNil(state.move(move: "-1"))
        XCTAssertEqual(state.move(move: "20")?.minNum, 21)
        XCTAssertEqual(state.move(move: "80")?.maxNum, 79)
        XCTAssertEqual(state.move(move: "50")?.winners, [0])
    }
    
}
