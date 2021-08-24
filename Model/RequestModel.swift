//
//  RequestModel.swift
//  Nasa-Client
//
//  Created by Dmitrii on 10.08.2021.
//

import Foundation

struct RequestModel: Codable {
    var photos: [Photo]
}

class Photo: Codable {
    var imagePath: String?
    var camera: Camera
    var rover: Rover
    var earthDate: String?
    
    enum CodingKeys: String, CodingKey {
        case camera, rover
        case imagePath = "img_src"
        case earthDate = "earth_date"
    }
}

struct Camera: Codable {
    var name: String?
    var fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

struct Rover: Codable {
    var name: String?
}

