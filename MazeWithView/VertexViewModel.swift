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

class VertexViewModel: Equatable, Hashable {
    static func == (lhs: VertexViewModel, rhs: VertexViewModel) -> Bool {
        return lhs.mazeNode == rhs.mazeNode
    }
    
    var hashValue: Int {
        return mazeNode.hashValue
    }
    
    let mazeNode: MazeNode
    let shape: SKShapeNode
    var velocity: CGPoint
    var netForce: CGPoint
    
    init(mazeNode: MazeNode, shape: SKShapeNode) {
        self.mazeNode = mazeNode
        self.shape = shape
        velocity = .zero
        netForce = .zero
    }
    
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

