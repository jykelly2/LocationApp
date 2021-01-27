//
//  MapController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-09.
//  Copyright © 2021 JK. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import FloatingPanel
import FBSDKLoginKit
import GoogleSignIn

enum traceState {
      case start
      case stop
      case restart
      case neutral
}

class MapController: MapBaseController {
    typealias PanelDelegate = FloatingPanelControllerDelegate & UIGestureRecognizerDelegate

    lazy var fpcDelegate: PanelDelegate =
        (traitCollection.userInterfaceIdiom == .pad) ? SearchPanelPadDelegate(mapOwner: self, fpcType: .search) : SearchPanelPhoneDelegate(mapOwner: self, listOwner: nil)
    
    lazy var listFpcDelegate: PanelDelegate =
         (traitCollection.userInterfaceIdiom == .pad) ? SearchPanelPadDelegate(mapOwner: self, fpcType: .list) : SearchPanelPhoneDelegate(mapOwner: self, listOwner: nil)
    
    lazy var placeFpcDelegate: PanelDelegate =
           (traitCollection.userInterfaceIdiom == .pad) ? SearchPanelPadDelegate(mapOwner: self, fpcType: .place) : SearchPanelPhoneDelegate(mapOwner: self, listOwner: nil)
    
    lazy var searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchController") as! SearchController
    
    let sectionTitles = ["Recent Searches", "Lists"]
    let distanceValues = [1, 3, 5, 10]
    
    let userDbController = UserDbController()
    let listDbController = ListDbController()
    let searchDbController = SearchDbController()
    let placeDbController = PlaceDbController()
    
    let group = DispatchGroup()
    
    let transiton = SlideInTransition()
    
    var emptyView = EmptyTableView()
    var distanceView = DistancePicker()
 
    var matchingItems: [MKMapItem] = []
    var searchText: String = ""
    var pickedDistance: Double = 0
    var pickedDistanceRow: Int = 0
    var regionRadius: CLLocationDistance = 10000000
    var searchDistance: Double = 1000.0
    var trace = traceState.neutral
    
    var allLoc: [CLLocation] = []

    var coordinates: [CLLocationCoordinate2D] = [] {
          didSet{
              guard coordinates.count > 1 else {return}
              let count = coordinates.count
              let start = coordinates[count-1]
              let end = coordinates[count-2]
              let polyine = MKPolyline(coordinates: [start, end], count: 2)
              myMap.addOverlay(polyine)
          }
    }
   
    @IBOutlet weak var NavigationStack: UIStackView!
    @IBOutlet weak var SettingBtn: UIButton!
    @IBOutlet weak var TraceBtn: UIButton!
    @IBOutlet weak var DistanceBtn: UIButton!
    
    @IBOutlet weak var NavVisualEffectView: UIVisualEffectView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fpc.contentMode = .fitToBounds
        fpc.delegate = fpcDelegate
        fpc.set(contentViewController: searchVC)
        fpc.track(scrollView: searchVC.tableView)
        
        setUpFloatingPanel(fpc: fpc, type: FpcType.search)
       
        setupMapView(fromMap: true)
        setUpSearchView()
        setUpSearchIcons()
        setUpTraceIcon()
        
