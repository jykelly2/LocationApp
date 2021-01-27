//
//  DimmedView.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-14.
//  Copyright © 2021 JK. All rights reserved.
//

import Foundation
import UIKit
class DimmedView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = 10
        self.frame = frame
        self.backgroundColor = .black
        self.alpha = 0.3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
