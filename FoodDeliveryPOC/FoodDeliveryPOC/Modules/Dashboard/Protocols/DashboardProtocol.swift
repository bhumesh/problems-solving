//
//  DashboardProtocol.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 23/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import UIKit

protocol ViewToPresenterDashboardProtocol: class {
    var view: PresenterToViewDashboardProtocol? { get set }
    var interactor: PresenterToInteractorDashboardProtocol? { get set }
    var router: PresenterToRouterDashboardProtocol? { get set }
    
    func fetchDashboardItems()
    func showMenuController(navigationController: UINavigationController, menuList: [Cuisine], controller: DashboardViewController)
}

protocol PresenterToViewDashboardProtocol: class {
    func onOffersResponse(offers: Offers?)
    func onCuisinesResponse(cuisines: [Cuisines]?)
}

protocol PresenterToRouterDashboardProtocol: class {
    static func updateDashboardModule(view: DashboardViewController)
    func pushToMenuScreen(navigationConroller navigationController: UINavigationController, menuList: [Cuisine], controller: DashboardViewController)
}

protocol PresenterToInteractorDashboardProtocol: class {
    var presenter:InteractorToPresenterDashboardProtocol? { get set }
    func fetchCuisines()
    func fetchOffers()
}

protocol InteractorToPresenterDashboardProtocol: class {
    func didReceiveOffers(offers: Offers?)
    func didReceiveCuisines(cuisines: [Cuisines]?)
}
