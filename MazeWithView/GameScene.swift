//
//  GameScene.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 8/22/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private let colors = [SKColor.darkGray, SKColor.orange, SKColor.magenta, SKColor.purple]
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var vertices = Set<VertexViewModel>()
    private var graph: Graph!
    
    private var lines = [SKShapeNode]()
    
    private func createGraph() {
        
        let numNodes = 5 + arc4random_uniform(10)
        var collection = [MazeNode]()
        for i in 0..<numNodes {
            let n = MazeNode(name: "\(i)")
            collection.append(n)
            
        }
        
        for i in 0..<collection.count {
            let n = collection[i]
            for j in 0..<collection.count {
                n.addSibling(collection[j])
            }
        }
        
        graph = Graph(with: Set(collection))
        
    }
    
    private func visualizeGraph() {
        
        vertices.forEach { $0.removeViewFromScene() }
        vertices.removeAll()
        
        let screenWidth = self.size.width
        let xlb = -screenWidth * 0.5
        let screenHeight = self.size.height
        let ylb = -screenHeight * 0.5
        
        graph.nodes.forEach { (mn: MazeNode) in
            let w = (screenWidth + self.size.height) * 0.05
            
            
            let rect = CGRect(x: xlb + CGFloat(arc4random_uniform(UInt32(screenWidth - w))),
                              y: ylb + CGFloat(arc4random_uniform(UInt32(screenHeight - w))),
                              width: w, height: w)
            let shape = SKShapeNode.init(ellipseOf: rect.size)
            shape.position = rect.origin
            shape.lineWidth = 2.5
            shape.strokeColor = SKColor.red
            shape.fillColor = colors.randomElement()!
            
            self.addChild(shape)
            
            let vertexVM = VertexViewModel(mazeNode: mn, shape: shape)
            vertices.insert(vertexVM)
            let text = SKLabelNode(attributedText: NSAttributedString(string: mn.name, attributes: [.font: NSFont.boldSystemFont(ofSize: 20),
                                                                                                    .foregroundColor: SKColor.green]))
            shape.addChild(text)
        }
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        resetGraph()
    }
    
    private func visualizeLines() {
        lines.forEach { $0.removeFromParent() }
        lines.removeAll()
        
        vertices.forEach { (vertex: VertexViewModel) in
            
            vertex.mazeNode.passages.forEach({ (sib: MazeNode) in
                guard let sibShape = vertices.filter({ $0.mazeNode == sib }).first?.shape else { return }
                
                let line = SKShapeNode.init()
                let pathToDraw = CGMutablePath()
                pathToDraw.move(to: vertex.shape.position)
                pathToDraw.addLine(to: sibShape.position)
                line.path = pathToDraw
                line.strokeColor = SKColor.cyan
                self.addChild(line)
                lines.append(line)
            })
        }
    }
    
    private func resetGraph() {
        createGraph()
        graph.reset()
        graph.carveMaze()
        visualizeGraph()
        visualizeLines()
    }
    
    func touchUp(atPoint pos : CGPoint) {
        resetGraph()
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        
        default:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    private let repulsion_scalar: CGFloat = 200.0
    private let attraction_scalar: CGFloat = 0.010
    private let velocity_scalar: CGFloat = 0.70
    
    private func spreadOut() {
        
        // For each node in our graph, calculate its replusion from all the other nodes, and its attraction to the nodes it has a passage to
        vertices.forEach { (v: VertexViewModel) in
            
            v.netForce = .zero
            
            vertices.forEach { (u: VertexViewModel) in
                guard u != v else { return }
                
                // squared distance between "u" and "v" in 2D space
                let rsq = ((v.position.x-u.position.x)*(v.position.x-u.position.x)+(v.position.y-u.position.y)*(v.position.y-u.position.y))
                
                // make them repulse
                v.netForce = v.netForce + (((v.position - u.position) / rsq) * repulsion_scalar)
            }
            // for each edge between our vertex in question and any other vertex, calculate the attraction between those two vertices
            v.mazeNode.passages.forEach { (other: MazeNode) in
                guard v.mazeNode != other else { return }
                guard let u = vertices.filter({ $0.mazeNode == other }).first else { return }
                
                // make them attract since they're connected by a passage
                v.netForce = v.netForce + ((u.position - v.position) * attraction_scalar)
            }
            
            v.velocity = (v.velocity + v.netForce) * velocity_scalar
        }
        
        // Now put the sprites in their new positions according to their netForces
        vertices.forEach { (v: VertexViewModel) in
            v.shape.position = v.velocity + v.shape.position
        }
        
        // Re-draw the lines
        visualizeLines()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let _ = currentTime - self.lastUpdateTime
        
        spreadOut()
        
        self.lastUpdateTime = currentTime
    }
}
