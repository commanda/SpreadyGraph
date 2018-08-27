//
//  Graph.swift
//  MazeGenInSwift
//
//  Created by Amanda Wixted on 8/22/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

class Graph {
    var nodes: Set<MazeNode>!
    
    let min: Int
    let max: Int
    
    init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
    
    func generate() {
        
        let numNodes = min + Int(arc4random_uniform(UInt32(max - min)))
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
        
        nodes = Set(collection)
    }
    
    func carveMaze() {
        /*
         Let C be a list of cells, initially empty. Add one cell to C, at random.
         Choose a cell from C, and carve a passage to any unvisited neighbor of that cell, adding that neighbor to C as well. If there are no unvisited neighbors, remove the cell from C.
         Repeat #2 until C is empty.
         */
        
        guard nodes.isEmpty == false else { return }
        
        
        var workingSet = Set<MazeNode>()
        let startNode = nodes.randomElement()!
        workingSet.insert(startNode)
        
        var visited = Set<MazeNode>()
        visited.insert(startNode)
        
        func anyUnvisitedSibling(of element: MazeNode) -> MazeNode? {
            return element.siblings.subtracting(visited).randomElement()
        }
        
        func chooseNewest() -> MazeNode? {
            return Array(workingSet).last
        }
        
        repeat {
            if let chosen = chooseNewest() {
                if let unvisitedSibling = anyUnvisitedSibling(of: chosen) {
                    chosen.carvePassage(to: unvisitedSibling)
                    workingSet.insert(unvisitedSibling)
                    visited.insert(unvisitedSibling)
                }
                else {
                    workingSet.remove(chosen)
                }
            }
        } while !workingSet.isEmpty
    }
    
    func uncarvePassages() {
        nodes.forEach { $0.uncarveAllPassages() }
    }
}



extension Graph: CustomStringConvertible {
    var description: String {
        return nodes.map({String(describing:$0)}).joined(separator: "\n")
    }
}

extension Set {
    func randomElement() -> Element? {
        guard self.isEmpty == false else { return nil }
        return Array(self)[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension Array {
    func randomElement() -> Element? {
        guard self.isEmpty == false else { return nil }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

