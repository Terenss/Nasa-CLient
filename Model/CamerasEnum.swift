//
//  CamerasEnum.swift
//  Nasa-Client
//
//  Created by Dmitrii on 11.08.2021.
//

import Foundation

enum Cameras: String, CaseIterable {
    case fhaz, rhaz, mast, chemcam, mahli, mardi, navcam, pancam, minites, all
    
    var fullName: String {
        switch self {
        case .fhaz: return "Front Hazard Avoidance Camera"
        case .rhaz: return "Rear Hazard Avoidance Camera"
        case .mast: return "Mast Camera"
        case .chemcam: return "Chemistry and Camera Complex"
        case .mahli: return "Mars Hand Lens Imager"
        case .mardi: return "Mars Descent Imager"
        case .navcam: return "Navigation Camera"
        case .pancam: return "Panoramic Camera"
        case .minites: return "Miniature Thermal Emission Spectrometer (Mini-TES)"
        case .all: return "ALL"
        }
    }
}
