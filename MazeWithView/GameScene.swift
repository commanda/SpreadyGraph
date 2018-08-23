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
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var nodes = [SKShapeNode]()
    
    private let colors = [SKColor.darkGray, SKColor.orange, SKColor.magenta, SKColor.purple]
    
    private var graph: Graph!
    
    private var lines = [SKShapeNode]()
    
    private var mazeNodesToShapes = [MazeNode: SKShapeNode]()
    
    private func createGraph() {
        
        
        let frank = MazeNode(name: "Frank")
        let sarah = MazeNode(name: "Sarah")
        let jeanine = MazeNode(name: "Jeanine")
        let lawrence = MazeNode(name: "Lawrence")
        frank.addSibling(sarah)
        frank.addSibling(sarah) // no-op
        sarah.addSibling(jeanine)
        frank.addSibling(jeanine)
        lawrence.addSibling(frank)
        
        let gianni = MazeNode(name: "Gianni")
        let kim = MazeNode(name: "Kim")
        kim.addSibling(gianni)
        
        graph = Graph(with: [lawrence, frank, sarah, jeanine, gianni, kim])
        
    }
    
    private func visualizeGraph() {
        
        
        mazeNodesToShapes.values.forEach { $0.removeFromParent() }
        mazeNodesToShapes.removeAll()
        
        let screenWidth = self.size.width
        let xlb = -screenWidth * 0.5
        let screenHeight = self.size.height
        let ylb = -screenHeight * 0.5
        
        graph.nodes.forEach { (mn: MazeNode) in
            let w = (screenWidth + self.size.height) * 0.05
            let rect = CGRect(x: xlb + CGFloat(arc4random_uniform(UInt32(screenWidth - w))),
                              y: ylb + CGFloat(arc4random_uniform(UInt32(screenHeight - w))),
                              width: w, height: w)
            let node = SKShapeNode.init(ellipseOf: rect.size)
            node.position = rect.origin
            node.lineWidth = 2.5
            node.strokeColor = SKColor.red
            node.fillColor = colors.randomElement()!
            nodes.append(node)
            self.addChild(node)
            
            let text = SKLabelNode(attributedText: NSAttributedString(string: mn.name, attributes: [.font: NSFont.boldSystemFont(ofSize: 20),
                                                                                                    .foregroundColor: SKColor.green]))
            node.addChild(text)
            
            mazeNodesToShapes[mn] = node
        }
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        resetGraph()
    }
    
    private func visualizeLines() {
        lines.forEach { $0.removeFromParent() }
        lines.removeAll()
        
        graph.nodes.forEach { (mn: MazeNode) in
            
            let mnShape = mazeNodesToShapes[mn]!
            
            mn.passages.forEach({ (sib: MazeNode) in
                
                let sibShape = mazeNodesToShapes[sib]!
                
                let line = SKShapeNode.init()
                let pathToDraw = CGMutablePath()
                pathToDraw.move(to: mnShape.position)
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
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
