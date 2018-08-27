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
    
    private let vertexPlacer: VertexPlacer
    
    private var doneSpreadingOut = false
    
    required init?(coder aDecoder: NSCoder) {
        vertexPlacer = TensionSpreader()
        super.init(coder: aDecoder)
    }
    
    private func createGraph() {
        
        let numNodes = 10 + arc4random_uniform(30)
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
            let w:CGFloat = 20.0
            
            
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
        doneSpreadingOut = false
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
    
    private func spreadOut() {
        if !doneSpreadingOut {
            doneSpreadingOut = vertexPlacer.spreadOut(vertices: vertices)
        }
        // Re-draw the lines
        visualizeLines()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        spreadOut()
    }
}
