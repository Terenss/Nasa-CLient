//
//  Access.swift
//  Nasa-Client
//
//  Created by Dmitrii on 11.08.2021.
//

import Foundation
import Moya

enum RequestTarget {
    case requestWithParametrs(rover: String, camera: String, date: Date, page: Int)
}

extension RequestTarget: TargetType {
    var baseURL: URL {
        let uRL = URL(string: "https://api.nasa.gov/")
        return uRL!
    }
    
    var path: String {
        switch self {
        case .requestWithParametrs(let rover, _, _, _):
            return "mars-photos/api/v1/rovers/\(rover)/photos"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var parameters = [String:Any]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        parameters["api_key"] = "tmWb2pM85ASFF07a25t9TMuVjtz0gFGxXUV6IspF"
        switch self {
        case .requestWithParametrs(_, let camera, let date, let page):
            let stringFromDate = dateFormatter.string(from: date)
            parameters["earth_date"] = stringFromDate
            parameters["page"] = page
            if camera != "all" {
                parameters["camera"] = camera
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