        NavigationStack.addHorizontalSeparators(color : .systemGray5)
    }
    
    func setUpFloatingPanel(fpc: FloatingPanelController , type: FpcType){
        switch traitCollection.userInterfaceIdiom {
        case .pad:
            layoutPanelForPad(fpc: fpc)
            fpc.panGestureRecognizer.delegateProxy = fpcDelegate
        default:
            layoutPanelForPhone(fpc: fpc, type: type)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchVC.searchBar.delegate = self
    }
    
        
// MARK: - Place Search Functions

    func searchItems(){
        matchingItems.removeAll()
    
        if coordinates.count == 0{
            searchLocally()
        }else{
            matchingPlaces.removeAll()
            myMap.removeAnnotations(self.myMap.annotations)
            
            var matchedCoordinates = [CLLocation]()
            let startLocation = CLLocation(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude)
            var distance = searchDistance
            matchedCoordinates.append(startLocation)
            
            for i in 1...coordinates.count-1{
                let endLocation = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
                
                if(startLocation.distance(from: endLocation) >= distance){
                    distance += searchDistance
                    matchedCoordinates.append(endLocation)
                }
            }
            allLoc = matchedCoordinates
            searchCoordinates(allLocations: matchedCoordinates)
            let circle = MKCircle(center: coordinates.first!, radius: 5)
            myMap.addOverlay(circle)
        }
    }
    
    func searchLocally(){
        if let  currentLocation = locationManager.location {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
               
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: self.searchDistance, longitudinalMeters: self.searchDistance)
                      
            request.region = region

            let search = MKLocalSearch(request: request)
                            
            searching(search: search, loc: currentLocation, fromCoordinates: false)
        }
    }
   
    func searchCoordinates(allLocations: [CLLocation]){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        group.enter()
        DispatchQueue.main.async {
            for loc in allLocations{
                
                let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: self.searchDistance, longitudinalMeters: self.searchDistance)
                          
                request.region = region
            
                let search = MKLocalSearch(request: request)
                
                self.searching(search: search, loc: loc, fromCoordinates: true)
              
            }
         self.addSearchToDb()
           // self.adjustMap(places: self.matchingPlaces)
           
        }
        group.notify(queue: .main) {
          
            print("placeountFinished\(self.matchingPlaces.count)")
        self.getDetailFcp(places: self.matchingPlaces, list: nil)
        }
        
    }
    
    func searching(search: MKLocalSearch,loc: CLLocation, fromCoordinates: Bool){
        search.start(completionHandler: {(response, error) in
            guard let response = response else{
                print("error : \(error?.localizedDescription ?? "Unknown error happened.")")
                return
            }
            if fromCoordinates{
                let coordinates = self.myMap.annotations.map({$0.coordinate})
                for item in response.mapItems.filter({!coordinates.contains($0.placemark.coordinate)}){
                         if((loc.distance(from: item.placemark.location!)) <= self.searchDistance){
                            let place = self.createPlaceitems(item: item)
                            self.addSinglePinToMap(place: place)
                            print("placecount\(self.matchingPlaces.count)")
                        }
                }
                if loc == self.allLoc.last{
                    self.group.leave()
                }
            }else{
                for item in response.mapItems{
                    if((loc.distance(from: item.placemark.location!)) <= self.searchDistance){
                        if self.matchingItems.contains(item) == false{
                             self.matchingItems.append(item)
                        }
                    }
                }
                         
                self.matchingPlaces = self.createPlaceList(items: self.matchingItems)
                self.adjustMap(places: self.matchingPlaces)
                self.getDetailFcp(places: self.matchingPlaces, list: nil)
                self.addSearchToDb()
            }
        })
    }

    func getDetailFcp(places: [Place], list: List?){
        self.fpc.hide(animated: true , completion: {
            self.fpc.view.isHidden = true
            
            if list == nil {
                self.listDetailVC.listTitle = self.searchText.capitalizingFirstLetter()
            }else{
               self.listDetailVC.list = list
            }
            
            self.listDetailVC.fromMapView = true
            self.listDetailVC.places = places
            self.listDetailVC.userId = self.userId
            
            self.detailFpc.contentMode = .fitToBounds
            self.detailFpc.delegate = self.listFpcDelegate
            self.detailFpc.set(contentViewController: self.listDetailVC)
            self.fpc.track(scrollView: self.listDetailVC.tableView)
            self.setUpFloatingPanel(fpc: self.detailFpc, type: FpcType.list)
                      
            self.listDetailVC.CloseBtn.addTarget(self, action: #selector(self.removeDetailFpc), for: .touchUpInside)
      
            self.setUpDetailView()
        })
    }
    
// MARK: - Place and place property formatting

    func createPlaceList(items: [MKMapItem])-> [Place]{
           var places = [Place]()
           for item in matchingItems{
               
               let address = formatAddress(placemark: item.placemark)
               
               let category = formatCategory(unfilteredCategory: item.pointOfInterestCategory?.rawValue ?? searchText)
            
                let icon = self.setPlaceIcon(title: category)
            
            let distance = self.locationManager.location?.distance(from: item.placemark.location!)
            
            let place = Place(name: item.name ?? "", address: address, phone: item.phoneNumber ?? "", website: item.url ?? URL(string: "https://www.google.com")!, category: category, coordinate: item.placemark.coordinate, distance: distance ?? 0, icon: icon.0, color: icon.1)
            
               places.append(place)
           }
           return places
    }
    
    func createPlaceitems(item: MKMapItem)-> Place{
        let address = formatAddress(placemark: item.placemark)
        let category = formatCategory(unfilteredCategory: item.pointOfInterestCategory?.rawValue ?? searchText)
        let icon = self.setPlaceIcon(title: category)
        let distance = self.locationManager.location?.distance(from: item.placemark.location!)
        
        let place = Place(name: item.name ?? "", address: address, phone: item.phoneNumber ?? "", website: item.url ?? URL(string: "https://www.google.com")!, category: category, coordinate: item.placemark.coordinate, distance: distance ?? 0, icon: icon.0, color: icon.1)
        
        return place
    }
       
    func formatAddress(placemark: MKPlacemark) -> String{
        let subThroughfare = placemark.subThoroughfare ?? ""
        let throughFare = placemark.thoroughfare ?? ""
        let locality = placemark.locality ?? ""
           
        return subThroughfare + " " + throughFare + " " + locality
    }
       
    func formatCategory(unfilteredCategory: String) -> String{
        var category = ""
        if unfilteredCategory == searchText {
            return searchText.capitalizingFirstLetter()
        }else{
            category = unfilteredCategory.filterMapCategory(category: unfilteredCategory)
        }
        return category
    }
    
     
// MARK: - Navigation Stack Actions / Functions
    
    @IBAction func tappedSettingBtn(_ sender: UIButton) {
           didTapMenu()
    }
       
    @IBAction func tappedTraceBtn(_ sender: UIButton) {
        if myMap.userTrackingMode.rawValue == 0{
            myMap.setUserTrackingMode( .followWithHeading, animated: true)
        }else{
            myMap.setUserTrackingMode( .none, animated: true)
        }
    }
       
    @IBAction func tappedDistanceBtn(_ sender: Any) {
        distanceView = DistancePicker(frame: CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height))
        distanceView.pickerView.delegate = self
        distanceView.pickerView.dataSource = self
        distanceView.originalRow = pickedDistanceRow
        distanceView.pickerView.selectRow(pickedDistanceRow, inComponent: 0, animated: false)
        distanceView.SaveBtn.addTarget(self, action: #selector(tappedSaveBtn), for: .touchUpInside)
        distanceView.CloseBtn.addTarget(self, action: #selector(removePickerAndDimView), for: .touchUpInside)
        let dimmingView = DimmedView(frame: view.frame)
        view.addSubview(dimmingView)
          
        view.addSubview(distanceView)
        distanceView.animateIn()
    }
 
// MARK: - Trace Setup / Functions
    func setUpTraceIcon(){
        searchVC.traceHeaderView.StartTraceStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedStartTrace)))
        searchVC.traceHeaderView.StopTraceStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedStopTrace)))
        searchVC.traceHeaderView.RestartTraceStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedRestartTrace)))
    }
      
    func changeTraceIcons(value: Int){
          switch value{
          case 0:
              TraceBtn.setImage(UIImage(systemName: "location")?.withTintColor(.teal), for: .normal)
           default:
              TraceBtn.setImage(UIImage(systemName: "location.fill")?.withTintColor(.teal), for: .normal)
          }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        changeTraceIcons(value: mapView.userTrackingMode.rawValue)
    }
          
    @objc func tappedStartTrace(){
          myMap.setUserTrackingMode( .followWithHeading, animated: true)
          trace = traceState.start
    }
      
    @objc func tappedStopTrace(){
          myMap.setUserTrackingMode( .none, animated: false)
          trace = traceState.stop
    }
           
    @objc func tappedRestartTrace(){
           myMap.setUserTrackingMode( .followWithHeading, animated: true)
          trace = traceState.restart
    }
    
    @objc func tappedSearchIcon(_ tapGesture: UITapGestureRecognizer){
           guard let tag = tapGesture.view?.tag else {return}
           var text = ""
           switch tag {
           case 1:
               text = "Food"
           case 2:
               text = "Gas"
           case 3:
               text = "Shop"
           default:
               text = "Park"
           }
          searchText = text
          searchItems()
    }
}

