//
//  ListInfoView.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-31.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit

class ListDetailController: UIViewController,UITableViewDataSource, DirectionBtnDelegate{

    @IBOutlet weak var ListIcon: UIImageView!
    @IBOutlet weak var ListTitle: UILabel!
    @IBOutlet weak var PlacesCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var OptionsBtn: UIButton!
    @IBOutlet weak var CloseBtn: UIButton!
    
    @IBOutlet weak var VisualEffectView: UIVisualEffectView!
    
    var places: [Place]?
    var list: List?
    var listTitle: String = ""
    
    var userId: String = ""
    var fromMapView: Bool = false
    
    let placeDbController = PlaceDbController()
    let listDbController = ListDbController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
        self.tableView.dataSource = self
        tableView.rowHeight = 90

        if list == nil {
            let icon = self.setPlaceIcon(title: listTitle)
            ListIcon.image = icon.0
            ListIcon.tintColor = icon.1
            ListTitle.text = listTitle
        }
        else{
            ListIcon.image = list?.icon
            ListIcon.tintColor = list?.color
            ListTitle.text = list?.title
        }

        PlacesCount.text = (places?.count ?? 0).placeSingularity()
    }

// MARK: - Tableview Functions
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListDetailCell", for: indexPath) as! ListDetailCell
        
        let row = indexPath.row
                   
        guard let place = places?[row] else {return cell}
        
        cell.configure(with: place.name, category: place.category, address: place.address, phone: place.phone, web: place.website, placeIcon: place.icon, placeColor: place.color, distance: place.distance)
        
        cell.CallBtn.tag = row
        cell.DirectionBtn.tag = row
        cell.directionDelegate = self
        cell.CallBtn.addTarget(self, action: #selector(didTapCall(_:)), for: .touchUpInside)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard let place = self.places?[row], let listId = list?.id else {return}
        if listId == "" {
            let alert = UIAlertController(title: "Are you sure?",
                            message: "This place will be deleted from all lists",
                            preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in}
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction!) -> Void in
                self.resetListTable(row: row)
                self.listDbController.removePlaceFromAllList(userId:self.userId, placeId: place.id, listTitle: place.list)
                self.placeDbController.deletePlace(userId: self.userId, placeId: place.dbId)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
                       
            present(alert, animated: true, completion: nil)
      
        }else{
            resetListTable(row: row)
            listDbController.removePlaceFromList(userId: userId, listId: listId, placeId: place.id)
             
             if place.list.count == 1 {
                 placeDbController.deletePlace(userId: userId, placeId: place.dbId)
             }else{
                 guard let listTitle = list?.title else {return}
                 placeDbController.removeListInPlace(userId: userId, placeId: place.dbId, listTitle: listTitle)
             }
        }
       
    }
    
    func resetListTable(row: Int){
        places?.remove(at: row)
        tableView.reloadData()
        PlacesCount.text = (places?.count ?? 0).placeSingularity()
    }
    

// MARK: - Button Actions
    @objc func didTapCall(_ button: UIButton) {
        let tag = button.tag
        guard let phone = places?[tag].phone else {return}
        makeCall(phone: phone)
    }
      
    @objc func didTapCell(_ cell: UITableViewCell) {
        let tag = cell.tag
        guard let phone = places?[tag].phone else {return}
        makeCall(phone: phone)
    }
      
    func didTapDirection(_ tag: Int) {
        guard let place = places?[tag] else{return}
        openDirection(place: place)
    }
      
    @IBAction func tappedCloseBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}



