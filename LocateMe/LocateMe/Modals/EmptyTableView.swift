//
//  EmptyTableView.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-14.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
class EmptyTableView: UIView {
  
    @IBOutlet weak var SignUpBtn: UIButton!
    @IBOutlet weak var SignInBtn: UIButton!
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var EmptyImg: UIImageView!
    
    @IBOutlet var ParentView: UIView!
    @IBOutlet weak var DisplayView: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)
        instanceFromNib(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func instanceFromNib(frame: CGRect) {
        ParentView.frame = frame
        DisplayView.layer.cornerRadius = 10
        addSubview(ParentView)
    }
    
    @objc func animateOut(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.7, initialSpringVelocity: 1 , options: .curveEaseIn,animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
            self.alpha = 0
        }
        ){(complete) in
            if complete {
                self.removeFromSuperview()
            }
        }
    }
    @objc func animateIn(){
        self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        self.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.7, initialSpringVelocity: 1 , options: .curveEaseIn,animations: {
            self.transform = .identity
            self.alpha = 1
        })
    }
}



