//
//  main.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

/// Manages program initialization
class Main{
    
    /// The prefix of all classes in this project
    static let bundle = "\(String(reflecting: Main.self).split(separator: ".").first!)."
    
    /// Find a class withing this project
    ///
    /// - Parameter className: The name of the class 
    /// - Returns: The class if it exists, otherwise nil
    static func findClass<T>(className: String) -> T?{
        if let result = NSClassFromString(bundle + className){
            return result as? T
        }
        return nil
    }
    
    /// Build and start a game using commandline input
    static func startGame(input: () -> String?){
        
        guard let gameType: GameState.Type = getInput(
            prompt: pure1("Please type a game name: "),
            failedMessage: "Cannot find the game",
            parser: findClass,
            terminateCondition: pure2(true),
            inputStream: input).first else { return }
        
        guard var game = gameType.init(input: input) else { return }
        
        let algorithmTypes: [GameAlgorithm.Type] = getInput(
            prompt: pure1("Please type an algorithm name: "),
            failedMessage: "Cannot find the algorithm",
            parser: findClass,
            terminateCondition: { _, result in return result.count == game.numPlayer },
            inputStream: input)
        
        let algorithms = algorithmTypes.compactMap{ $0.init(game: game, input: input) }
        if algorithmTypes.count != game.numPlayer { return }
        
        while true {
            if let winners = game.winners {
                if winners.isEmpty {
                    print("Game end with no winner")
                } else if winners.count == 1 {
                    print("The winner is \(game.playerSymbol(player: winners[0])!)")
                } else {
                    print(winners.reduce("The winners are", { 
                        $0 + " \(game.playerSymbol(player: $1)!)" }))
                }
                return
            }
            print(game)
            game = algorithms[game.player].makeMove(game)!
        }
    }
    
}

// an example of pyraminx game
var input = [
    "Pyraminx",
    "g", "b", "y",
    "r", "y", "b",
    "r", "g", "y",
    "r", "b", "g",
    "y", "b", "g", "g", "y", "b",
    "y", "g", "y", "y", "g", "r",
    "g", "b", "r", "r", "r", "g",
    "b", "y", "b", "b", "r", "r",
    "AStarSearch",
//    "BFSHMulThread",
//    "20",
    "PyraminxManhattanH"
]

//Main.startGame{ popFirst(array: &input) }
Main.startGame(input: { readLine() })
