//
//  OffersViewController.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 22/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import UIKit
class OffersViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var heightContraints: NSLayoutConstraint!
    
    var offers = [OffersModel]()
    private var index = 0
    private let animationDuration: TimeInterval = 0.25
    private let switchingInterval: TimeInterval = 2
    private var transition = CATransition()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.contentMode = .scaleAspectFill
        heightContraints.constant = UIScreen.main.bounds.height * 0.30
    }
    
    func animateImageView() {
        CATransaction.begin() //Begin the CATransaction
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {[weak self] in
                self?.animateImageView()
            }
        }
        
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        
        imageView.layer.add(transition, forKey: kCATransition)
        if self.offers.count > 0 {
            imageView.image = UIImage(named: self.offers[index].imageUrl ?? "")
        }
        CATransaction.commit()
        
        if index < self.offers.count - 1 {
            index = index + 1
        } else {
            index = 0
        }
        pageControl.currentPage = index
    }
    func didReceiveOffers(_ offers: [OffersModel]) {
        self.offers = offers
        pageControl.numberOfPages = self.offers.count
        animateImageView()
    }
}

extension OffersViewController: ViewControllerViewSource {
    func headerViewForMixObserveContentOffsetChange() -> UIView? {
        return self.view
    }
}
