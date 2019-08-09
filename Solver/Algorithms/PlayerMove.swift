//
//  PlayerMove.swift
//  Solver
//
//  Created by Toby on 2019-08-07.
//  Copyright © 2019 Toby. All rights reserved.
//

import Foundation

final class PlayerMove: GameAlgorithm{
    
    init(){ }
    
    func makeMove(_ game: GameState) -> GameState? {
        if let move = getInput(
            prompt: { """
            \(game.moves())
            \(game.playerSymbol()) move: 
            """ } ,
            failedMessage: "Invalid move",
            parser: { game.isValidMove(move: $0) ? $0 : nil },
            terminateCondition: pure1(true)
            ).first {
            return game.move(move: move)
        }
        return nil
    }
    
}
