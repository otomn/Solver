//
//  CalculatorTheGameHTest.swift
//  GameTest
//
//  Created by Toby on 2020-07-21.
//  Copyright © 2020 Toby. All rights reserved.
//

import XCTest
import Solver

class CalculatorTheGameHTest: XCTestCase {
    
    var game: GameState!
    
    override func setUp() {
        game = CalculatorTheGame.init(value: 9, movesLeft: 9, goal: 3001, ops: [
            "39>93", "/3", "st", "31>00"
        ])
    }
    
    override func tearDown() {
        game = nil
    }
    
    func testBFS(){
        guard let heuristic = CalculatorTheGameH(game: game) else {
            XCTFail()
            return
        }
        let algorithm = BFS(game: game, heuristic: heuristic)
        measure { test(heuristic: heuristic, algorithm: algorithm) }
    }
    
    func testBFSControl(){
        guard let heuristic = WinLoseH(game: game) else {
            XCTFail()
            return
        }
        let algorithm = BFS(game: game, heuristic: heuristic)
        measure { test(heuristic: heuristic, algorithm: algorithm) }
    }
    
    func test(heuristic: GameHeuristic, algorithm: GameAlgorithm){
        while game.winners == nil{
            guard let newGame = algorithm.makeMove(game) else {
                XCTFail()
                return
            }
            game = newGame
        }
        XCTAssert(game.winners == [0])
    }

}
