//
//  UIViewExtensions.swift
//  SwifterSwift
//
//  Created by Omar Albeik on 8/5/16.
//  Copyright © 2016 SwifterSwift
//
#if canImport(UIKit) && !os(watchOS)
import UIKit
public extension UIView {
    /// SwifterSwift: Size of view.
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    /// SwifterSwift: Width of view.
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    /// SwifterSwift: Height of view.
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    
    /// SwifterSwift: x origin of view.
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    /// SwifterSwift: y origin of view.
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    /// SwifterSwift: top of view.
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    /// SwifterSwift: left of view.
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    /// SwifterSwift: right of view.
    var right: CGFloat {
        get {
            return (frame.origin.x + frame.size.width)
        }
        set {
            var frame = self.frame
            frame.origin.x = (newValue - frame.size.width)
            self.frame = frame
        }
    }
    
    /// SwifterSwift: bottom of view.
    var bottom: CGFloat {
        get {
            return (frame.origin.y + frame.size.height)
        }
        set {
            var frame = self.frame
            frame.origin.x = (newValue - frame.size.height)
            self.frame = frame
        }
    }
    
    /// SwifterSwift: centerX of view.
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.x)
        }
    }
    
    /// SwifterSwift: centerY of view.
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
}
#endif
