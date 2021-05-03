//
//  DashboardProtocol.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 23/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import UIKit

class DashboardPresenter: ViewToPresenterDashboardProtocol {
    
    var view: PresenterToViewDashboardProtocol?
    var interactor: PresenterToInteractorDashboardProtocol?
    var router: PresenterToRouterDashboardProtocol?

    func fetchDashboardItems() {
        interactor?.fetchOffers()
        interactor?.fetchCuisines()
    }
    
    func showMenuController(navigationController: UINavigationController, menuList: [Cuisine], controller: DashboardViewController) {
        router?.pushToMenuScreen(navigationConroller: navigationController, menuList: menuList, controller: controller)
    }
}

extension DashboardPresenter: InteractorToPresenterDashboardProtocol {
    func didReceiveOffers(offers: Offers?) {
        view?.onOffersResponse(offers: offers)
    }
    func didReceiveCuisines(cuisines: [Cuisines]?) {
        view?.onCuisinesResponse(cuisines: cuisines)
    }
}
