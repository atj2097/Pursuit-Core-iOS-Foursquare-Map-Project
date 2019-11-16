//
//  MapPicture.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import Foundation


// MARK: - PictureWrapper
struct PictureWrapper: Codable {
    let meta: PictureMeta
    let response: PictureResponse
}

// MARK: - Meta
struct PictureMeta: Codable {
    let code: Int
    let requestID: String

    enum CodingKeys: String, CodingKey {
        case code
        case requestID = "requestId"
    }
}

// MARK: - Response
struct PictureResponse: Codable {
    let photos: Photos
}

// MARK: - Photos
struct Photos: Codable {
    let count: Int
    let items: [Item]
    let dupesRemoved: Int
}

// MARK: - Item
struct Item: Codable {
    let id: String
    let createdAt: Int
    let itemPrefix: String
    let suffix: String
    let width, height: Int
    
    let checkin: Checkin
    let visibility: String

    enum CodingKeys: String, CodingKey {
        case id, createdAt
        case itemPrefix = "prefix"
        case suffix, width, height,checkin, visibility
    }
    func returnPictureURL() -> String{
       return "\(itemPrefix)original\(suffix)"
    }
}

// MARK: - Checkin
struct Checkin: Codable {
    let id: String
    let createdAt: Int
    let type: String
    let timeZoneOffset: Int
}


