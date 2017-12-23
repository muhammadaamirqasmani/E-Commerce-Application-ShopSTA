//
//  File.swift
//  EasyShopping
//
//  Created by admin on 11/11/2017.
//  Copyright © 2017 MuhammadAamir. All rights reserved.
//

import Foundation
import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 10
        let color = UIColor(red: 119.0/255.0, green: 211.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        self.layer.shadowColor = color.cgColor
        super.awakeFromNib()
    }
    
}
