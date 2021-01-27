//
//  IphoneFloatingPanel.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-22.
//  Copyright © 2021 JK. All rights reserved.
//

import FloatingPanel

// MARK: - Floating Panel Phone Delegate

class SearchPanelPhoneDelegate: NSObject, FloatingPanelControllerDelegate, UIGestureRecognizerDelegate {
    unowned let mapOwner: MapController?
    unowned let listOwner: ListController?
    
    init(mapOwner: MapController?, listOwner: ListController?) {
        self.mapOwner = mapOwner
        self.listOwner = listOwner
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        if let owner = (mapOwner != nil) ? mapOwner : listOwner {
            
            if newCollection.verticalSizeClass == .compact{
                let appearance = vc.surfaceView.appearance
                appearance.borderWidth = 1.0 / owner.traitCollection.displayScale
                appearance.borderColor = UIColor.black.withAlphaComponent(0.2)
                vc.surfaceView.appearance = appearance
                return SearchPanelLandscapeLayout()
            }
        }
       return FloatingPanelBottomLayout()
    }

    func floatingPanelDidMove(_ vc: FloatingPanelController) {
       // debugPrint("surfaceLocation: ", vc.surfaceLocation)
        let loc = vc.surfaceLocation

        if vc.isAttracting == false {
            let minY = vc.surfaceLocation(for: .full).y - 6.0
            let maxY = vc.surfaceLocation(for: .tip).y + 6.0
            vc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }

        let tipY = vc.surfaceLocation(for: .tip).y
        
        if loc.y > tipY - 44.0 {
            let progress = max(0.0, min((tipY  - loc.y) / 44.0, 1.0))
            if mapOwner != nil {
                mapOwner?.searchVC.tableView.alpha = progress
            }
        } else {
            if mapOwner != nil {
                mapOwner?.searchVC.tableView.alpha = 1.0
            }
        }
       // debugPrint("NearbyState : ",vc.nearbyState)
    }

    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.state == .full && mapOwner != nil{
            mapOwner?.searchVC.searchBar.showsCancelButton = false
            mapOwner?.searchVC.searchBar.resignFirstResponder()
        }
    }

    func floatingPanelWillEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee != .full && mapOwner != nil {
            mapOwner?.searchVC.hideHeader(animated: true)
        }
        if targetState.pointee == .tip {
            vc.contentMode = .static
        }
    }

    func floatingPanelDidEndAttracting(_ fpc: FloatingPanelController) {
        fpc.contentMode = .fitToBounds
    }
}



// MARK: - Panel Phone Layouts

class ListDetailPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half //fractionalInset: 0.417
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 280.0, edge: .bottom, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 95.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
}
class PlaceDetailPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half //fractionalInset: 0.417
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 240.0, edge: .bottom, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 160.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
}
class SearchDetailPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half //fractionalInset: 0.417
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.43, edge: .bottom, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 95.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
}

class SearchPanelLandscapeLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 69.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        }
    }
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
}


// MARK: -  Panel Phone Function
extension FloatingPanelController {
    func setAppearanceForPhone() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = .clear
        surfaceView.appearance = appearance
    }
}
