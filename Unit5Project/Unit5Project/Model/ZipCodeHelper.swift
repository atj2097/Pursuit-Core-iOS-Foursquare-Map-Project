//
//  ZipCodeHelper.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import UIKit
import CoreLocation

enum LocationFetchingError: Error {
    case error(Error)
    case noErrorMessage
}

class ZipCodeHelper {
    private init() {}
    
    static func getLatLong(fromZipCode zipCode: String, completionHandler: @escaping (Result<CLLocationCoordinate2D, LocationFetchingError>) -> Void) {
           let geocoder = CLGeocoder()
           DispatchQueue.global(qos: .userInitiated).async {
               geocoder.geocodeAddressString(zipCode){(placemarks, error) -> Void in
                   DispatchQueue.main.async {
                       if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate{
                           completionHandler(.success((coordinate)))
                       } else {
                           let locationError: LocationFetchingError
                           if let error = error {
                               locationError = .error(error)
                           } else {
                               locationError = .noErrorMessage
                           }
                           completionHandler(.failure(locationError))
                       }
                   }
               }
           }
       }
  
}
