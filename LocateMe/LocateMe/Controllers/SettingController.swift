//
//  SettingController.swift
//  LocateMe
//
//  Created by Jun K on 2021-02-01.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class SettingController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultTitleNavigationBar(navTitle: "General", backText: "")
        showNavigationBar(animated: animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         tableView.isScrollEnabled = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if traitCollection.userInterfaceIdiom == .pad {
            if indexPath.row == 0 || indexPath.row == 4 {
                return viewAreaHeight/20
            }
            return viewAreaHeight/15
        }else{
            if indexPath.row == 0 || indexPath.row == 4 {
                return viewAreaWidth/10
            }
            return viewAreaWidth/7.5
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            review()
        case 1:
            feedback()
        case 2:
            share()
            
        default:
            print("nothing")
        }
    }
    
    func share(){
        let shareUrl = "https://apps.apple.com/app/id1084540807?fbclid=IwAR1ctXGVKLXubpvHB9GCJ-tGzpfhCHyfyRLi6dRSIKJFViAVKTmdyZC6uJU"
        let activityVC = UIActivityViewController(activityItems: [shareUrl], applicationActivities: nil)
        activityVC.isModalInPresentation = true
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func review(){
        let feedbackUrl = "https://apps.apple.com/app/id1084540807?fbclid=IwAR1ctXGVKLXubpvHB9GCJ-tGzpfhCHyfyRLi6dRSIKJFViAVKTmdyZC6uJU"
        showSafariVC(for: feedbackUrl)
    }
    
    func showSafariVC(for url: String){
        guard let url = URL(string: url) else {return}
        let safariVC = SFSafariViewController(url:url)
        present(safariVC, animated: true)
    }
    
    func feedback(){
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.setToRecipients(["spotfinderinc@gmail.com"])
            composer.setSubject("App Feedback")
            composer.mailComposeDelegate = self
            
            present(composer, animated: true, completion: nil)
        }
    }
}

extension SettingController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("cancelled")
            controller.dismiss(animated: true)
        case .failed:
            print("failed")
            controller.dismiss(animated: true)
        case .saved:
            print("saved")
            controller.dismiss(animated: true)
        case .sent:
            print("sent")
            controller.dismiss(animated: true)
        @unknown default:
            print("default")
            controller.dismiss(animated: true)
        }
        
        //controller.dismiss(animated: true)
    }
}
