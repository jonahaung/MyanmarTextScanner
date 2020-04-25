//
//  RectFunnel.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 24/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation

typealias QuadBlock = [Quadrilateral]

final class RectFunnel {
    
    private let minimumInitialThreshold = 30
    private var initialCount = 0

    func filter(_ block: QuadBlock) -> QuadBlock? {
        
        if minimumInitialThreshold > initialCount {
            initialCount += 1
            return nil
        }
        
        return block
    }
    
    
    func reset() {
        initialCount = 0
    }
}
