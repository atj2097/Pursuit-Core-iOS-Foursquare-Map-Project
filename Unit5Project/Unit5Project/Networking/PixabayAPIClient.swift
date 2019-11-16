//
//  Pixabay.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//



import Foundation
import UIKit

class PictureAPIClient {
    static let shared = PictureAPIClient()
    
    func getPictures(searchTerm:String,completionHandler:@escaping (Result<[Hit],AppError>) -> Void) {
        
        
        
        
        let urlString = "https://pixabay.com/api/?q=\(searchTerm.replacingOccurrences(of: " ", with: "_"))&key=\(Secrets.pixaBayKey.lowercased())&page=1&per_page=5"
        
        guard let url  = URL(string: urlString) else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (results) in
            switch results {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let URLisWorking):
                do { let decoded = try JSONDecoder().decode(Picture.self, from: URLisWorking)
                    
                    completionHandler(.success(decoded.hits))
                } catch {
                    completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
        
        
}
}

