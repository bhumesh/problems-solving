//
//  CustomSegmentProtocol.swift
//  DinDinnAssignment
//
//  Created by Mangrulkar on 16/10/20.
//  Copyright © 2020 Ashwinkumar Mangrulkar. All rights reserved.
//

import Foundation

@objc public protocol CustomSegmentProtocol {
    typealias didIndexChange = (Int)->Void
    var change:didIndexChange{get set}
    func setSelected(index: Int, animator: Bool)
}
