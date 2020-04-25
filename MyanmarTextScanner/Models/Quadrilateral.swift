//
//  Quadrilateral.swift
//  Myanmar Lens
//
//  Created by Aung Ko Min on 25/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreGraphics

/// A data structure representing a quadrilateral and its position. This class exists to bypass the fact that CIRectangleFeature is read-only.

struct Quadrilateral: Transformable {
    
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint

    init(_ x: CIRectangleFeature) {
        topLeft = x.topLeft
        topRight = x.topRight
        bottomLeft = x.bottomLeft
        bottomRight = x.bottomRight
    }
    init(_ x: CITextFeature) {
        topLeft = x.topLeft
        topRight = x.topRight
        bottomLeft = x.bottomLeft
        bottomRight = x.bottomRight
    }
    init(_ x: VNRectangleObservation) {
        topLeft = x.topLeft
        topRight = x.topRight
        bottomLeft = x.bottomLeft
        bottomRight = x.bottomRight
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    init(_ x: VNTextObservation) {
        topLeft = x.topLeft
        topRight = x.topRight
        bottomLeft = x.bottomLeft
        bottomRight = x.bottomRight
    }
    init(_ x: VNRecognizedTextObservation) {
        topLeft = x.topLeft
        topRight = x.topRight
        bottomLeft = x.bottomLeft
        bottomRight = x.bottomRight
        if let top = x.topCandidates(1).first {
            text = top.string
        }
    }
    init(_ x: VNDetectedObjectObservation) {
        let rect = x.boundingBox
        topLeft =  CGPoint(x: rect.minX, y: rect.maxY)
        topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
    }
    init(_ rect: CGRect) {
        topLeft =  CGPoint(x: rect.minX, y: rect.minY)
        topRight = CGPoint(x: rect.maxX, y: rect.minY)
        bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
    }
    
    var text: String = String()
    mutating func applyText(text: String) {
        self.text = text
    }
    var textRects: [(String, CGRect)]?

    var description: String {
        return "topLeft: \(topLeft), topRight: \(topRight), bottomRight: \(bottomRight), bottomLeft: \(bottomLeft)"
    }
    
    /// The path of the Quadrilateral as a `UIBezierPath`
    var rectanglePath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }

    var cornersPath: UIBezierPath {
        let rect = frame.insetBy(dx: -10, dy: -10)
        let thickness: CGFloat = 2
        let length: CGFloat = min(rect.height, rect.width) / 3
        let radius: CGFloat = 0
        let t2 = thickness / 2
        let path = UIBezierPath()
        
        let topSpace = self.topLeft.y
        let leftSpace = self.topLeft.x
        // Top left
        path.move(to: CGPoint(x: t2 + leftSpace, y: length + radius + t2 + topSpace))
        path.addLine(to: CGPoint(x: t2 + leftSpace, y: radius + t2 + topSpace))
        path.addArc(withCenter: CGPoint(x: radius + t2 + leftSpace, y: radius + t2 + topSpace), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: length + radius + t2 + leftSpace, y: t2 + topSpace))
        
