//
//  RoversEnum.swift
//  Nasa-Client
//
//  Created by Dmitrii on 11.08.2021.
//

import Foundation

enum Rovers: String, CaseIterable {
    case Curiosity
    case Opportunity
    case Spirit
    
    
    var roverCameras: [Cameras] {
        switch self {
        case .Curiosity: return [.fhaz, .rhaz, .mast, .chemcam, .mahli, .mardi, .navcam, .all]
        case .Opportunity, .Spirit: return [.fhaz, .rhaz, .navcam, .pancam, .minites, .all]
        }
    }
}
