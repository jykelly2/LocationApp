//
//  IpadFloatingPanel.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-22.
//  Copyright © 2021 JK. All rights reserved.
//

import FloatingPanel

// MARK: - Floating Panel Pad Delegate

class SearchPanelPadDelegate: NSObject, FloatingPanelControllerDelegate, UIGestureRecognizerDelegate {
    unowned let mapOwner: MapController?
    //unowned let listOwner: ListMapController?
    var fpcType: FpcType?
    
    init(mapOwner: MapController?, fpcType: FpcType?) {
        self.mapOwner = mapOwner
        self.fpcType = fpcType
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        
        if newCollection.horizontalSizeClass == .compact {
            fpc.surfaceView.containerMargins = .zero
            return FloatingPanelBottomLayout()
        }
        
        fpc.surfaceView.containerMargins = UIEdgeInsets(top: .leastNonzeroMagnitude,left: 16,bottom: 0.0,right: 0.0)
        switch fpcType {
        case .search:
            return SearchPanelPadLayout()
        case .list:
            return ListPanelPadLayout()
        default:
            return PlacePanelPadLayout()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
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
    }
}


// MARK: - Panel Pad Layouts

class SearchPanelPadLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .top
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 80.0, edge: .top, referenceGuide: .superview),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 290.0, edge: .top, referenceGuide: .superview),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 60.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor),
            surfaceView.widthAnchor.constraint(equalToConstant: 375),
        ]
    }
}

class ListPanelPadLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .top
    let initialState: FloatingPanelState = .full
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 105.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 280.0, edge: .top, referenceGuide: .superview),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 60.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor),
            surfaceView.widthAnchor.constraint(equalToConstant: 375),
        ]
    }
}

class PlacePanelPadLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .top
    let initialState: FloatingPanelState = .full
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 155.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 255.0, edge: .top, referenceGuide: .superview),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 60.0, edge: .bottom, referenceGuide: .superview),
        ]
    }
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor),
            surfaceView.widthAnchor.constraint(equalToConstant: 375),
        ]
    }
}


// MARK: - Panel Pad Behaviour
class SearchPaneliPadBehavior: FloatingPanelBehavior {
    var springDecelerationRate: CGFloat {
        return UIScrollView.DecelerationRate.fast.rawValue - 0.003
    }
    var springResponseTime: CGFloat {
        return 0.3
    }
    var momentumProjectionRate: CGFloat {
        return UIScrollView.DecelerationRate.fast.rawValue
    }
    func shouldProjectMomentum(_ fpc: FloatingPanelController, to proposedTargetPosition: FloatingPanelState) -> Bool {
        return true
    }
}


// MARK: - Panel Pad Function
extension FloatingPanelController {
    func setAppearanceForPad() {
        view.clipsToBounds = false
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]
        appearance.backgroundColor = .clear
        surfaceView.appearance = appearance
    }
}
