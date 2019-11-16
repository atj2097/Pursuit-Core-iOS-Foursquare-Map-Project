//
//  FourSquare.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import Foundation
struct Foursquare: Codable {
    let meta: Meta
    let response: Response?
    
    static func getTestData(from data:Data) -> [Venue]? {
        do {
            let newMap = try JSONDecoder().decode(Foursquare.self, from: data)
            return newMap.response?.venues
        } catch let error {
            print(error)
            return nil
        }
    }
}

// MARK: - Meta
struct Meta: Codable {
    let code: Int
    let requestID: String

    enum CodingKeys: String, CodingKey {
        case code
        case requestID = "requestId"
    }
}

// MARK: - Response
struct Response: Codable {
    let venues: [Venue]?
}

// MARK: - Venue
struct Venue: Codable {
    let id, name: String
    let location: Location?
    let categories: [Category]?
    //let delivery: Delivery?
    let venuePage: VenuePage?
    let currentCategory:String?
    func returnCategory() -> String {
        return categories?[0].name ?? "Food Venue"
    }
}

// MARK: - Category
struct Category: Codable {
    let id: String
    let name: String
    let pluralName: String
    let shortName: String
    let icon: CategoryIcon
    let primary: Bool
    
    
}

// MARK: - CategoryIcon
struct CategoryIcon: Codable {
    let iconPrefix: String
    let suffix: Suffix

    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

enum Suffix: String, Codable {
    case png = ".png"
}

// MARK: - Location
struct Location: Codable {
    let address: String?
    let crossStreet: String?
    let lat, lng: Double
    let labeledLatLngs: [LabeledLatLng]?
    let distance: Int?
    let postalCode: String?
    let cc: String?
    let city: String?
    let state: String?
    let country: String?
    let formattedAddress: [String]
    
    func returnFormattedAddress() -> String {
       
  return      """
        
        \(address ?? "Address Not Available")(\(crossStreet ?? "Cross Street Not Available"))
        \(city ?? "City Not Available"),\(state ?? "State Not Available") \(postalCode ?? "Postal Code Not Available")
        \(country ?? "Country Not Available")
        
        """
       
    }
}





// MARK: - LabeledLatLng
struct LabeledLatLng: Codable {
    let label: String
    let lat, lng: Double
}





// MARK: - VenuePage
struct VenuePage: Codable {
    let id: String
}
