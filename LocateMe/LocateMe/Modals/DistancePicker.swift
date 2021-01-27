//
//  DistancePicker.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-14.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
class DistancePicker: UIView{
  
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var TitleLbl: UILabel!
    
    @IBOutlet var ParentView: UIView!
    @IBOutlet weak var DistancePickerView: UIView!
    
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var SaveBtn: UIButton!
    
    @IBOutlet weak var DistancePickerHeight: NSLayoutConstraint!
    
    var originalRow : Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("DistancePicker", owner: self, options: nil)
        instanceFromNib(frame: frame)
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
 
    func instanceFromNib(frame: CGRect) {
        if #available(iOS 11.0, *) {
            DistancePickerView.clipsToBounds = true
            DistancePickerView.layer.cornerRadius = 10
            DistancePickerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        ParentView.frame = frame
        pickerView.layer.cornerRadius = 10
        pickerView.backgroundColor = .veryLightGray
        addSubview(ParentView)
    }
 
    @objc func animateOut(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1 , options: .curveEaseIn,animations: {
                self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
               self.alpha = 0
           }
           ){(complete) in
               if complete {
                   self.removeFromSuperview()
               }
               
           }
       }
    @objc func animateIn(){
            self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
           self.alpha = 0
           UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping:  0.9, initialSpringVelocity: 1 , options: .curveEaseIn,animations: {
               self.transform = .identity
               self.alpha = 1
           })
    }
}


// MARK: - Picker View Functions

extension MapController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedDistanceRow = row
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
         
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distanceValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return view.frame.height/15
    }
       
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
           var label: UILabel
           if let view = view as? UILabel { label = view }
           else { label = UILabel() }

           label.text = "\(distanceValues[row]) km"
           label.numberOfLines = 1
           label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: self.view.frame.height/20)
                 
           label.adjustsFontSizeToFitWidth = true
           label.minimumScaleFactor = 0.1
           label.textColor = .lightGray
           return label
       }

    @objc func tappedSaveBtn(){
        if distanceView.originalRow != pickedDistanceRow{
            searchDistance = Double(distanceValues[pickedDistanceRow]) * 1000.0
        }
        removeViews()
    }
    
    @objc func removePickerAndDimView(){
        pickedDistanceRow = distanceView.originalRow
        removeViews()
    }
    
    func removeViews(){
        distanceView.animateOut()
        removeDimmedView()
    }
}
