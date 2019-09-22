//
//  PyraminxTest.swift
//  GameTest
//
//  Created by Toby on 2019-09-06.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
@testable import Solver

class PyraminxTest: XCTestCase {

    // r: gby
    // g: ryb
    // b: rgy
    // y: rbg
    
    // r: gg:r gb:r bb:r by:r yy:r yg:r
    // ...
    
    // move rl
    
    // r: gg:r gb:r bb:r by:r yy:r yg:r
    // g: rr:y rb:y bb:g by:g yy:g yr:y
    // b: gg:b gr:g rr:g ry:g yy:b yg:b
    // y: gg:y gb:y bb:y br:b rr:b rg:b
    
    var gameComplete: Pyraminx!
    var gameIpr: Pyraminx!
    
    override func setUp() {
        gameComplete = buildGameBase()
        gameIpr = buildGameBase()
        
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
    
    func testComplete() {
        XCTAssertTrue(gameComplete.isValid)
        XCTAssertTrue(gameComplete.isComplete)
        XCTAssertEqual(gameComplete.winners, [0])
    }
    
    func testIpr() {
        XCTAssertTrue(gameIpr.isValid)
        XCTAssertFalse(gameIpr.isComplete)
        XCTAssertNil(gameIpr.winners)
    }
    
    func testInit() {
        var input = [
            "g", "b", "y",
            "r", "y", "b",
            "r", "g", "y",
            "r", "b", "g",
            "r", "r", "r", "r", "r", "r",
            "g", "g", "g", "g", "g", "g",
            "b", "b", "b", "b", "b", "b",
            "y", "y", "y", "y", "y", "y"
        ]
        guard let game = Pyraminx(input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        XCTAssertEqual(game.faces[0].tiles, gameComplete.faces[0].tiles)
        XCTAssertEqual(game.faces[1].tiles, gameComplete.faces[1].tiles)
        XCTAssertEqual(game.faces[2].tiles, gameComplete.faces[2].tiles)
        XCTAssertEqual(game.faces[3].tiles, gameComplete.faces[3].tiles)
    }
    
    func testMove() {
        // rotate right on the tip without red
        Colour.colours.forEach{
            XCTAssertTrue(gameIpr.isValidMove(move: "\($0)l"))
            XCTAssertTrue(gameIpr.isValidMove(move: "\($0)r"))
        }
        XCTAssertFalse(gameIpr.isValidMove(move: "ro"))
        XCTAssertFalse(gameIpr.isValidMove(move: "ror"))
        XCTAssertFalse(gameIpr.isValidMove(move: "cr"))
        
        guard let game = gameIpr.move(move: "rl") else {
            XCTFail()
            return
        }
        XCTAssertTrue(game.isValid)
        XCTAssertTrue(game.isComplete)
        XCTAssertEqual(game.winners, [0])
        
        // move does not change original
        _ = gameComplete.move(move: "rr")
        XCTAssertTrue(gameComplete.isValid)
        XCTAssertTrue(gameComplete.isComplete)
        XCTAssertEqual(gameComplete.winners, [0])
    }
    
}
