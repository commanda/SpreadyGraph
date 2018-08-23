//
//  VertexViewModel.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 8/23/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

struct VertexViewModel: Equatable {
    let mazeNode: MazeNode
    let shape: SKShapeNode
    var velocity: CGPoint
    var netForce: CGPoint
    
    var position: CGPoint {
        get {
            return shape.position
        }
        set {
            shape.position = newValue
        }
    }
    
    func removeViewFromScene() {
        shape.removeFromParent()
    }
    
}

