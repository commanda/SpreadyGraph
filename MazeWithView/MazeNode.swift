//
//  MazeNode.swift
//  MazeGenInSwift
//
//  Created by Amanda Wixted on 8/22/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

class MazeNode {
    let name: String!
    
    var siblings: Set<MazeNode>
    var passages: Set<MazeNode>
    
    init(name: String) {
        self.name = name
        siblings = Set<MazeNode>()
        passages = Set<MazeNode>()
    }
    
    func addSibling(_ sibling: MazeNode) {
        guard !siblings.contains(sibling) else { return }
        siblings.insert(sibling)
        sibling.addSibling(self)
    }
    
    func carvePassage(to sibling: MazeNode) {
        guard siblings.contains(sibling) else { return }
        guard !passages.contains(sibling) else { return }
        passages.insert(sibling)
        sibling.carvePassage(to: self)
    }
    
    func uncarvePassage(to sibling: MazeNode) {
        guard passages.contains(sibling) else { return }
        passages.remove(sibling)
        sibling.uncarvePassage(to: self)
    }
    
    func uncarveAllPassages() {
        passages.forEach { $0.uncarvePassage(to: self) }
    }
}

extension MazeNode: Hashable {
    
    var hashValue: Int { return name.hashValue }
    
    static func == (lhs: MazeNode, rhs: MazeNode) -> Bool {
        return lhs.name == rhs.name
    }
}

extension MazeNode: CustomStringConvertible {
    var description: String { return "\(name!): siblings: \(siblings.map { $0.name! } ), passages: \(passages.map { $0.name! })" }
}
