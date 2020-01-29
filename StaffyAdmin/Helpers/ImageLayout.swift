//
//  ImageLayout.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 29/01/2020.
//  Copyright © 2020 Aidan Miskella. All rights reserved.
//

import Foundation
import UIKit

class ImageLayout: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
    }
}
