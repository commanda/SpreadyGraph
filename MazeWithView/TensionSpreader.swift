//
//  TensionSpreader.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 8/27/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

class TensionSpreader: VertexPlacer {
    
    //private let repulsion_scalar: CGFloat = 50.0
    //private let attraction_scalar: CGFloat = 0.100
    private let velocity_scalar: CGFloat = 0.8
    private let avgNetForceThreshold: CGFloat = 0.01
    
    func spreadOut(vertices: Set<VertexViewModel>, rect: CGRect) -> Bool {
        
        let rect = rect.insetBy(dx: 30, dy: 30)
        
        func iterateSpreadOut() -> Bool {
            
            var doneSpreadingOut = false
            
            // For each node in our graph, calculate its replusion from all the other nodes, and its attraction to the nodes it has a passage to
            vertices.forEach { (v: VertexViewModel) in
                
                v.netForce = .zero
                
                vertices.forEach { (u: VertexViewModel) in
                    guard u != v else { return }
                    
                    // squared distance between "u" and "v" in 2D space
                    let rsq = ((v.position.x-u.position.x)*(v.position.x-u.position.x)+(v.position.y-u.position.y)*(v.position.y-u.position.y))
                    
                    // make them repulse
                    let repulsion = CGFloat(u.mazeNode.repulsion + v.mazeNode.repulsion) / 2.0
                    v.netForce = v.netForce + (((v.position - u.position) / rsq) * repulsion)
                }
                // for each edge between our vertex in question and any other vertex, calculate the attraction between those two vertices
                v.mazeNode.passages.forEach { (other: MazeNode) in
                    guard v.mazeNode != other else { return }
                    guard let u = vertices.filter({ $0.mazeNode == other }).first else { return }
                    
                    // make them attract since they're connected by a passage
                    let attraction = CGFloat(u.mazeNode.attraction + v.mazeNode.attraction) / 2.0
                    v.netForce = v.netForce + ((u.position - v.position) * attraction)
                }
                
                v.velocity = (v.velocity + v.netForce) * velocity_scalar
            }
            
            let avgNetForce = vertices.reduce(0) { (value: CGFloat, v:VertexViewModel) -> CGFloat in
                value + v.netForce.distanceFrom(.zero)
                } / CGFloat(vertices.count)
            
            if avgNetForce < avgNetForceThreshold {
                doneSpreadingOut = true
            }
            
            // Now put the sprites in their new positions according to their netForces
            vertices.forEach { (v: VertexViewModel) in
                v.shape.position = v.velocity + v.shape.position
                // But keep them on screen
                //v.shape.position = v.shape.position.clamp(to: rect)
            }
            
            return doneSpreadingOut
        }
        
        if !Constants.animateSpreadOut {
            while !iterateSpreadOut() {}
            return true
        } else {
            return iterateSpreadOut()
        }
        
    }
}