// MARK: - UITableViewDelegate - Search Controller and List Detail Controller

extension MapController: UITableViewDelegate {
    func resetMapView(){
        var floatingPanel = ""
        if detailFpc.view.superview != nil{
            floatingPanel = infoFpc.view.superview != nil ? "both" : "detail"
        }
        
        removeFpc(floatingPanel: floatingPanel)
        searchVC.searches = []
        setUpSearchView()
        searchVC.tableView.reloadData()
    }
    
    func setUpDetailView() {
          listDetailVC.loadViewIfNeeded()
          listDetailVC.tableView.delegate = self
          listDetailVC.tableView.isUserInteractionEnabled = true
    }
    
    func setUpSearchView() {
        searchVC.loadViewIfNeeded()
        searchVC.tableView.delegate = self
        searchVC.tableView?.register(SectionHeaderCell.nib, forCellReuseIdentifier: SectionHeaderCell.identifier)
        searchVC.searchBar.placeholder = "Search for a place or address"
        
        userId = userDbController.getCurrentUserId()
        if userId != ""{
            retrieveSearches()
            retrieveLists()
        }else{
            searchVC.lists = getDefaultList()
        }
    }

    func retrieveSearches(){
        searchDbController.getAllSearches(userId: userId){(allSearches) in
            self.searchVC.searches = allSearches.sorted { $0.id > $1.id }
            self.searchVC.tableView.reloadSections(IndexSet(integersIn: 0...0), with: .automatic)
        }
    }
    func retrieveLists(){
        listDbController.getAllList(userId: userId){(allLists) in
            if allLists.count > 0{
                self.searchVC.lists = allLists
                self.reloadTableView()
            }else{
                self.listDbController.addDefaultLists(userId: self.userId){ (defaultLists) in
                    self.searchVC.lists.append(contentsOf: defaultLists)
                }
                self.reloadTableView()
            }
        }
    }
    
