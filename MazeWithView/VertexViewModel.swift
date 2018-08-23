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

struct VertexViewModel {
    let mazeNode: MazeNode
    let shape: SKShapeNode
    var velocity: CGPoint
    var netForce: CGPoint
    
    func removeViewFromScene() {
        shape.removeFromParent()
    }
}
