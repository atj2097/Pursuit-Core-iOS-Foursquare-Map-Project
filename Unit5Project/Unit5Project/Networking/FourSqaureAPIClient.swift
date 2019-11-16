//
//  FourSqaureAPIClient.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//


import Foundation

class MapAPIClient {
    static let client = MapAPIClient()
    
    func getMapData(query:String,latLong:String,completionHandler:@escaping(Result<[Venue],AppError>)-> Void) {
        
        let url = "https://api.foursquare.com/v2/venues/search?client_id=\(Secrets.client_id)&client_secret=\(Secrets.client_secret)&ll=\(latLong)&query=\(query.lowercased())&v=20191104"
        
        guard let urlStr = URL(string: url) else {
            completionHandler(.failure(.badURL))
            return
      }
        
        NetworkHelper.manager.performDataTask(withUrl: urlStr, andMethod: .get) { (results) in
            switch results {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let data):
                do {
                    let mapData = try
                        JSONDecoder().decode(Foursquare.self, from: data)
                    if let map = mapData.response?.venues{
                    completionHandler(.success(map))
                    }
                } catch let error {
                   print(error)
                    completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
    }
}
