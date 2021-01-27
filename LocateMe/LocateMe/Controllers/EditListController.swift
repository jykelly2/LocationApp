//
//  EditListView.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-05.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

class EditListController: UICollectionViewController{
    
    let listDbController = ListDbController()
    let placeDbController = PlaceDbController()
    
    var places: [Place]?
    var list: List?
    private var selectedPlaces = [Place]()
    
    var editedListTitle: String = ""
    var userId: String = ""
    
    @IBOutlet weak var DoneBtn: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLargeTitleNavigationBar(navTitle: "Edit List", backText: "Saved")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        editedListTitle = list?.title ?? ""
        
        hideKeyboardWhenTappedAround()
    }
        
    // MARK: - Button Actions
    @IBAction func tappedDone(_ sender: UIBarButtonItem) {
        guard let listId = list?.id, let listTitle = list?.title else {return}
        
        placeDbController.removeListFromAllSelectedPlaces(userId: userId, listId: listId, listTitle: listTitle, places: selectedPlaces)
        
        listDbController.removeAllPlaceFromList(userId: userId, listId: listId, placeIds: selectedPlaces.map({$0.id}))
        
        if listTitle != editedListTitle {
            listDbController.updateListTitle(userId: userId, listId: listId, oldTitle: listTitle, newTitle: editedListTitle)//, placeDbIds: selectedPlaces.map({$0.dbId}))
           
            listDbController.updateTitleInPlaces(userId: userId, oldTitle: listTitle, newTitle: editedListTitle, places: places!)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tappedDelete(_ sender: UIButton){
        let placeId = sender.tag
        guard  let index = self.places?.firstIndex(where: {$0.id == placeId}) else {return}
        selectedPlaces.append((places?[index])!)
        places?.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])

    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
// MARK: - CollectionView Functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (places?.count ?? 0)
    }
       
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditItemCell", for: indexPath) as! EditItemCell
        
        let row = indexPath.row
        cell.layer.cornerRadius = safeAreaHeight/80
        cell.backgroundColor = .veryLightGray

        guard let place = places?[row] else {return cell}
     
        cell.configure(with: place.name, placeCategory: place.category, placeAddress: place.address)
        cell.DeleteBtn.addTarget(self, action: #selector(tappedDelete(_:)), for: .touchUpInside)
        cell.DeleteBtn.tag = place.id
      
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EditListHeader", for: indexPath) as! EditListHeader
            view.ListTxtField.text = list?.title
            
            if list?.title.checkIfDefaultList() == true{
                view.ListTxtField.isUserInteractionEnabled = false
            }
            
            view.ListTxtField.addTarget(self, action: #selector(textViewDidEndEditing(_:)), for: .editingDidEnd)
            view.ListTxtField.addTarget(self, action: #selector(textViewEditing(_:)), for: .editingChanged)
       
            return view
        }
        fatalError("Unexpected kind")
    }
        
// MARK: - TextView Functions
    @objc func textViewDidEndEditing(_ textView: UITextView) {
         var done: Bool = true
          if textView.text.isEmpty {
             done = false
          }
          DoneBtn.isEnabled = done
          self.editedListTitle = textView.text
      }
      
      @objc func textViewEditing(_ textView: UITextView) {
          var done: Bool = true
          if textView.text.isEmpty {
             done = false
          }
          DoneBtn.isEnabled = done
          self.editedListTitle = textView.text
      }

}
