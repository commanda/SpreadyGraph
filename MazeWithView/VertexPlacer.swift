//
//  VertexPlacer.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 8/27/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

protocol VertexPlacer {
    func spreadOut(vertices: Set<VertexViewModel>, rect: CGRect) -> Bool
}
