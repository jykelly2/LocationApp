//
//  SearchController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-09.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Search Controller

class SearchController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var SearchStack: UIStackView!
    
    @IBOutlet weak var RestaurantIcon: UIImageView!
    @IBOutlet weak var GasIcon: UIImageView!
    @IBOutlet weak var ParkIcon: UIImageView!
    @IBOutlet weak var ShopIcon: UIImageView!
    
    let mapController = MapController()
    
    var lists: [List] = []
    var searches: [Search] = []
    
    let traceHeaderView = TableHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        setUpUI()
    }
    
    func setUpUI(){
        hideHeader(animated: false)
        searchBar.setSearchText(fontSize: 15.0)
    }
    
    // MARK: - Search panel header transition
    
    func showHeader(animated: Bool) {
        changeHeader(height: 116.0, animated: animated)
    }
    
    func hideHeader(animated: Bool) {
        changeHeader(height: 0.0, animated: animated)
    }
    
    private func changeHeader(height: CGFloat, animated: Bool) {
        if animated == false {
            updateHeader(height: height)
            return
        }
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.25) {
            self.updateHeader(height: height)
        }
        tableView.endUpdates()
    }
    
    private func updateHeader(height: CGFloat) {
        guard let headerView = tableView.tableHeaderView else { return }
        
        var frame = headerView.frame
        if height == 0.0 {
            SearchStack.isHidden = true
            traceHeaderView.frame = frame
            headerView.addSubview(traceHeaderView)
            headerView.frame = frame
        }else{
            SearchStack.isHidden = false
            frame.size.height = height
            traceHeaderView.removeFromSuperview()
            headerView.frame = frame
        }
    }
    
    // MARK: - Tableview Functions (Datasource)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let count = searches.count > 3 ? 3 : searches.count
            return count
        }
        return lists.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = UITableViewCell()
        let row = indexPath.row
        
        if  indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
            if let cell = cell as? RecentSearchCell {
                cell.searchTitle.text = searches[row].title
            }
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "ListSearchCell", for: indexPath)
            if let cell = cell as? ListSearchCell {
                let list = lists[row]
                cell.configure(list: list)
            }
        }
        return cell
    }
}

class SearchHeaderView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
}

extension UISearchBar {
    func setSearchText(fontSize: CGFloat) {
        if #available(iOS 13, *) {
            let font = searchTextField.font
            searchTextField.font = font?.withSize(fontSize)
        } else {
            let textField = value(forKey: "_searchField") as! UITextField
            textField.font = textField.font?.withSize(fontSize)
        }
    }
}


// MARK: - UISearchBarDelegate (MapController)

extension MapController: UISearchBarDelegate {
    func activate(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchVC.showHeader(animated: true)
        searchVC.tableView.alpha = 1.0
    }
    func deactivate(searchBar: UISearchBar) {
        myMap.removeAnnotations(myMap.annotations)
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        searchVC.hideHeader(animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivate(searchBar: searchBar)
        UIView.animate(withDuration: 0.25) {
            self.fpc.move(to: .half, animated: false)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activate(searchBar: searchBar)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.fpc.move(to: .full, animated: false)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if let searchText = searchBar.text {
            if searchText != ""{
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.fpc.move(to: .half, animated: false)
                }
                deactivate(searchBar: searchBar)
                self.searchText = searchText
                self.searchItems()
                
            }else{
                myMap.removeAnnotations(myMap.annotations)
            }
        }
    }
    
    func addSearchToDb(){
        DispatchQueue.main.async {
            if !self.searchVC.searches.contains(where: {$0.title == self.searchText}) && self.userId != ""{
                let searchesCount = self.searchVC.searches.count
                let id = searchesCount > 0 && self.searchVC.searches.map({$0.id}).max() != nil ? self.searchVC.searches.map({$0.id}).max()! + 1 : 1
                
                self.searchDbController.addSearch(userId: self.userId, searchTitle: self.searchText, id: id)
                
                if searchesCount > 2 {
                    self.searchVC.searches.removeLast()
                }
                self.searchVC.searches.insert(Search(title: self.searchText, id: id), at: 0)
                self.searchVC.tableView.reloadData()
            }
        }
    }
    
}

