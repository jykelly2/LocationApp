//
//  SavePlaceView.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-26.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

class SavePlaceView: UIViewController, UITableViewDelegate, UITableViewDataSource, CheckBoxDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newList: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private let userDbController = UserDbController()
    private let listDbController = ListDbController()
    private let placeDbController = PlaceDbController()
    
    var userId: String = ""
    var currentPlace: Place?
    var alreadySavedPlace: Bool = false
    
    private var selectedLists = [Int]()
    private var lists = [List]()
    private var ids =  [Int]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userId != "" && currentPlace != nil{
            retrieveLists()
            retrieveHistoryCount()
        }
        setDefaultTitleNavigationBar(navTitle: "Save to list", backText: "")
        showNavigationBar(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = traitCollection.userInterfaceIdiom == .pad ?  viewAreaHeight/9.5 : viewAreaWidth/4.3
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        newList.layer.borderWidth = 2
        newList.layer.borderColor = UIColor.lightGrey.cgColor
        newList.layer.cornerRadius = safeAreaHeight/50
    }
    
    func retrieveLists(){
        listDbController.getAllList(userId: self.userId){(allLists) in
            if allLists.count > 0{
                self.lists = allLists
            }
            self.lists = self.lists.sorted { $0.title.lowercased() < $1.title.lowercased() }
            self.tableView.reloadData()
        }
    }
    
    func retrieveHistoryCount(){
        placeDbController.getAllPlacesIds(userId: userId){ (placeIds) in
            self.ids = placeIds
        }
    }
    
    func updateViewHeight(count: Int){
        let tableCellHeight = (traitCollection.userInterfaceIdiom == .pad ?  viewAreaHeight/9.5 : viewAreaWidth/4.3)*CGFloat(count)
        let yPos = (view.subviews.map { $0.frame.height }).reduce(60, +)
        
        let scrollHeight = self.view.frame.height - yPos
        let height = yPos < view.frame.height ? scrollHeight + tableCellHeight : tableCellHeight
        
        self.tableViewHeight.constant = height
    }
    
    // MARK: - Tableview Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        
        cell.checkBoxdelegate = self
        cell.CheckBox.tag = indexPath.row
        cell.CheckBox.style = .tick
        cell.CheckBox.checkboxBackgroundColor = .teal
        cell.CheckBox.isChecked = false
        
        let list = lists[indexPath.row]
        
        if alreadySavedPlace {
            if (currentPlace?.list.contains(list.title))!{
                cell.CheckBox.isChecked = true
                selectedLists.append(indexPath.row)
            }
        }
        cell.configure(with: list.icon, listName: list.title, listCount: list.count, color: list.color)
        return cell
    }
    
    // MARK: - Button Actions
    
    @IBAction func tappedNewList(_ sender: Any) {
        let alert = UIAlertController(title: "New List", message: "Give title to the list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            let input = alert.textFields![0].text
            let icon = self.view.setListIcon(title: input!)
            
            self.listDbController.addNewList(title: input!, userId: self.userId){
                (listId) in
                let list = List(title: input!, id: listId, icon: icon.0, color: icon.1, placeIds: [], count: 0)
                self.lists.append(list)
                self.lists = self.lists.sorted { $0.title.lowercased() < $1.title.lowercased() }
                self.selectedLists.removeAll()
                self.tableView.reloadData()
                self.updateViewHeight(count: self.lists.count)
            }
        }
        saveAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in}
        
        alert.addTextField {
            (textFieldName: UITextField!) in textFieldName.placeholder = "Enter list title"
        }
        
        // adding the notification observer here
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let textFieldName = alert.textFields?[0]
            saveAction.isEnabled =  !textFieldName!.text!.isEmpty
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func didTapCheckBox(_ sender: CheckBox) {
        let row = (sender as AnyObject).tag!
        if sender.isChecked == true && !selectedLists.contains(row){
            selectedLists.append(row)
        }else if sender.isChecked == false && selectedLists.contains(row) {
            if let idx = selectedLists.firstIndex(of: row) {
                selectedLists.remove(at: idx)
            }
        }
    }
    
    @IBAction func tappedDoneBtn(_ sender: UIBarButtonItem) {
        if selectedLists.count == 0 && !alreadySavedPlace{
            let alert = UIAlertController(title: "Select list", message: "Please select at least one list", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        }else{
            var listTitles = [String]()
            var highestId = ids.max() ?? 0
            guard let currentPlace = currentPlace else {return}
            
            highestId = alreadySavedPlace ? currentPlace.id : highestId + 1
            
            for index in selectedLists{
                let list = lists[index]
                if !currentPlace.list.contains(list.title){
                    self.listDbController.addNewPlaceToList(place: currentPlace, userId: userId, listId: list.id, placeId: highestId)
                }
                listTitles.append(list.title)
            }
            if !alreadySavedPlace{
                placeDbController.addPlaceToHistory(place: currentPlace, userId: userId, listTitle: listTitles, count: highestId)
            }else{
                if listTitles.count == 0{
                    placeDbController.deletePlace(userId: userId, placeId: currentPlace.dbId)
                }else{
                    placeDbController.updatePlace(userId: userId, place: currentPlace, listTitle: listTitles)
                }
                
                for place in currentPlace.list{
                    if listTitles.contains(place) == false{
                        let listId = lists.first(where: {$0.title == place})?.id
                        listDbController.removePlaceFromList(userId: userId, listId: listId!, placeId: currentPlace.id)
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