        // Top right
        path.move(to: CGPoint(x: rect.width - t2 + leftSpace, y: length + radius + t2 + topSpace))
        path.addLine(to: CGPoint(x: rect.width - t2 + leftSpace, y: radius + t2 + topSpace))
        path.addArc(withCenter: CGPoint(x: rect.width - radius - t2 + leftSpace, y: radius + t2 + topSpace), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: rect.width - length - radius - t2 + leftSpace, y: t2 + topSpace))
        
        // Bottom left
        path.move(to: CGPoint(x: t2 + leftSpace, y: rect.height - length - radius - t2 + topSpace))
        path.addLine(to: CGPoint(x: t2 + leftSpace, y: rect.height - radius - t2 + topSpace))
        path.addArc(withCenter: CGPoint(x: radius + t2 + leftSpace, y: rect.height - radius - t2 + topSpace), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: length + radius + t2 + leftSpace, y: rect.height - t2 + topSpace))
        
        // Bottom right
        path.move(to: CGPoint(x: rect.width - t2 + leftSpace, y: rect.height - length - radius - t2 + topSpace))
        path.addLine(to: CGPoint(x: rect.width - t2 + leftSpace, y: rect.height - radius - t2 + topSpace))
        path.addArc(withCenter: CGPoint(x: rect.width - radius - t2 + leftSpace, y: rect.height - radius - t2 + topSpace), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.width - length - radius - t2 + leftSpace, y: rect.height - t2 + topSpace))
        return path
    }
    
    var labelRect: CGRect {
        let rect = frame
        let size = CGSize(width: 90, height: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        return CGRect(origin: CGPoint(x: rect.midX - size.width/2, y: rect.minY-size.height), size: size)
    }
    /// The perimeter of the Quadrilateral
    var perimeter: Double {
        let perimeter = topLeft.distanceTo(point: topRight) + topRight.distanceTo(point: bottomRight) + bottomRight.distanceTo(point: bottomLeft) + bottomLeft.distanceTo(point: topLeft)
        return Double(perimeter)
    }
    
    /// Applies a `CGAffineTransform` to the quadrilateral.
    ///
    /// - Parameters:
    ///   - t: the transform to apply.
    /// - Returns: The transformed quadrilateral.
    func applying(_ transform: CGAffineTransform) -> Quadrilateral {
        var x = Quadrilateral(topLeft: topLeft.applying(transform), topRight: topRight.applying(transform), bottomRight: bottomRight.applying(transform), bottomLeft: bottomLeft.applying(transform))
        x.text = text
        return x
    }
    func createTextLayer() -> CATextLayer? {
        guard !text.isEmpty else { return nil }
        let textLayer = CATextLayer()
        let rect = frame
        
        textLayer.fontSize = rect.height
        textLayer.font = UIFont.systemFont(ofSize: textLayer.fontSize)
        textLayer.isWrapped = true
        textLayer.contentsScale = 2
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor(white: 0.3
            , alpha: 0.8).cgColor
        textLayer.frame = rect
        textLayer.string = text
        return textLayer
    }

    func isWithin(_ distance: CGFloat, ofRectangleFeature rectangleFeature: Quadrilateral) -> Bool {
        
        let topLeftRect = topLeft.surroundingSquare(withSize: distance)
        
        if !topLeftRect.contains(rectangleFeature.topLeft) {
            return false
        }
        
        let topRightRect = topRight.surroundingSquare(withSize: distance)
        if !topRightRect.contains(rectangleFeature.topRight) {
            return false
        }
        
        let bottomRightRect = bottomRight.surroundingSquare(withSize: distance)
        if !bottomRightRect.contains(rectangleFeature.bottomRight) {
            return false
        }
        
        let bottomLeftRect = bottomLeft.surroundingSquare(withSize: distance)
        if !bottomLeftRect.contains(rectangleFeature.bottomLeft) {
            return false
        }
        
        return true
    }
    
    /// Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
    mutating func reorganize() {
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let ySortedPoints = sortPointsByYValue(points)
        
        guard ySortedPoints.count == 4 else {
            return
        }
        
        let topMostPoints = Array(ySortedPoints[0..<2])
        let bottomMostPoints = Array(ySortedPoints[2..<4])
        let xSortedTopMostPoints = sortPointsByXValue(topMostPoints)
        let xSortedBottomMostPoints = sortPointsByXValue(bottomMostPoints)
        
        guard xSortedTopMostPoints.count > 1,
            xSortedBottomMostPoints.count > 1 else {
                return
        }
        
        topLeft = xSortedTopMostPoints[0]
        topRight = xSortedTopMostPoints[1]
        bottomRight = xSortedBottomMostPoints[1]
        bottomLeft = xSortedBottomMostPoints[0]
    }
    
    
    // Convenience functions
    
    /// Sorts the given `CGPoints` based on their y value.
    /// - Parameters:
    ///   - points: The poinmts to sort.
    /// - Returns: The points sorted based on their y value.
    private func sortPointsByYValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.y < point2.y
        }
    }
    
    /// Sorts the given `CGPoints` based on their x value.
    /// - Parameters:
    ///   - points: The points to sort.
    /// - Returns: The points sorted based on their x value.
    private func sortPointsByXValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.x < point2.x
        }
    }
}

extension Quadrilateral {
    
    func toCartesian(withHeight height: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withHeight: height)
        let topRight = self.topRight.cartesian(withHeight: height)
        let bottomRight = self.bottomRight.cartesian(withHeight: height)
        let bottomLeft = self.bottomLeft.cartesian(withHeight: height)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    
    var frame: CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x - topLeft.x, height: bottomRight.y - topRight.y)
    }
}

extension Quadrilateral: Equatable {
    public static func == (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
        return lhs.topLeft == rhs.topLeft && lhs.topRight == rhs.topRight && lhs.bottomRight == rhs.bottomRight && lhs.bottomLeft == rhs.bottomLeft
    }
}

extension Array where Element == Quadrilateral {
    
    /// Finds the biggest rectangle within an array of `Quadrilateral` objects.
    func biggest() -> Quadrilateral? {
        let biggestRectangle = self.max(by: { (rect1, rect2) -> Bool in
            return rect1.perimeter < rect2.perimeter
        })
        
        return biggestRectangle
    }
    func smallest() -> Quadrilateral? {
        let biggestRectangle = self.max(by: { (rect1, rect2) -> Bool in
            return rect1.perimeter > rect2.perimeter
        })
        
        return biggestRectangle
    }
}
