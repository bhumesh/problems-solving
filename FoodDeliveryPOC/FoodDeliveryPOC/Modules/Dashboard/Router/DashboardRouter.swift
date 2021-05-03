//
//  DashboardModuleBuilder.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 23/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import UIKit

class DashboardRouter: PresenterToRouterDashboardProtocol {
    
    static func updateDashboardModule(view: DashboardViewController)  {
        
        let presenter: ViewToPresenterDashboardProtocol & InteractorToPresenterDashboardProtocol = DashboardPresenter()
        let interactor: PresenterToInteractorDashboardProtocol = DashboardInteractor()
        let router:PresenterToRouterDashboardProtocol = DashboardRouter()
        
        view.dashboardPresenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
    }
            
    static var mainstoryboard: UIStoryboard {
        return UIStoryboard(name:"Main", bundle: Bundle.main)
    }
    
    func pushToMenuScreen(navigationConroller navigationController: UINavigationController, menuList: [Cuisine], controller: DashboardViewController) {
//        guard let menu = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else {
//            return
//        }
//        menu.menuList = menuList
//        menu.delegate = controller.self
//        navigationController.pushViewController(menu, animated: true)
    }
}
