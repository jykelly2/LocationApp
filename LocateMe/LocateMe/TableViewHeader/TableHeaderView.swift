//
//  TableHeaderView.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-13.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
class TableHeaderView: UIView {
    
    @IBOutlet weak var StartTraceStack: UIStackView!
    @IBOutlet weak var StopTraceStack: UIStackView!
    @IBOutlet weak var RestartTraceStack: UIStackView!
    
    @IBOutlet weak var TraceImg: UIImageView!
    @IBOutlet weak var StopImg: UIImageView!
    @IBOutlet weak var RestartImg: UIImageView!
    
    var defaultTraceImg = UIImage()
    var defaultStopImg = UIImage()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instanceFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        instanceFromNib()
    }
    
    func instanceFromNib() {
        let view = Bundle.main.loadNibNamed("TableHeaderView", owner: self, options: nil)![0] as! UIView
        TraceImg.setUpIconImg(img: TraceImg.image!, color: UIColor.lightBlue, inset: 25.0)
        defaultTraceImg = TraceImg.image!
        defaultStopImg = StopImg.image!
        
        view.frame = self.bounds
        addSubview(view)
    }
}
