//
//  BitUtilTest.swift
//  GameTest
//
//  Created by Toby on 2019-08-24.
//  Copyright © 2019 Toby. All rights reserved.
//

import XCTest
@testable import Solver

class BitUtilTest: XCTestCase {
    
    func bitTest<T: Bitmap>(bitmap: T, lb: Int, hb: Int) {
        var bmp = bitmap
        
        // test initial all false
        for i in lb...hb {
            XCTAssertEqual(bmp[i], false)
        }
        
        // test set bit
        bmp[lb] = true
        bmp[hb] = true
        XCTAssertEqual(bmp[lb], true)
        XCTAssertEqual(bmp[hb], true)
        for i in (lb + 1)...(hb - 1) {
            XCTAssertEqual(bmp[i], false)
        }
        
        // test UInt index
        XCTAssertEqual(bmp[UInt16(lb)], true)
        XCTAssertEqual(bmp[UInt16(hb)], true)
        
        // test unset bit
        for i in lb...hb {
            bmp[i] = false
        }
        for i in lb...hb {
            XCTAssertEqual(bmp[i], false)
        }
        
        // test copy
        bmp[lb] = true
        bmp[hb] = true
        var newBmp = T.init(bmp)
        XCTAssertEqual(bmp, newBmp)
        newBmp[hb] = false
        XCTAssertEqual(bmp[hb], true)
        XCTAssertEqual(newBmp[hb], false)
        XCTAssertNotEqual(bmp, newBmp)
        
        // test equal
        var eqBmp = T()
        eqBmp[lb] = true
        eqBmp[hb] = true
        XCTAssertEqual(bmp, eqBmp)
    }
    
    func listTest<I: FixedWidthInteger>(bitList: BitList<I>) {
        var bl = bitList
        let lb = 0
        let hb = bl.bitWidth - 1
        let ln: I = 1
        let hn: I = (1 << bl.itemSize) - 1
        
        // test initial all 0
        bl.forEach{ XCTAssertEqual($0, 0) }
        
        // test set bit
        bl[lb] = hn
        bl[hb] = ln
        XCTAssertEqual(bl[lb], hn)
        XCTAssertEqual(bl[hb], ln)
        bl[(lb + 1)...(hb - 1)].forEach{ XCTAssertEqual($0, 0) }
        
        // test set UInt
        bl[UInt8(0)] = UInt8(0)
        bl[UInt8(min(15, hb))] = UInt8(min(15, hn))
        XCTAssertEqual(bl[0], 0)
        XCTAssertEqual(bl[min(15, hb)], min(15, hn))
        
        // test unset bit
        for i in lb...hb {
            bl[i] = 0
        }
        bl.forEach{ XCTAssertEqual($0, 0) }
        
        // test copy
        bl[lb] = hn
        bl[hb] = ln
        var newBl = BitList.init(bl)
        XCTAssertEqual(bl, newBl)
        newBl[hb] = hn
        XCTAssertEqual(bl[hb], ln)
        XCTAssertEqual(newBl[hb], hn)
        XCTAssertNotEqual(newBl, bl)
        
        // test equal
        var eqbl = BitList<I>(itemSize: bl.itemSize)
        eqbl[lb] = hn
        eqbl[hb] = ln
        XCTAssertEqual(eqbl, bl)
    }
    
    func testBitmapInt8() {
        var bmp = BitmapInt<UInt8>()
        XCTAssertEqual(bmp.bitWidth, 8)
        bitTest(bitmap: bmp, lb: 0, hb: 7)
        bmp[0] = true
        bmp[7] = true
        XCTAssertEqual(bmp.rawValue, (1 << 7) + 1)
        XCTAssertEqual(MemoryLayout.size(ofValue: bmp), 1)
    }
    
    func testBitmapInt64() {
        var bmp = BitmapInt<UInt64>()
        XCTAssertEqual(bmp.bitWidth, 64)
        bitTest(bitmap: bmp, lb: 0, hb: 63)
        bmp[0] = true
        bmp[63] = true
        XCTAssertEqual(bmp.rawValue, (1 << 63) + 1)
        XCTAssertEqual(MemoryLayout.size(ofValue: bmp), 8)
    }
    
    func testBitmapList8() {
        let bmp = BitmapList<UInt8>()
        XCTAssertEqual(bmp.bitWidth, 0)
        bitTest(bitmap: bmp, lb: 0, hb: 15)
        XCTAssertEqual(bmp.bitWidth, 16)
        XCTAssertEqual(bmp.rawValue, [1, 1 << 7])
    }
    
    func testBitList8() {
        var bl = BitList<UInt8>(itemSize: 2)
        XCTAssertEqual(bl.bitWidth, 4)
        XCTAssertEqual(bl.itemSize, 2)
        listTest(bitList: bl)
        bl[0] = 2
        bl[3] = 3
        XCTAssertEqual(bl.rawValue, (3 << (2 * 3)) + 2)
        XCTAssertLessThanOrEqual(MemoryLayout.size(ofValue: bl), 2)
    }
    
    func testBitList64() {
        var bl = BitList<UInt64>(itemSize: 8)
        XCTAssertEqual(bl.bitWidth, 8)
        XCTAssertEqual(bl.itemSize, 8)
        listTest(bitList: bl)
        bl[0] = 1
        bl[7] = 11
        XCTAssertEqual(bl.rawValue, (11 << (8 * 7)) + 1)
        XCTAssertLessThanOrEqual(MemoryLayout.size(ofValue: bl), 16)
    }

}
