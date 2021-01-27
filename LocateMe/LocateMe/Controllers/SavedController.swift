//
//  SavedController.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-25.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import MapKit

class SavedController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, EditListDelegate, UICollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NewListBtn: UIButton!
    
    @IBOutlet weak var SeeAllBtn: UIButton!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
 
    var userId: String = ""
    
    let userDbController = UserDbController()
    let listDbController = ListDbController()
    let placeDbController = PlaceDbController()
    
    var lists = [List]()
    var places = [Place]()
    var counts = [Int]()
    
    var empty: Bool = false
    var fromSignUp: Bool = false
    
   override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent{
            guard let mapController =  (self.navigationController?.viewControllers[0]) as? MapController else {return}
            if fromSignUp{
                mapController.setUpSearchView()
            }else{
                mapController.retrieveLists()
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userId != "" {
            retrieveHistory()
            retrieveLists()
        }
        setLargeTitleNavigationBar(navTitle: "Saved", backText: "Map")
        showNavigationBar(animated: true)
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        tableView.rowHeight = viewAreaWidth/4.3
    }

    func retrieveLists(){
        listDbController.getAllList(userId: self.userId){(allLists) in
            if allLists.count > 0{
                self.updateViewHeight(count: allLists.count)
                self.lists = allLists
                self.reloadTableView()
     
            }else{
                self.listDbController.addDefaultLists(userId: self.userId){ (defaultLists) in
                    self.lists.append(contentsOf: defaultLists)
                    self.reloadTableView()
                }
            }
        }
    }

    func retrieveHistory(){
        placeDbController.getAllPlaces(userId: self.userId){(allPlaces) in
            let count = allPlaces.count
            
            switch count {
                case 0:
                    self.empty = true
                    self.SeeAllBtn.isHidden = true
                case 1:
                    self.SeeAllBtn.isHidden = true
                    self.places = allPlaces
                default:
                    self.places = allPlaces
                    self.places = self.places.sorted { $0.id > $1.id }
            }
            self.collectionView.reloadData()
        }
    }
    
    func reloadTableView(){
              self.lists = self.lists.sorted { $0.title.lowercased() < $1.title.lowercased() }
              self.tableView.reloadData()
    }
    
    func updateViewHeight(count: Int){
         let tableCellHeight = (self.viewAreaWidth/4.5)*CGFloat(count)
         let yPos = (view.subviews.map { $0.frame.height }).reduce(60, +)
         let scrollHeight = self.view.frame.height - yPos
         let height = yPos < view.frame.height ? scrollHeight + tableCellHeight : tableCellHeight
         self.tableViewHeight.constant = height
     }
    
// MARK: - Collectionview Functions
       
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if empty == true{
            return 1
        }
        return places.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            if empty == true{
                cell.emptyConfigure()
                cell.ItemIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAddNew(_:))))
            }else{
                let place = places[indexPath.row]
                cell.configure(with: place.name, itemImg: place.icon, categoryLabel:place.category, listImg: place.icon, listLabel: place.list[0], color: place.color)
            }
            cell.BackView.roundCorners(corners: [.topLeft, .topRight], radius: safeAreaHeight/80)
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.lightGrey.cgColor
            cell.layer.cornerRadius = safeAreaHeight/80
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !(empty), let listController = storyboard?.instantiateViewController(withIdentifier: "ListController") as? ListController else { return }
             listController.currentPlace = places[indexPath.row]
             listController.userId = userId
            self.navigationController?.pushViewController(listController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: view.frame.width * 0.4, height: view.frame.width * 0.429)
    }
    
