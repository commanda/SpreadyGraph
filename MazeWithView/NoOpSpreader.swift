//
//  NoOpSpreader.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 9/13/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

class NoOpSpreader : VertexPlacer {
    func spreadOut(vertices: Set<VertexViewModel>, rect: CGRect) -> Bool {
        return true
    }
}
