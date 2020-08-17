//
//  Pyraminx.swift
//  Solver
//
//  Created by Toby on 2019-08-23.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Represent the toy pyraminx
public final class Pyraminx: GameState {
    
    public var player: Int = 0
    
    public var numPlayer: Int = 1
    
    var tips: [Tip]
    
    var faces: [Face]
    
    public var moves: [String] {
        return Colour.colours.flatMap{ ["\($0)l", "\($0)r"] }
    }
    
    public var winners: [Int]? {
        return isComplete ? [0] : nil
    }
    
    public var description: String {
        var result = ""
        for i in 0 ... 3{
            result += faces[i].descriptInOrder(tip: tips[i])
        }
        return result
    }
    
    public var isComplete: Bool {
        return faces.reduce(true, { $0 && $1.isComplete })
    }
    
    public var isValid: Bool {
        if tips.count != 4 || faces.count != 4 { return false }
        
        var bmp = BitmapInt<UInt8>()
        tips.forEach{ bmp[$0.id] = true }
        if bmp.rawValue != 15 { return false }
        
        bmp = BitmapInt<UInt8>()
        faces.forEach{ bmp[$0.id] = true }
        if bmp.rawValue != 15 { return false }
        
        var count = [0, 0, 0, 0]
        faces.forEach{ $0.tiles.forEach{ count[Int($0)] += 1 } }
        if count != [8, 8, 8, 8] { return false }
        
        if faces.reduce(false, { $0 || $1.tiles[$1.id] != $1.id }) { return false }
        
        return true
    }
    
    public convenience init?(input: () -> String?) {
        var tips: [Tip] = []
        for colour in Colour.colours {
            print("Building tip without colour \(colour)")
            guard let tip = Tip(input: input) else { return nil }
            if tip.colour != colour { return nil }
            tips.append(tip)
        }
        var faces: [Face] = []
        for colour in Colour.colours {
            print("Building face for colour \(colour)")
            guard let face = Face(colour: colour, order: tips[colour.index], input: input) else { return nil }
            faces.append(face)
        }
        self.init(tips: tips, faces: faces)
    }
    
    // Assuming in order of rgby
    init(tips: [Tip], faces: [Face]){
        self.tips = tips
        self.faces = faces
    }
    
    public func playerSymbol(player: Int) -> String? {
        return "Player"
    }
    
    public func move(player: Int, move: String) -> Pyraminx? {
        if !isValidMove(move: move) { return nil }
        let tip = tips[Colour(String(move.first!))!.index]
        let direction = Direction(String(move.last!))!
        
        let newState = Pyraminx(tips: tips, faces: faces)
        for i in 0 ... 2{
            let sourceColour = tip.nextTo(origin: i, to: .still)
            let targetColour = tip.nextTo(origin: i, to: direction)
            let sourceFace = faces[sourceColour.index]
            var targetFace = faces[targetColour.index]
            targetFace[tip, tip] = sourceFace[tip, tip]
            targetFace[tip.colour, tip.nextTo(from: targetColour, to: .right)] = 
            sourceFace[tip.colour, tip.nextTo(from: sourceColour, to: .right)]
            targetFace[tip.colour, tip.nextTo(from: targetColour, to: .left)] = 
            sourceFace[tip.colour, tip.nextTo(from: sourceColour, to: .left)]
            newState.faces[targetColour.index].tiles = targetFace.tiles
        }
        return newState
    }
}

public enum Colour: UInt8, LosslessStringConvertible{
    
//    typealias RawValue = UInt8
    
    case red = 0
    case green = 1
    case blue = 2
    case yellow = 3
    
    static let representations = ["r", "g", "b", "y"]
    static let colours: [Colour] = [.red, .green, .blue, .yellow]
    
    public var description: String {
        return Colour.representations[Int(self.rawValue)]
    }
    
    var index: Int {
        return Int(rawValue)
    }
    
    public init?(_ description: String) {
        guard let index = Colour.representations.firstIndex(of: description) 
            else { return nil }
        self = Colour.init(rawValue: UInt8(index))!
    }
}

public enum Direction: Int8, LosslessStringConvertible{
    
    case left = -1
    case still = 0
    case right = 1
    
    static let representations = ["l", "left", "r", "right", "s", "still"]
    
    public init?(_ description: String) {
        guard let index = Direction.representations.firstIndex(of: description) 
            else { return nil }
        self = index < 2 ? .left : index < 4 ? .right : .still
    }
    
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .still:
            return "still"
        case .right:
            return "right"
        }
    }
    
}

public struct Tip {
    
    /// Colours on this tip in clockwise order (last one is the missing colour)
    var colours = BitList<UInt8>(itemSize: 2)
    
    
    var id: UInt8 {
        return self.colours[3]
    }
    
