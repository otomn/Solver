//
//  Util.swift
//  Solver
//
//  Created by Toby on 2019-08-08.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Prompt for user input, return a list of parsed result
///
/// Sample usage: 
///
/// ```
/// var lst = getInput(
///     prompt: { _ in return "Type an integer please: " },
///     failedMessage: "That is not an integer",
///     parser: Int.init,
///     )
/// ```
///    
/// - When function runs, it will prompt:
///
///   `Type an integer please: `
///
/// Where the user can type at the end of the line.
/// - If the user types an invalid string, the program will print the `failedMessage`
///   and print the `prompt` again.
///
///   `Type an integer please: hi`
///
///   `That is not an integer`
///
///   `Type an integer please: `
///
/// Loop runs until user types a valid input or close the input stream
///
/// - If the user types a valid string, the result will be store.
///   In the example above, the default option is used for `terminateCondition`
///   which returns when there is one parsed result
///
///   `Type an integer please: 5`
///
///   `lst` will now have value `[5]`.
///
/// - If the input stream is closed unexpectedly, 
///   `getInput` will return with all the valid
///   results it has received, meaning the program could return with `[]`
///
/// - parameters:
///   - prompt: A function that takes parsed results and return a prompt for user input
///   - failedMessage: A string that will be printed if parse failed
///   - parser: A function that can parse `T` from a string, return `nil` if failed
///   - terminateCondition: A function that takes the input string and parsed result and returns whether it should return (by default, only get one result)
///     `getInput` should return
/// - returns: A list of parsed result
func getInput<T>(prompt: ([T]) -> String, 
                 failedMessage: String, 
                 parser parse: (String) -> T?,
                 terminateCondition: (String, [T]) -> Bool = { $1.count == 1 },
                 inputStream: () -> String? = { readLine() }
    ) -> [T]{
    var result: [T] = []
    while true{
        print(prompt(result), terminator: "")
        guard let input = inputStream() else {
            print("Input stream closed")
            return result
        }
        if let parsed = parse(input) {
            result.append(parsed)
            if terminateCondition(input, result) {
                return result
            }
        } else {
            if terminateCondition(input, result) {
                return result
            }
            print(failedMessage)
        }
    }
}

/// A function that returns the input without any modification
///
/// - Parameter val: The value that will be returned
/// - Returns: `val`
func pure<T>(_ val: T) -> T{
    return val
}

/// Returns a function that takes 1 input and returns `val`
///
/// ```
/// var p = pure(5)
/// print(p(0)) // prints 5
/// ```
///
/// - Parameter val: The value where the returned function will return
/// - Returns: A function that takes 1 input and returns `val`
func pure1<T>(_ val: T) -> (Any) -> T{
    return { _ in val}
}

/// Return and remove the first element of the array
///
/// - Parameter array: Source array
/// - Returns: First element
func popFirst<T>(array: inout [T]) -> T?{
    if array.isEmpty { return nil }
    return array.removeFirst()
}

func pow(_ base: Int, _ power: Int) -> Int?{
    let result = pow(Double(base), Double(power))
    if result >= Double(Int.max) {
        return nil
    }
    return Int(result)
}

extension String {
    
    subscript(index: Int) -> String.Index{
        return self.index(startIndex, offsetBy: index)
    }
    
    func split(separatorString: String, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [String] {
        var str = self
        var result: [String] = []
        var part = ""
        while str.count > 0 && result.count < maxSplits {
            if str.hasPrefix(separatorString) {
                str = String(str[str[separatorString.count] ..< str.endIndex])
                if !omittingEmptySubsequences || part != "" {
                    result.append(part)
                }
                part = ""
            } else {
                part.append(str.removeFirst())
            }
        }
        part += str
        if !omittingEmptySubsequences || part != "" {
            result.append(part)
        }
        return result
    }
}
