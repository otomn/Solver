//
//  Util.swift
//  Solver
//
//  Created by Toby on 2019-08-08.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

func getInput<T>(prompt: () -> String, failedMessage: String, parser parse:(String) -> T?,
                 terminateCondition:(String) -> Bool) -> [T]{
    var result: [T] = []
    while true{
        print(prompt(), terminator: "")
        guard let input = readLine() else {
            print("Input stream closed")
            return result
        }
        if let parsed = parse(input) {
            result.append(parsed)
            if terminateCondition(input) {
                return result
            }
        } else {
            print(failedMessage)
        }
    }
}

func pure<T>(_ val: T) -> T{
    return val
}

func pure0<T>(_ val: T) -> () -> T{
    return { val }
}

func pure1<T>(_ val: T) -> (Any) -> T{
    return { _ in val}
}
