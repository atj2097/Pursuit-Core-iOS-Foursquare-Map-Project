//
//  PictureModel.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import Foundation
import UIKit
// MARK: - Picture
struct Picture: Codable {
    let totalHits: Int
    let hits: [Hit]
    let total: Int
    
    static func getPictureTestData(from data:Data) -> [Hit]? {
           do {
               let newPicArray = try JSONDecoder().decode(Picture.self, from: data)
            return newPicArray.hits
            
           } catch let error {
               print(error)
               return nil
           }
       }
}

// MARK: - Hit
struct Hit: Codable {
    let largeImageURL: String?
    let webformatHeight, webformatWidth, likes, imageWidth: Int?
    let id, userID, views, comments: Int?
    let pageURL: String?
    let imageHeight: Int?
    let webformatURL: String?
    let previewHeight: Int?
    let tags: String?
    let downloads: Int?
    let user: String?
    let favorites, imageSize, previewWidth: Int?
    let userImageURL: String?
    let previewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case largeImageURL, webformatHeight, webformatWidth, likes, imageWidth, id
        case userID = "user_id"
        case views, comments, pageURL, imageHeight, webformatURL, previewHeight, tags, downloads, user, favorites, imageSize, previewWidth, userImageURL, previewURL
    }
}

