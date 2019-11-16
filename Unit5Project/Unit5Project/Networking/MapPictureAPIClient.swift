//
//  MapPictureAPIClient.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import Foundation

class MapPictureAPIClient {
    static let manager = MapPictureAPIClient()
    
    func getFourSquarePictureData(venueID:String,completionHandler:@escaping(Result<[Item],AppError>)-> Void) {
        let url = "https://api.foursquare.com/v2/venues/\(venueID)/photos?client_id=\(Secrets.client_id)&client_secret=\(Secrets.client_secret)&v=20191104&limit=1"
   
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
                    let mapData = try JSONDecoder().decode(PictureWrapper.self, from: data)
                
                    completionHandler(.success(mapData.response.photos.items))
                } catch {
                    completionHandler(.failure(.invalidJSONResponse))
                }
            }
        }
    }
}
