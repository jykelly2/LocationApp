//
//  PlaceDetailController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-02.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import Contacts
import SafariServices
import MapKit

class PlaceDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var PlaceName: UILabel!
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var PlaceIcon: UIImageView!
    @IBOutlet weak var Distance: UILabel!
    @IBOutlet weak var DirectionBtn: UIButton!
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var CallBtn: UIButton!
    @IBOutlet weak var SaveBtn: UIButton!
    @IBOutlet weak var CallStack: UIStackView!
    @IBOutlet weak var ShareStack: UIStackView!
    @IBOutlet weak var SaveStack: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TableHeader: UIView!
    
    var currentPlace: Place?
    var currentList: List?
    var userId: String = ""
    var fromMapView: Bool = false
    
    let userDbController = UserDbController()
    let placeDbController = PlaceDbController()
 
    let sectionTitle = ["Address", "Phone", "Website"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
       guard let place = currentPlace else {return}
        
        PlaceName.text = place.name
        PlaceIcon.setUpIconImg(img: place.icon, color: place.color, inset: 30.0)
        Distance.text = place.category + " . " + place.distance.roundToSingleDigit()
                 
        let direction_string = "Directions\n\(place.time) min"
        let information_string = "\(place.time) min"
        let range = (direction_string as NSString).range(of: information_string)
        let attribute = NSMutableAttributedString.init(string: direction_string)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: self.viewAreaHeight/60)!, range: range)
                 
        DirectionBtn.setAttributedTitle(attribute, for: .normal)
        DirectionBtn.titleLabel?.textAlignment = .center
        DirectionBtn.titleLabel?.textColor = .white

        DirectionBtn.layer.cornerRadius = viewAreaHeight/65
                 
        CallStack.addBackground(color: .secondarySystemGroupedBackground)
        ShareStack.addBackground(color: .secondarySystemGroupedBackground)
        SaveStack.addBackground(color: .secondarySystemGroupedBackground)
                 
        CallStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedCall)))
        SaveStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSave)))
        ShareStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedShare)))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = viewAreaWidth/4.5
        
       if currentPlace?.dbId == "" && userId != "" {
          retrieveCurrentPlaceData(place: place)
        }
    }
    
    func retrieveCurrentPlaceData(place:Place){
        placeDbController.getPlaceByAddress(userId: userId, place: place ){ (place) in
            if place.dbId != ""{
                self.currentPlace = place
            }
        }
    }
    
// MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 3
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailCell", for: indexPath) as! PlaceDetailCell
        
        let section = indexPath.row
        let information = selectInfo(row: section)
        cell.configure(with: sectionTitle[section] , sectionInfo: information, section: section)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentPlace = currentPlace else { return }
        switch indexPath.row{
            case 1:
                self.makeCall(phone: currentPlace.phone)
            case 2:
                guard let url = currentPlace.website else { return }
                self.openWebsite(url: url)
            default:
                return print("address")
        }
    }
    
    func selectInfo(row: Int) -> String{
          guard let place = currentPlace else {return ""}
          switch row {
          case 0:
              return place.address
          case 1:
              return place.phone
          default:
              var information = ""
              information = place.website?.host ?? ""
              information = information.replacingOccurrences(of: "www.", with: "", options: [.caseInsensitive, .regularExpression])
              return information
          }
    }
    
// MARK: - Button Actions

    @IBAction func tappedDirection(_ sender: UIButton) {
        guard let currentPlace = currentPlace else { return }
        openDirection(place: currentPlace)
    }
      
    @objc func tappedCall(){
        guard let phone = currentPlace?.phone else { return }
        makeCall(phone: phone)
    }
    @objc func tappedSave(){
        if self.userId != ""{
            guard let savePlaceModal = storyboard?.instantiateViewController(withIdentifier: "SavePlaceView") as? SavePlaceView else { return }
            savePlaceModal.modalPresentationStyle = .overFullScreen
            savePlaceModal.userId = self.userId
            savePlaceModal.currentPlace = currentPlace
            savePlaceModal.alreadySavedPlace = currentPlace?.list.count ?? 0 > 0 ? true : false
            self.navigationController?.pushViewController(savePlaceModal, animated: true)
        }else{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let mapController = storyBoard.instantiateViewController(withIdentifier: "MapController") as? MapController else { return }
            mapController.setUpEmptyView()
        }
    }
    @objc func tappedShare(){
        guard let coordinate = currentPlace?.coordinate else {return}
        openShare(coordinate: coordinate)
    }
    
    @IBAction func tappedClosedBtn(_ sender: UIButton) {
        if currentList == nil{
            self.navigationController?.popViewController(animated: true)
        }
    }

}


