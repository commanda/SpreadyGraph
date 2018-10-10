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
    private var graph = Graph(min: 20, max: 30)
    
    private var lines = [SKShapeNode]()
    
    private let vertexPlacer: VertexPlacer
    
    private var doneSpreadingOut = false
    
    required init?(coder aDecoder: NSCoder) {
        vertexPlacer = Constants.vertexPlacer
        super.init(coder: aDecoder)
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
            
            shape.isHidden = !Constants.drawVertices
            
            let vertexVM = VertexViewModel(mazeNode: mn, shape: shape)
            vertices.insert(vertexVM)
            if Constants.drawVertexLabels {
                let text = SKLabelNode(attributedText: NSAttributedString(string: mn.name, attributes: [.font: NSFont.boldSystemFont(ofSize: 20),
                                                                                                    .foregroundColor: SKColor.white]))
                shape.addChild(text)
            }
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
                line.strokeColor = SKColor.white
                line.strokeTexture = SKTexture(imageNamed: "linetexture")
                line.lineWidth = 10
                line.lineCap = .round
                self.addChild(line)
                lines.append(line)
            })
        }
    }
    
    private func sCurve() {
        
        /*
         -(ccBezierConfig)bezierForStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint curviness:(CGFloat)alpha
         {
         CGPoint basis1 = ccpLerp(startPoint, endPoint, 0.3333);
         CGPoint basis2 = ccpLerp(startPoint, endPoint, 0.6666);
         
         // Get a point on the perpendicular line of each of the control points
         CGPoint vector = ccpSub(endPoint, startPoint);
         
         // First point is to the right, second is to the left, of the line between the start point and end point
         CGPoint v1 = ccpRPerp(vector);
         CGPoint v2 = ccpPerp(vector);
         
         // Translate our two perpendicular vectors over onto our chosen basis points
         CGPoint s1 = ccpAdd(basis1, v1);
         CGPoint s2 = ccpAdd(basis2, v2);
         
         // Apply the alpha to control curviness
         CGPoint l1 = ccpLerp(basis1, s1, alpha);
         CGPoint l2 = ccpLerp(basis2, s2, alpha);
         
         ccBezierConfig bezier = (ccBezierConfig){
         endPoint,    // end point
         l1,            // control point 1
         l2            // control point 2
         };
         
         return bezier;
         }
         */
    }
    
    private func resetGraph() {
        doneSpreadingOut = false
        graph.generate()
        graph.uncarvePassages()
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
            doneSpreadingOut = vertexPlacer.spreadOut(vertices: vertices, rect: self.frame)
        }
        // Re-draw the lines
        visualizeLines()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        spreadOut()
    }
}
