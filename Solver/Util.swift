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
///     termniateCondition: pure2(true)
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
///   In the example above, `terminateCondition` is a function that always return `true`,
///   So the program will terminate after a valid string is received:
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
///   - terminateCondition: A function that takes the input string and parsed resulta and returns whether 
///     `getInput` should return
/// - returns: A list of parsed result
func getInput<T>(prompt: ([T]) -> String, 
                 failedMessage: String, 
                 parser parse: (String) -> T?,
                 terminateCondition: (String, [T]) -> Bool, 
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

/// Returns a function that takes 0 input and returns `val`
///
/// ```
/// var p = pure(5)
/// print(p()) // prints 5
/// ```
///
/// - Parameter val: The value where the returned function will return
/// - Returns: A function that takes 0 input and returns `val`
func pure0<T>(_ val: T) -> () -> T{
    return { val }
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

/// Returns a function that takes 2 input and returns `val`
///
/// ```
/// var p = pure(5)
/// print(p(0, 1)) // prints 5
/// ```
///
/// - Parameter val: The value where the returned function will return
/// - Returns: A function that takes 1 input and returns `val`
func pure2<T>(_ val: T) -> (Any, Any) -> T{
    return { _, _ in val}
}

/// Return and remove the first element of the array
///
/// - Parameter array: Source array
/// - Returns: First element
func popFirst<T>(array: inout [T]) -> T?{
    if array.isEmpty { return nil }
    return array.removeFirst()
}
