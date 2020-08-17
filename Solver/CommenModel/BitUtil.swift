//
//  BitMap.swift
//  Solver
//
//  Created by Toby on 2019-08-23.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Light bitmap
public protocol Bitmap: CustomStringConvertible, Equatable {
    
    /// Get / set a bit
    ///
    /// - Parameter bit: offset bit
    subscript<A: BinaryInteger>(bit: A) -> Bool { get set }
    
    /// size of the Bitmap
    var bitWidth: Int {get}
    
    /// Copy from provided Bitmap
    ///
    /// - Parameter _: Source Bitmap
    init(_: Self)
    
    /// Init an empty Bitmap
    init()
}

/// Use an integer to store the bits
public struct BitmapInt<Rawtype: FixedWidthInteger>: Bitmap 
    where Rawtype:UnsignedInteger {
    
    public var rawValue: Rawtype
    public var bitWidth: Int {
        return Rawtype.bitWidth
    }
    public var description: String {
        return "\(rawValue)"
    }
    
    public init() {
        rawValue = 0
    }
    
    public init(_ source: BitmapInt) {
        rawValue = source.rawValue
    }
    
    public static func == (lhs: BitmapInt<Rawtype>, rhs: BitmapInt<Rawtype>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public subscript<A: BinaryInteger>(bit: A) -> Bool {
        get {
            return rawValue & getMask(bit: bit) != 0
        }
        set (value){
            if value {
                rawValue |= getMask(bit: bit)
            } else {
                rawValue &= ~0 - getMask(bit: bit)
            }
        }
    }
    
    /// Check if bit is valide, return the bit mask
    ///
    /// - Parameter bit: Bit offset
    /// - Returns: Bit mask
    private func getMask<A: BinaryInteger>(bit: A) -> Rawtype {
        precondition(bit < bitWidth)
        precondition(bit >= 0)
        return 1 << bit
    }
    
}

/// Use an array of integers to store the bits, size is dynamic
public final class BitmapList<Rawtype: FixedWidthInteger>: Bitmap 
    where Rawtype:UnsignedInteger {
    
    public var bitWidth: Int {
        return rawValue.count * Rawtype.bitWidth
    }
    public var rawValue: [Rawtype]
    
    public init() {
        rawValue = []
    }
    
    public init(_ source: BitmapList<Rawtype>) {
        rawValue = Array(source.rawValue)
    }
    
    public var description: String {
        return "\(rawValue)" 
    }
        
    public static func == (lhs: BitmapList<Rawtype>, rhs: BitmapList<Rawtype>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public subscript<A: BinaryInteger>(bit: A) -> Bool {
        get {
            if bit >= bitWidth { return false }
            let (index, mask) = getMask(bit: bit)
            return rawValue[index] & mask != 0
        }
        set (value){
            let (index, mask) = getMask(bit: bit)
            if value {
                if index >= rawValue.count {
                    rawValue.append(contentsOf: 
                        Array(repeating: 0, count: index - rawValue.count + 1)) 
                }
                rawValue[index] |= mask
            } else if index < rawValue.count {
                rawValue[index] &= ~0 - mask
            } // else do nothing since bit is already off
        }
    }
    
    /// Check if bit is valid, return raw array offset and bit mask
    ///
    /// - Parameter bit: Bit offset
    /// - Returns: Array offset and bit mask
    private func getMask<A: BinaryInteger>(bit: A) -> (index: Int, mask: Rawtype) {
        precondition(bit >= 0)
        return (Int(bit) / Rawtype.bitWidth, 1 << (Int(bit) % Rawtype.bitWidth))
    }
    
}

/// Use an integer to store a list of values
public struct BitList<Rawtype: FixedWidthInteger>: 
CustomStringConvertible, Equatable, Collection where Rawtype:UnsignedInteger{
    
    public var itemSize: UInt8
    public var rawValue: Rawtype
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return bitWidth
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public var bitWidth: Int {
        return Rawtype.bitWidth / Int(itemSize)
    }
    
    public var description: String {
        return "\(rawValue)"
    }
    
    public init(itemSize: UInt8) {
        rawValue = 0
        self.itemSize = itemSize
    }
    
    public init(_ source: BitList) {
        rawValue = source.rawValue
        itemSize = source.itemSize
    }
    
    public init<A: BinaryInteger>(itemSize: UInt8, source: [A]){
        self.init(itemSize: itemSize)
        for i in 0 ..< source.count {
            self[i] = source[i]
        }
    }
    
    public static func == (lhs: BitList<Rawtype>, rhs: BitList<Rawtype>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public subscript(bit: Int) -> Rawtype {
        get { return get(bit: bit) }
        set { set(bit: bit, item: newValue) }
    }
    
    public subscript<A: BinaryInteger, B: BinaryInteger>(bit: A) -> B {
        get { return get(bit: bit) }
        set { set(bit: bit, item: newValue) }
    }
    
    private func get<A: BinaryInteger, B: BinaryInteger>(bit: A) -> B {
        return B((rawValue & getMask(bit: bit)) >> (bit * A(itemSize)))
    }
    
    private mutating func set<A: BinaryInteger, B: BinaryInteger>(bit: A, item: B){
        rawValue = rawValue & ~getMask(bit: bit) | itemShift(bit: bit, item: item)
    }
    
    /// Check if bit is valide, return the bit mask
    ///
    /// - Parameter bit: Bit offset
    /// - Returns: Bit mask
    private func getMask<A: BinaryInteger>(bit: A) -> Rawtype {
        precondition(bit < bitWidth)
        precondition(bit >= 0)
        return ((1 << itemSize) - 1) << (bit * A(itemSize)) 
        // itemSize                                  = 2
        // bit                                       = 1
        // bit * itemSize                            = 2
        // 1 << itemSize                             = 0100
        // (1 << itemSize) - 1                       = 0011
        // ((1 << itemSize) - 1) << (bit * itemSize) = 1100
    }
    
    private func itemShift<A: BinaryInteger, B: BinaryInteger>(bit: B, item: A) -> Rawtype{
        precondition(bit < bitWidth)
        precondition(bit >= 0)
        return (Rawtype(item) & ((1 << itemSize) - 1)) << (bit * B(itemSize))
    }
    
}
