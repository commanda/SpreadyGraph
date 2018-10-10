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
        
        func layoutInGrid() {
            
            let columns = 4
            
            let rows = (numNodes % columns == 0) ? numNodes / columns : (numNodes / columns) + 1
            
            var counter = 0
            var grid = [[MazeNode]]()
            for _ in 0..<columns {
                var column = [MazeNode]()
                for _ in 0..<rows {
                    guard counter < collection.count else { break }
                    column.append(collection[counter])
                    counter += 1
                }
                
                grid.append(column)
            }
            
            
            for i in 0..<columns {
                for j in 0..<rows {
                    guard let n = grid[i, true]?[j, true] else { continue }
                    
                    // Cardinals
                    if let u = grid[i, true]?[j-1, true] {
                        n.addSibling(u)
                    }
                    if let r = grid[i+1, true]?[j, true] {
                        n.addSibling(r)
                    }
                    if let d = grid[i, true]?[j+1, true]{
                        n.addSibling(d)
                    }
                    if let l = grid[i-1, true]?[j, true]{
                        n.addSibling(l)
                    }
                    
                    if Constants.connectDiagonals {
                        // Diagonals
                        if let ul = grid[i-1, true]?[j-1, true] {
                            n.addSibling(ul)
                        }
                        if let ur = grid[i+1, true]?[j+1, true] {
                            n.addSibling(ur)
                        }
                        if let dr = grid[i+1, true]?[j+1, true] {
                            n.addSibling(dr)
                        }
                        if let dl = grid[i-1, true]?[j+1, true]{
                            n.addSibling(dl)
                        }
                    }
                }
            }
        }
        
        func layoutAllInLine () {
            for i in 0..<collection.count {
                let n = collection[i]
                
                guard i > 0 else { continue }
                let l = collection[i-1]
                n.addSibling(l)
                
                guard i < collection.count - 1 else { continue }
                let r = collection[i+1]
                n.addSibling(r)
            }
        }
        
        layoutInGrid()
        
        nodes = Set(collection)
    }
    
    func carveMaze() {
        carveMazeEverything()
    }
    
    func carveMazeEverything() {
        for n in nodes {
            for s in n.siblings {
                n.carvePassage(to: s)
            }
        }
    }
    
    func carveMazeGrowingTree(){
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
        
        func chooseRandom() -> MazeNode? {
            return workingSet.randomElement()
        }
        
        let chooser = arc4random_uniform(2) == 0 ? chooseRandom : chooseNewest
        
        repeat {
            if let chosen = chooser() {
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
    
    func makeExtraPassages() {
        // now poke some extra holes so the maze isn't just a boring spanning tree
        for _ in 0...(arc4random_uniform(UInt32(nodes.count))) {
            let node = nodes.randomElement()!
            let potentialPassages = node.siblings.subtracting(node.passages)
            potentialPassages.randomElement()?.carvePassage(to: node)
        }
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

