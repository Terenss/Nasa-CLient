//
//  CustomTextField.swift
//  Nasa-Client
//
//  Created by Dmitrii on 24.08.2021.
//

import UIKit
import Foundation

class CustomTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        } else if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return false
        } else if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
        
    }
}
