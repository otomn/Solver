//
//  AStartSearchTest.swift
//  GameTest
//
//  Created by Toby on 2019-09-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class AStarSeachTest: XCTestCase {
    
    var algorithm: AStarSearch!
    var heuristic: PyraminxManhattanH!
    var gameComplete: Pyraminx!
    var gameIpr: Pyraminx!
    
    override func setUp() {
        gameComplete = buildGameBase()
        gameIpr = buildGameBase()
        heuristic = PyraminxManhattanH(game: gameComplete)
        algorithm = AStarSearch(game: gameComplete, heuristic: heuristic)
        
        gameIpr.faces[1][.red, .red] = .yellow
        gameIpr.faces[1][.red, .blue] = .yellow
        gameIpr.faces[1][.blue, .blue] = .green
        gameIpr.faces[1][.blue, .yellow] = .green
        gameIpr.faces[1][.yellow, .yellow] = .green
        gameIpr.faces[1][.yellow, .red] = .yellow
        
        gameIpr.faces[2][.green, .green] = .blue
        gameIpr.faces[2][.green, .red] = .green
        gameIpr.faces[2][.red, .red] = .green
        gameIpr.faces[2][.red, .yellow] = .green
        gameIpr.faces[2][.yellow, .yellow] = .blue
        gameIpr.faces[2][.yellow, .green] = .blue
        
        gameIpr.faces[3][.green, .green] = .yellow
        gameIpr.faces[3][.green, .blue] = .yellow
        gameIpr.faces[3][.blue, .blue] = .yellow
        gameIpr.faces[3][.blue, .red] = .blue
        gameIpr.faces[3][.red, .red] = .blue
        gameIpr.faces[3][.red, .green] = .blue
    }
    
    override func tearDown() {
        heuristic = nil
        gameComplete = nil
        gameIpr = nil
        algorithm = nil
    }
    
    func buildGameBase() -> Pyraminx {
        return Pyraminx(
            tips: [
                Tip(colours: [.green, .blue, .yellow, .red]),
                Tip(colours: [.red, .yellow, .blue, .green]),
                Tip(colours: [.red, .green, .yellow, .blue]),
                Tip(colours: [.red, .blue, .green, .yellow  ])
            ], 
            faces: [
                Face(tiles: BitList<UInt16>(itemSize: 2, 
                                            source: Array.init(repeating: 0, count: 8))),
                Face(tiles: BitList<UInt16>(itemSize: 2, 
                                            source: Array.init(repeating: 1, count: 8))),
                Face(tiles: BitList<UInt16>(itemSize: 2, 
                                            source: Array.init(repeating: 2, count: 8))),
                Face(tiles: BitList<UInt16>(itemSize: 2, 
                                            source: Array.init(repeating: 3, count: 8)))
            ]
        )
    }
    
    func testEasy(){
        guard let result = algorithm.makeMove(gameIpr) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(result.winners)
    }
    
}

