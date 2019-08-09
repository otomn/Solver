//
//  main.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

class Main{
    
    static let bundle = "\(String(reflecting: Main.self).split(separator: ".").first!)."
    
    static func findClass<T>(className: String) -> T?{
        if let result = NSClassFromString(bundle + className){
            return result as? T
        }
        return nil
    }
    
    static func startGame(){
        
        guard let gameType: GameState.Type = getInput(
            prompt: pure0("Please type a game name: "),
            failedMessage: "Cannot find the game",
            parser: findClass,
            terminateCondition: pure1(true) ).first else { return }
        
        guard var game = gameType.init() else { return }
        
        var count = 0
        let algorithmTypes: [GameAlgorithm.Type] = getInput(
            prompt: pure0("Please type an algorithm name: "),
            failedMessage: "Cannot find the algorithm",
            parser: findClass,
            terminateCondition: { _ in
                count += 1
                return count == game.numPlayer
        } )
        if algorithmTypes.count != game.numPlayer { return }
        
        let algorithms = algorithmTypes.map{ $0.init() }
        
        while true {
            if let winners = game.winners() {
                if winners.isEmpty {
                    print("Game end with a tie")
                }
                print(winners.reduce("Winners are", { "\($0) \($1)" }))
                return
            }
            print(game)
            game = algorithms[game.player].makeMove(game)!
        }
    }
    
}

Main.startGame()