    /// The missing colour of the tip for easy reference
    var colour: Colour {
        return Colour.init(rawValue: id)!
    }
    
    /// Last colour is the colour of the tip
    init(colours: [Colour]){
        for i in 0 ... 3 {
            self.colours[i] = colours[i].rawValue
        }
    }
    
    init?(input: () -> String?){
        var hasColour = BitmapInt<UInt8>()
        let colours: [Colour] = getInput(
            prompt: { return "Please type colour \($0.count + 1): "},
            failedMessage: "Invalid colour", 
            parser: { 
                if let colour = Colour.init($0) {
                    if !hasColour[Int(colour.rawValue)] {
                        hasColour[Int(colour.rawValue)] = true
                        return colour
                    }
                }
                return nil
            }, 
            terminateCondition: { $1.count == 3 },
            inputStream: input
            )
        if colours.count != 3 { return nil }
        for i in 0 ... 2 {
            self.colours[i] = colours[i].rawValue
        }
        self.colours[3] = (15 - hasColour.rawValue).trailingZeroBitCount
    }
    
    func nextTo(from: Colour, to direction: Direction) -> Colour{
        let origin = colours.firstIndex(of: from.rawValue)!
        return nextTo(origin: origin, to: direction)
    }
    
    func nextTo(origin: Int, to direction: Direction) -> Colour{
        let index = (origin + 3 + Int(direction.rawValue)) % 3
        return Colour.init(rawValue: colours[index])!
    }
    
}

public struct Face: CustomStringConvertible{
    
    /// The target colour of the face, last one is the 
    var tiles = BitList<UInt16>(itemSize: 2)
    
    /// The colour of the face
    var colour: Colour{
        return Colour.init(rawValue: id)!
    }
    
    /// A unique identifier of the face
    var id: UInt8{
        return tiles[7]
    }
    
    /// All colours on this face is the same as the face colour
    var isComplete: Bool{
        return tiles.reduce(true, { $0 && $1 == id })
    }
    
    public var description: String{
        var result = "Face \(colour)("
        for firstColour in Colour.colours {
            if firstColour == colour { continue }
            for secondColour in Colour.colours[Int(firstColour.rawValue) ... 3] {
                if secondColour == colour { continue }
                result += " \(firstColour)\(secondColour):\(self[firstColour, secondColour])"
            }
        }
        return result + " )\n"
    }
    
    subscript(first: Tip, second: Tip) -> Colour{
        get {
            guard let index = tileIndex(first.id, second.id) else { fatalError() }
            return Colour.init(rawValue: tiles[index])!
        }
        set {
            guard let index = tileIndex(first.id, second.id) else { fatalError() }
            tiles[index] = newValue.rawValue
        }
    }
    
    subscript(first: Colour, second: Colour) -> Colour{
        get {
            guard let index = tileIndex(first.rawValue, second.rawValue) else { fatalError() }
            return Colour.init(rawValue: tiles[index])!
        }
        set {
            guard let index = tileIndex(first.rawValue, second.rawValue) else { fatalError() }
            tiles[index] = newValue.rawValue
        }
    }
    
    init(tiles: BitList<UInt16>) {
        self.tiles = tiles
    }
    
    init?(colour: Colour, order: Tip, input: () -> String?) {
        tiles[7] = colour.rawValue
        // fill the gap for easier calculation of isComplete
        tiles[colour.rawValue] = colour.rawValue
        if !doInOrder(tip: order, do: { firstColour, secondColour in
            guard let tile = getInput(
                prompt: { _ in "Tile colour for \(firstColour) \(secondColour): " },
                failedMessage: "Invalid colour", 
                parser: Colour.init, 
                inputStream: input
                ).first else { return false }
            self[firstColour, secondColour] = tile
            return true
            }){ return nil }
    }
    
    func tileIndex(_ first: UInt8, _ second: UInt8) -> UInt8?{
        if first == id || second == id { return nil }
        return first == second ? first : ((first ^ second) + 3)
        // same first/second takes bit 1 - 4
        // xor will not produce 00 if different, thus takes bit 5 - 7
        // bit 8 used for face colour
    }
    
    func descriptInOrder(tip: Tip) -> String{
        var result = "Face \(colour)("
        _ = doInOrder(tip: tip){
            result += " \($0)\($1):\(self[$0, $1])"
            return true
        }
        return result + " )\n"
    }
    
    func doInOrder(tip: Tip, do job: (Colour, Colour) -> Bool) -> Bool{
        for i in 0 ... 2 {
            let first = tip.nextTo(origin: i, to: .still)
            let second = tip.nextTo(origin: i, to: .right)
            if !job(first, first){ return false }
            if !job(first, second){ return false }
        }
        return true
    }
}