// MARK: - Tableview Functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists[indexPath.row]
        let selectedPlaces = places.filter({list.placeIds.contains($0.id)})
        
        guard let listController = storyboard?.instantiateViewController(withIdentifier: "ListController") as? ListController else { return }

        listController.matchingPlaces = selectedPlaces
        listController.list = list
        listController.userId = userId
        
       self.navigationController?.pushViewController(listController, animated: true)
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
            
        let list = lists[indexPath.row]
        cell.configure(with: list.icon, listName: list.title, listCount: list.count, color: list.color)
        cell.delegate = self
        cell.EditBtn.tag = indexPath.row
        cell.addSlightShadow()
        
        return cell
    }
    
// MARK: - Button Actions
    
    @objc func tappedAddNew(_ sender: UIImageView){
         self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func SeeAllTapped(_ sender: UIButton) {
           guard let listController = storyboard?.instantiateViewController(withIdentifier: "ListController") as? ListController else { return }
           let list = List(title: "Recently Saved", id: "", icon: UIImage(systemName:"bookmark")!.withRenderingMode(.alwaysTemplate), color: .lightPurple, placeIds: [], count: 0)
           
           listController.modalPresentationStyle = .overFullScreen
           listController.matchingPlaces = places
           listController.userId = userId
           listController.list = list
           self.navigationController?.pushViewController(listController, animated: true)
    }
       

    @IBAction func NewListTapped(_ sender: UIButton) {
               let alert = UIAlertController(title: "New List", message: "Give title to the list", preferredStyle: .alert)

               let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
                   let input = alert.textFields![0].text
                   let icon = self.view.setListIcon(title: input!)
                       
                   self.listDbController.addNewList(title: input!, userId: self.userId){
                           (listId) in
                       let list = List(title: input!, id: listId, icon: icon.0, color: icon.1, placeIds: [],count: 0)
                       
                       self.lists.append(list)
                       self.lists = self.lists.sorted { $0.title.lowercased() < $1.title.lowercased() }
                       
                       self.updateViewHeight(count: self.lists.count)
                       self.tableView.reloadData()
                   }
               }
                saveAction.isEnabled = false

               let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in }

               alert.addTextField {
                      (textFieldName: UITextField!) in
                      textFieldName.placeholder = "Enter list title"
               }

               NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
                        let textFieldName = alert.textFields?[0]
                        saveAction.isEnabled =  !textFieldName!.text!.isEmpty
                }
               alert.addAction(cancelAction)
               alert.addAction(saveAction)
               
               present(alert, animated: true, completion: nil)
    }

    func didTapEdit(_ tag: Int) {
             let list = self.lists[tag]
             let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         
              let editAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { action -> Void in
               
                   let list = self.lists[tag]
                   let selectedPlaces = self.places.filter({list.placeIds.contains($0.id)})

                   guard let editController = self.storyboard?.instantiateViewController(withIdentifier: "EditListController") as? EditListController else { return }
                   editController.modalPresentationStyle = .overFullScreen
                   editController.userId = self.userId
                   editController.list = list
                   editController.places = selectedPlaces
                   self.navigationController?.pushViewController(editController, animated: true)
              }

              let shareAction: UIAlertAction = UIAlertAction(title: "Share", style: .default) { action -> Void in
                  print("Share Action pressed")
              }

              let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

            actionSheetController.addAction(editAction)
            actionSheetController.addAction(shareAction)
            actionSheetController.addAction(cancelAction)
           
           if list.title.checkIfDefaultList() == false{
               let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
                   self.placeDbController.removeListFromAllPlaces(userId: self.userId, listTitle: list.title) {(placeId) in
                       if let index = self.places.firstIndex(where: {$0.id == placeId}) {
                           self.places.remove(at: index)
                           self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                       }
                   }
                   self.listDbController.deleteList(userId: self.userId, listId: list.id)
                   self.lists.remove(at: tag)
                   self.tableView.reloadData()
                   
                   self.updateViewHeight(count: self.lists.count)
               }
               actionSheetController.addAction(deleteAction)
           }

            // works for both iPhone & iPad
          actionSheetController.popoverPresentationController?.sourceView = self.view
          present(actionSheetController, animated: true)
     }
}
