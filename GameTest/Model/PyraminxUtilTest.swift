//
//  PyraminxUtilTest.swift
//  GameTest
//
//  Created by Toby on 2019-09-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
@testable import Solver

class PyraminxUtilTest: XCTestCase {
    
    func testColour() {
        XCTAssertEqual(Colour.init("r"), Colour.red)
        XCTAssertEqual(Colour.init("g"), Colour.green)
        XCTAssertEqual(Colour.init("b"), Colour.blue)
        XCTAssertEqual(Colour.init("y"), Colour.yellow)
        XCTAssertEqual(String(Colour.red), "r")
        XCTAssertEqual(String(Colour.green), "g")
        XCTAssertEqual(String(Colour.blue), "b")
        XCTAssertEqual(String(Colour.yellow), "y")
        XCTAssertEqual(Colour.red.rawValue, 0)
        XCTAssertEqual(Colour.green.rawValue, 1)
        XCTAssertEqual(Colour.blue.rawValue, 2)
        XCTAssertEqual(Colour.yellow.rawValue, 3)
        XCTAssertLessThanOrEqual(MemoryLayout.size(ofValue: Colour.red), 1)
    }
    
    func testDirection() {
        XCTAssertEqual(Direction.init("l"), Direction.left)
        XCTAssertEqual(Direction.init("left"), Direction.left)
        XCTAssertEqual(Direction.init("r"), Direction.right)
        XCTAssertEqual(Direction.init("right"), Direction.right)
        XCTAssertEqual(String(Direction.left), "left")
        XCTAssertEqual(String(Direction.right), "right")
        XCTAssertEqual(Direction.left.rawValue, -1)
        XCTAssertEqual(Direction.right.rawValue, 1)
        XCTAssertLessThanOrEqual(MemoryLayout.size(ofValue: Direction.left), 1)
    }
    
    func testTip() {
        var input = ["r", "g"]
        let tip1 = Tip(input: { popFirst(array: &input) })
        XCTAssertNil(tip1)
        
        input = ["r", "g", "g"]
        let tip2 = Tip(input: { popFirst(array: &input) })
        XCTAssertNil(tip2)
        
        input = ["r", "g", "b"]
        guard let tip3 = Tip(input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        XCTAssertEqual(tip3.colours[0], Colour.red.rawValue)
        XCTAssertEqual(tip3.colours[1], Colour.green.rawValue)
        XCTAssertEqual(tip3.colours[2], Colour.blue.rawValue)
        XCTAssertEqual(tip3.colours[3], Colour.yellow.rawValue)
        
        input = ["y", "g", "b"]
        guard let tip4 = Tip(input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        XCTAssertEqual(tip4.colours[0], Colour.yellow.rawValue)
        XCTAssertEqual(tip4.colours[1], Colour.green.rawValue)
        XCTAssertEqual(tip4.colours[2], Colour.blue.rawValue)
        XCTAssertEqual(tip4.colours[3], Colour.red.rawValue)
        
        XCTAssertLessThanOrEqual(MemoryLayout.size(ofValue: tip4), 2)
    }
    
    func testFace() {
        var input = ["b", "g", "y"]
        guard let tip = Tip(input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        input = ["r", "r", "r", "r", "r", "r"]
        guard var face = Face(colour: .red, order: tip, input: { popFirst(array: &input) }) else {
            XCTFail()
            return
        }
        XCTAssertEqual(face.colour, Colour.red)
        XCTAssertTrue(face.isComplete)
        
        face[.green, .green] = .green
        face[.blue, .blue] = .blue
        face[.yellow, .yellow] = .yellow
        face[.green, .blue] = .green
        face[.blue, .yellow] = .blue
        face[.yellow, .green] = .yellow
        XCTAssertEqual(face[.green, .green], .green)
        XCTAssertEqual(face[.blue, .blue], .blue)
        XCTAssertEqual(face[.yellow, .yellow], .yellow)
        XCTAssertEqual(face[.green, .blue], .green)
        XCTAssertEqual(face[.blue, .yellow], .blue)
        XCTAssertEqual(face[.yellow, .green], .yellow)
        XCTAssertEqual(face.colour, .red)
        XCTAssertFalse(face.isComplete)
    }

}
