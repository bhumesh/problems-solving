//
//  OffersModel.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 22/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import ObjectMapper
class Offers: Mappable {
    var offers: [OffersModel]?
    required init?(map: Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
        offers <- map["offers"]
    }
}
class OffersModel: Mappable {
    var imageUrl: String?
    var offerID: String?
    var offerDesc: String?
    
    required init?(map: Map){
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        imageUrl <- map["imageUrl"]
        offerID <- map["offerID"]
        offerDesc <- map["offerDesc"]
    }
}
