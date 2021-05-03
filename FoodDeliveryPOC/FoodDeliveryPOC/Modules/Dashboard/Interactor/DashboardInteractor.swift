//
//  DashboardProtocol.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 23/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import ObjectMapper

class DashboardInteractor: PresenterToInteractorDashboardProtocol {
    
    var presenter: InteractorToPresenterDashboardProtocol?
    
    func fetchCuisines() {
        if let resultData = self.loadDataFromFile("Cuisines") {
            do {
                let jsonData = try JSONSerialization.jsonObject(with: resultData, options: .allowFragments)
                if let object = Mapper<CuisinesData>().map(JSONObject: jsonData) {
                    self.presenter?.didReceiveCuisines(cuisines: object.cuisines)
                    return
                }
            } catch {
                print("error:\(error)")
            }
        }
        
        self.presenter?.didReceiveCuisines(cuisines: nil)
    }
    func fetchOffers() {
        if let resultData = self.loadDataFromFile("Offers") {
            do {
                let jsonData = try JSONSerialization.jsonObject(with: resultData, options: .allowFragments)
                if let object = Mapper<Offers>().map(JSONObject: jsonData) {
                    self.presenter?.didReceiveOffers(offers: object)
                    return
                }
            } catch {
                print("error:\(error)")
            }
        }
        
        self.presenter?.didReceiveOffers(offers: nil)
    }
    
    func loadDataFromFile(_ file: String) -> Data? {
        if let url = Bundle.main.url(forResource: file, withExtension: "json") {
            do {
                return try Data(contentsOf: url, options: .mappedIfSafe)
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}
