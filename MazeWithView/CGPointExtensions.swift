//
//  CGPointExtensions.swift
//  MazeWithView
//
//  Created by Amanda Wixted on 8/23/18.
//  Copyright © 2018 Meteor Grove Software. All rights reserved.
//

import Foundation


extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    func distanceFrom(_ other: CGPoint) -> CGFloat {
        return (pow(other.x - self.x, 2) + pow(other.y - self.y, 2)).squareRoot()
    }
}

