//
//  ArrayExtensions.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 9/13/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation

extension Array {
    subscript(index: Int, s: Bool) -> Element? {
        guard index >= 0 && index < self.count else { return nil }
        return self[index]
    }
}
