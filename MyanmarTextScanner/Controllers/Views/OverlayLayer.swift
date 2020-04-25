//
//  OverlayLayer.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
final class OverlayLayer: CAShapeLayer {
    
    
    var cameraTransform = CGAffineTransform.identity
    private var previousTextHolderFrame = CGRect.zero
    var isTracking = false

    private let textHolderLayer: CALayer = {
        $0.speed = 999
        return $0
    }(CALayer())
    
    func apply(_ textRects: [(String, CGRect)]) {
       
        textHolderLayer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        textRects.forEach {
            let textLayer = CATextLayer()
            let rect = $0.1
            textLayer.fontSize = rect.height * 0.8
            textLayer.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: textLayer.fontSize))
            textLayer.isWrapped = true
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.backgroundColor = UIColor(white: 0.3
                , alpha: 0.5).cgColor
            textHolderLayer.addSublayer(textLayer)
            var fitRect = rect
            fitRect.size.width = $0.0.width(withConstrainedHeight: rect.height, font: UIFont.systemFont(ofSize: textLayer.fontSize))
            textLayer.frame = fitRect
            textLayer.string = $0.0
        }
    }
    
    
    
    
    func apply(_ quads: [Quadrilateral]) {
        
        let transformedQuads = quads.map{ $0.applying(cameraTransform)}
        
        if isTracking {
            let rect = transformedQuads.map{$0.frame}.reduce(CGRect.null, {$0.union($1)})
            if rect.trashole(trashold: 10) == textHolderLayer.frame.trashole(trashold: 10) {
                textHolderLayer.frame.size = rect.size
            } else {
                textHolderLayer.frame.origin = rect.origin
                
                if previousTextHolderFrame == .zero {
                    previousTextHolderFrame = rect
                    strokeColor = nil
                    textHolderLayer.frame = rect
                }else {
                    let x = rect.width / previousTextHolderFrame.width
                    let y = rect.height / previousTextHolderFrame.height
                    let transform = CGAffineTransform(scaleX: x, y: y)
                    textHolderLayer.setAffineTransform(transform)
                }
            }
        } else {
            strokeColor = DetectorType.current.color
            let mutablePath = UIBezierPath()
            transformedQuads.forEach{ mutablePath.append($0.rectanglePath)}
            path = mutablePath.cgPath
        }
    }

    func setupTextsLayers() {
        speed = 999
        addSublayer(textHolderLayer)
    }
    
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
