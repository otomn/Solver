//
//  PyraminxManhattanHTest.swift
//  GameTest
//
//  Created by Toby on 2019-09-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
import Solver

class PyraminxManhattanHTest: XCTestCase {
    
    var heuristic: PyraminxManhattanH!
    var gameComplete: Pyraminx!
    var gameIpr: Pyraminx!
    
    override func setUp() {
        gameComplete = buildGameBase()
        gameIpr = buildGameBase()
        heuristic = PyraminxManhattanH(game: gameComplete)
        
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
    
    func buildRealGame() -> Pyraminx {
        var input = [
            "g", "b", "y",
            "r", "y", "b",
            "r", "g", "y",
            "r", "b", "g",
            "r", "g", "y", "b", "r", "y",
            "b", "r", "g", "r", "r", "r",
            "y", "g", "b", "b", "b", "g",
            "g", "y", "g", "y", "y", "b"
        ]
        return Pyraminx(input: { popFirst(array: &input) })!
    }
    
    func testScore(){
        XCTAssertEqual(heuristic.getScore(game: gameComplete, player: 0), 0)
        XCTAssertEqual(heuristic.getScore(game: gameIpr, player: 0), -9)
    }
    
    func testVisited(){
        let uidComplete = [heuristic.getUid(game: gameComplete)]
        let uidIpr = [heuristic.getUid(game: gameIpr)]
        XCTAssertFalse(heuristic.isVisited(uid: uidComplete))
        XCTAssertFalse(heuristic.isVisited(uid: uidIpr))
        XCTAssertFalse(heuristic.visit(uid: uidComplete))
        XCTAssertTrue(heuristic.isVisited(uid: uidComplete))
        XCTAssertFalse(heuristic.isVisited(uid: uidIpr))
    }
    
    func testWithBFSHMulThread(){
        var game = buildRealGame()
        guard let heuristic = PyraminxManhattanH(game: game) else {
            XCTFail()
            return
        }
        let algorithm = BFSHMulThread(game: game, heuristic: heuristic)
        measure {
            while game.winners == nil{
                guard let newGame = algorithm.makeMove(game) else {
                    XCTFail()
                    return
                }
                game = newGame as! Pyraminx
            }
        }
    }
    
    func testWithAStartSeach(){
        var game = buildRealGame()
        guard let heuristic = PyraminxManhattanH(game: game) else {
            XCTFail()
            return
        }
        let algorithm = AStarSearch(game: game, heuristic: heuristic)
        measure {
            while game.winners == nil{
                guard let newGame = algorithm.makeMove(game) else {
                    XCTFail()
                    return
                }
                game = newGame as! Pyraminx
            }
        }
    }

}
