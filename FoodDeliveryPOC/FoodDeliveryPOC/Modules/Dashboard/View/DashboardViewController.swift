//
//  DashboardViewController.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 22/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let Segment_statu_titleNormal = UIFont(name: "PingFangSC-Regular", size: 18)!
let Segment_statu_titleSelected = UIFont(name: "PingFangSC-Medium", size: 24)!

protocol OfferViewPresenter: class {
    func didReceiveOffers(_ offers: [OffersModel])
}

class DashboardViewController: BaseViewController {
    
    var dashboardPresenter: ViewToPresenterDashboardProtocol?
    var customScrollVC: CustomScrollViewController<SegmentControl>!
    var menuList = [Cuisine]()
    var cuisines: [Cuisines]?
    weak var viewPresenter: OfferViewPresenter?
    var offers: Offers?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureControllers()
        DashboardRouter.updateDashboardModule(view: self)
        dashboardPresenter?.fetchDashboardItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureControllers() {
        reloadSegments(title: [], child: [UIViewController()], header: UIViewController())
    }
    
    private func reloadSegments(title: [String], child: [UIViewController], header: UIViewController) {
        if customScrollVC != nil {
            customScrollVC.removeFromParent()
            for subViview in self.view.subviews {
                subViview.removeFromSuperview()
            }
            customScrollVC.view = nil
        }
        let segment = SegmentControl(sectionTitles: title)
        setupSegment(segmentView: segment)
        
        customScrollVC = CustomScrollViewController<SegmentControl>.init(headerViewController: header, segmentControllers: child, segmentView: segment)
        customScrollVC.headerViewOffsetHeight = 0
        customScrollVC.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        customScrollVC.shouldScrollToBottomAtFirstTime = false
        customScrollVC.delegate = self
        customScrollVC.view.bounds = self.view.bounds
        super.view.addSubview(customScrollVC.view)
        super.addChild(customScrollVC)
        customScrollVC.didMove(toParent: self)
    }
    private func setupSegment(segmentView: SegmentControl) {
        
        segmentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        segmentView.selectionIndicatorHeight = 2
        
        segmentView.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), NSAttributedString.Key.font: Segment_statu_titleSelected]
        segmentView.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), NSAttributedString.Key.font: Segment_statu_titleNormal]
        segmentView.indicatorWidthPercent = 1
    }
    
}

extension DashboardViewController: ViewControllerViewSource {
    func cartAction(_ sender: Any) {
        dashboardPresenter?.showMenuController(navigationController: self.navigationController!, menuList: menuList, controller: self)
    }
}

extension UIViewController {
    private func trigger(selector: Selector) -> Observable<Void> {
        return rx.sentMessage(selector).map { _ in () }.share(replay: 1)
    }
    
    var viewWillAppearTrigger: Observable<Void> {
        return self.trigger(selector: #selector(self.viewWillAppear(_:)))
    }
    
    var viewDidAppearTrigger: Observable<Void> {
        return self.trigger(selector: #selector(self.viewDidAppear(_:)))
    }
    
    var viewWillDisappearTrigger: Observable<Void> {
        return self.trigger(selector: #selector(self.viewWillDisappear(_:)))
    }
    
    var viewDidDisappearTrigger: Observable<Void> {
        return self.trigger(selector: #selector(self.viewDidDisappear(_:)))
    }
}

extension DashboardViewController: PresenterToViewDashboardProtocol{
    func onOffersResponse(offers: Offers?) {
        self.offers = offers
    }
    func onCuisinesResponse(cuisines: [Cuisines]?) {
        self.cuisines = cuisines

        let vcs = cuisines?.map { model -> CuisineViewController in
            let child = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CuisineViewController") as! CuisineViewController
            child.type = model.type ?? ""
            child.delegate = self
            return child
        }
        
        let headerScroll = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OffersViewController") as! OffersViewController
        DispatchQueue.main.async { [weak self] in
            headerScroll.didReceiveOffers(self?.offers?.offers ?? [])
        }
        
        self.reloadSegments(title: cuisines?.compactMap {$0.type} ?? [],
                            child: vcs ?? [],
                            header: headerScroll)
    }
}

extension DashboardViewController: CuisineProtocol {
    func getCusinesForType(_ type: String) -> [Cuisine] {
        return self.cuisines?.filter{$0.type == type}.first?.items ?? []
    }
    
    func didAddToCart(cuisine: Cuisine, type: String) {
        
//        let added = self.cuisines?.filter{$0.type == type}.first?.items?.filter {$0.name == cuisine.name}.first
//        if let item = added {
//            self
//        }
        if let row = menuList.firstIndex(where: {$0.name == cuisine.name}) {
            menuList.remove(at: row)
            menuList.append(cuisine)
        } else {
            menuList.append(cuisine)
        }
        customScrollVC.batchLabel.text = "\(menuList.count)"
    }
}