    func reloadTableView(){
        self.searchVC.lists = self.searchVC.lists.sorted { $0.title.lowercased() < $1.title.lowercased() }
        searchVC.tableView.reloadSections(IndexSet(integersIn: 1...1), with: .automatic)
    }
    
    func setUpSearchIcons(){
        searchVC.RestaurantIcon.setUpIconImg(img: searchVC.RestaurantIcon.image!, color: UIColor.lightOrange, inset: 30.0)
        searchVC.GasIcon.setUpIconImg(img: searchVC.GasIcon.image!, color: UIColor.lightBlue, inset: 30.0)
        searchVC.ParkIcon.setUpIconImg(img: searchVC.ParkIcon.image!, color: UIColor.lightGreen, inset: 30.0)
        searchVC.ShopIcon.setUpIconImg(img: searchVC.ShopIcon.image!, color: UIColor.lightPurple, inset: 30.0)
             
        let restaurantTap = UITapGestureRecognizer(target: self, action: #selector(tappedSearchIcon(_:)))
        let gasTap = UITapGestureRecognizer(target: self, action: #selector(tappedSearchIcon(_:)))
        let shopTap = UITapGestureRecognizer(target: self, action: #selector(tappedSearchIcon(_:)))
        let parkTap = UITapGestureRecognizer(target: self, action: #selector(tappedSearchIcon(_:)))
        searchVC.RestaurantIcon.addGestureRecognizer(restaurantTap)
        searchVC.GasIcon.addGestureRecognizer(gasTap)
        searchVC.ShopIcon.addGestureRecognizer(shopTap)
        searchVC.ParkIcon.addGestureRecognizer(parkTap)

    }
    
   
// MARK: - TableView Functions

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.restorationIdentifier == "ListDetailTable"{
            tableViewSelect = true
            guard let place = self.listDetailVC.places?[indexPath.row] else {return}
            self.getDistanceAndTime(place: place)
       
        }else{
            deactivate(searchBar: searchVC.searchBar)
            
            if indexPath.section == 0 {
                searchText = self.searchVC.searches[indexPath.row].title
                searchItems()
            }else{
                if userId == ""{
                   setUpEmptyView()
                }else{
                let list = self.searchVC.lists[indexPath.row]
                placeDbController.getAllPlacesForList(userId: userId, listTitle: list.title) {
                    (allPlaces) in
                    for item in allPlaces{
                        let destPlacemark = MKPlacemark(coordinate: item.coordinate)
                        let distance = self.locationManager.location?.distance(from: destPlacemark.location!)
                        item.distance = Double(distance ?? 0)
                    }
                    self.matchingPlaces = allPlaces
                    self.adjustMap(places: allPlaces)
                    self.getDetailFcp(places: allPlaces, list: list)
                }
                
            }
        }
        }
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
         guard !(tableView.restorationIdentifier == "ListDetailTable") else{return tableView.rowHeight }
            if indexPath.section == 0 {
                return 60
            }
            return 70
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.userId == "" || searchVC.searches.count == 0{
             if section == 0 {
                 return 0
             }
         }
         return 40
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         if self.userId == ""{
             if section == 0 {
              return nil
             }
         }
         let view = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as? SectionHeaderCell

         view?.SectionTitle.text = self.sectionTitles[section]
         return view?.contentView
     }
    
        
// MARK: - List Detail and Place Detail setup
    
    func getDistanceAndTime(place: Place){
      let destPlacemark = MKPlacemark(coordinate: place.coordinate)
      let soucePlacemark = MKPlacemark(coordinate: self.locationManager.location!.coordinate)
                 let destItem = MKMapItem(placemark: destPlacemark)
                 let sourceItem = MKMapItem(placemark: soucePlacemark)
                 
                 let destinationRequest = MKDirections.Request()
                 destinationRequest.source = sourceItem
                 destinationRequest.destination = destItem
                 destinationRequest.transportType = .automobile
                 destinationRequest.requestsAlternateRoutes = true
                 
                 let directions = MKDirections(request: destinationRequest)
                 directions.calculate { (response, error) in
                     guard response != nil else {
                         if error != nil {
                                 print("error\(error)")
                             }
                             return
                         }
                         guard let route = response?.routes[0] else{return}
                         let minutes = route.expectedTravelTime / 60
                         let time = Int(ceil(minutes)).description
                         place.distance = Double(route.distance)
                         place.time = time
                   
                    self.detailFpc.hide(animated: false, completion: {self.detailFpc.view.isHidden = true})
                   self.setUpPlaceDetail(place: place)
                 }
            
    }
 
    func setUpPlaceDetail(place: Place){
              let placeDetailVC = storyboard?.instantiateViewController(withIdentifier: "PlaceDetailController") as! PlaceDetailController
              placeDetailVC.currentPlace = place
              placeDetailVC.fromMapView = true
              placeDetailVC.userId = self.userId
        
            infoFpc.contentMode = .fitToBounds
            infoFpc.delegate = placeFpcDelegate 
            infoFpc.set(contentViewController: placeDetailVC)
            infoFpc.track(scrollView: placeDetailVC.tableView)
            setUpFloatingPanel(fpc: infoFpc, type: FpcType.place)
        
            placeDetailVC.CloseBtn.addTarget(self, action: #selector(removeInfoFpc), for: .touchUpInside)

            animateAnnotation(coordinate: place.coordinate)
    }
    
    @objc func removeDetailFpc(){
        removeFpc(floatingPanel: "detail")
        searchVC.searchBar.text = ""
        myMap.removeAnnotations(myMap.annotations)
        if userId != ""{
            retrieveLists()
        }
    }
    
    @objc func removeInfoFpc(){
        removeFpc(floatingPanel: "info")
        self.tableViewSelect = false
        self.zoomToOriginal()
    }
    
    func removeFpc(floatingPanel: String){
        if floatingPanel == "info" || floatingPanel == "both"{
            infoFpc.removePanelFromParent(animated: false)
            detailFpc.view.isHidden = false
            detailFpc.show(animated: true)
        }
        
        if floatingPanel == "detail" || floatingPanel == "both"{
            detailFpc.removePanelFromParent(animated: false)
            listDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ListDetailController") as! ListDetailController
            fpc.view.isHidden = false
            fpc.show(animated: true)
        }
    }
  
// MARK: - Empty View
    
    func setUpEmptyView(){
        emptyView = EmptyTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    
        let dimmingView = DimmedView(frame: view.frame)
      
        view.addSubview(dimmingView)
        emptyView.animateIn()
                           
        emptyView.SignInBtn.addTarget(self, action: #selector(tappedSignUp(_:)), for: .touchUpInside)
        emptyView.SignUpBtn.addTarget(self, action: #selector(tappedSignUp(_:)), for: .touchUpInside)
        emptyView.CloseBtn.addTarget(self, action: #selector(removeEmptyView(_:)), for: .touchUpInside)
        view.addSubview(emptyView)
    }

    @objc func tappedSignUp(_ sender: UIButton){
        removeEmptyAndDimView()
        
        var controller = UIViewController()
        if sender.currentTitle == "Sign up" {
            controller = (storyboard?.instantiateViewController(withIdentifier: "SignUpController") as? SignUpController)!
        }else{
             let signInController = (storyboard?.instantiateViewController(withIdentifier: "ManualSignUpController") as? ManualSignUpController)!
            signInController.signUp = false
            controller = signInController
        }
        
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc func removeEmptyView(_ sender: UIButton){
        removeEmptyAndDimView()
    }

    func removeEmptyAndDimView(){
        emptyView.animateOut()
        removeDimmedView()
    }
  
}


