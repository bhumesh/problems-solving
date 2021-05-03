//
//  RxScrollExtension.swift
//  DinDinnAssignment
//
//  Created by Mangrulkar on 16/10/20.
//  Copyright © 2020 Ashwinkumar Mangrulkar. All rights reserved.
//

import Foundation
import EasyPeasy
import RxCocoa
import RxSwift

extension Reactive where Base == UIScrollView {
     var MatchHeightEqualToContent:Binder<CGFloat>{
        return Binder(self.base){(scroll,value) in
            scroll.easy.layout(
                Height(value)
            )
        }
    }
    
    // export to public the real content height.
     var realContentHeight: Observable<CGFloat> {
        return self.observeWeakly(CGSize.self, "contentSize").map{$0?.height ?? 0}
    }
}

