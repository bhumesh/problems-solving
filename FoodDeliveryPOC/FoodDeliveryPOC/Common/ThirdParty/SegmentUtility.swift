//
//  SegmentUtility.swift
//  DinDinnAssignment
//
//  Created by Mangrulkar on 16/10/20.
//  Copyright © 2020 Ashwinkumar Mangrulkar. All rights reserved.
//

import Foundation
import UIKit

class SegmentUtility {
    
    static func getTopSpacing(_ viewController: UIViewController) -> CGFloat {
        if let _ = viewController.splitViewController {
            return 0.0
        }
        
        var topSpacing: CGFloat = 0.0
        let navigationController = viewController.navigationController
        
        if navigationController?.children.last == viewController {
            if navigationController?.isNavigationBarHidden == false {
                topSpacing = UIApplication.shared.statusBarFrame.height
                if !(navigationController?.navigationBar.isOpaque)! {
                    topSpacing += (navigationController?.navigationBar.bounds.height)!
                }
            }
        }
        return topSpacing
    }
    
    static func getBottomSpacing(_ viewController: UIViewController) -> CGFloat {
        var bottomSpacing: CGFloat = 0.0
        
        if let tabBarController = viewController.tabBarController {
            if !tabBarController.tabBar.isHidden && !tabBarController.tabBar.isOpaque {
                bottomSpacing += tabBarController.tabBar.bounds.size.height
            }
        }
        
        return bottomSpacing
    }
}
