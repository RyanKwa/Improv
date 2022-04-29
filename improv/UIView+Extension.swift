//
//  UIView+Extension.swift
//  improv
//
//  Created by Ryan Vieri Kwa on 26/04/22.
//

import Foundation
import UIKit
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get{ return cornerRadius }
        set{
            self.layer.cornerRadius = newValue
        }
    }
}
