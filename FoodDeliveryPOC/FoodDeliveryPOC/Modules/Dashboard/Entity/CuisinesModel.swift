//
//  CuisinesModel.swift
//  FoodDeliveryPOC
//
//  Created by BhumeshwerKatre on 22/11/20.
//  Copyright © 2020 BhumeshwerKatre. All rights reserved.
//

import Foundation
import ObjectMapper

class CuisinesData: Mappable {
    var cuisines: [Cuisines]?
    required init?(map: Map){
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        cuisines <- map["cuisines"]
    }
}
class Cuisines: Mappable {
    var items: [Cuisine]?
    var type: String?
    required init?(map: Map){
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        items <- map["items"]
        type <- map["type"]
    }
}

class Cuisine: Mappable {
    var name, description, extraDetail, imageUrl: String?
    var quantity: Int?
    var price: Double?

    required init?(map: Map){
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        description <- map["description"]
        extraDetail <- map["extradetail"]
        imageUrl <- map["imageUrl"]
        quantity <- map["quantity"]
        price <- map["price"]
    }
}
