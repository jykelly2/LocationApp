//
//  SettingController.swift
//  LocateMe
//
//  Created by Jun K on 2020-11-13.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class SettingController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    let isPhone = UIDevice.isPhone
    let sectionCount = 3
    let cellCount = 8
    
    let navView : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            return view
    }()
    
    let underlineView : UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .lightGrey
                return view
    }()

      let tableView: UITableView = {
          let tv = UITableView(frame: .zero, style: .plain)
          tv.translatesAutoresizingMaskIntoConstraints = false
          tv.layer.borderColor = UIColor.lightGrey.cgColor
          tv.isScrollEnabled = false
          tv.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
          return tv
      }()
    
    let navTitle: UILabel = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textAlignment = .center
                  label.text = "Settings"
                    label.textColor = .darkerGray
                    return label
    }()
    
    let app: UILabel = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textAlignment = .center
                  label.text = "VOCALE"
                    label.textColor = .darkerGray
                    return label
    }()
    
    let version: UILabel = {
                       let label = UILabel()
                       label.translatesAutoresizingMaskIntoConstraints = false
                       label.textAlignment = .center
                       label.minimumScaleFactor = 0.1
                        label.adjustsFontSizeToFitWidth = true
                        label.numberOfLines = 1
                     label.text = "Vocale © 2020 Version: 5.29.0 (2137)"
                label.textColor = .lightGray
                       return label
    }()
    let account: UILabel = {
                      let label = UILabel()
                      label.translatesAutoresizingMaskIntoConstraints = false
                      label.textAlignment = .left
                    label.text = "ACCOUNT"
                      label.textColor = .lightGray
                      return label
    }()
    let general: UILabel = {
                         let label = UILabel()
                         label.translatesAutoresizingMaskIntoConstraints = false
                         label.textAlignment = .left
                       label.text = "GENERAL"
                         label.textColor = .lightGray
                         return label
       }()
    let legal: UILabel = {
                         let label = UILabel()
                         label.translatesAutoresizingMaskIntoConstraints = false
                         label.textAlignment = .left
                       label.text = "LEGAL"
                         label.textColor = .lightGray
                         return label
    }()
    
    let logout: UILabel = {
                           let label = UILabel()
                           label.translatesAutoresizingMaskIntoConstraints = false
                           label.textAlignment = .left
                         label.text = "Log Out"
                           label.textColor = .lightRed
                           return label
      }()
    let backBtn: UIButton = {
                     let btn = UIButton.init(type: .system)
                      btn.translatesAutoresizingMaskIntoConstraints = false
                      let img = UIImage(named: "backarrow")?.withRenderingMode(.alwaysTemplate)
                      btn.clipsToBounds = true
                      btn.layer.backgroundColor = UIColor.clear.cgColor
                      btn.setImage(img, for: .normal)
                  btn.tintColor = .teal
                     btn.isUserInteractionEnabled = true
         btn.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
                         return btn
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //if let font = UIFont(name: "AppleSDGothicNeo-Thin", size: 34)
        
       tableView.dataSource = self
       tableView.delegate = self
        view.addSubview(navView)
        navView.addSubview(navTitle)
       navView.addSubview(underlineView)
        navView.addSubview(backBtn)
        view.addSubview(tableView)
        
        
    }

    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
    
        if (isPhone){
            
           navTitle.font = UIFont(name: "Helvetica", size: safeAreaHeight/38)
    
             navView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            navView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.08).isActive=true
            backBtn.centerYAnchor.constraint(equalTo: navTitle.centerYAnchor).isActive = true
            backBtn.leadingAnchor.constraint(equalTo: navView.leadingAnchor, constant: safeAreaHeight/40).isActive = true
            backBtn.widthAnchor.constraint(equalTo: navView.widthAnchor, multiplier: 0.07).isActive = true
            backBtn.heightAnchor.constraint(equalTo:navView.widthAnchor, multiplier: 0.07).isActive = true
            underlineView.topAnchor.constraint(equalTo: navView.bottomAnchor).isActive = true
            underlineView.widthAnchor.constraint(equalTo: navView.widthAnchor).isActive = true
            underlineView.heightAnchor.constraint(equalToConstant: safeAreaHeight/150).isActive = true
            tableView.topAnchor.constraint(equalTo: underlineView.bottomAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
          
        }else{
            
        }
       // navView.addSlightShadow()
        navView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        navView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive=true
        navTitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        navTitle.centerYAnchor.constraint(equalTo: navView.centerYAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive=true
    }

     //--------------TABLEVIEW FUNCTIONS-----------------//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            switch section {
            /*case 0:
                let headerView1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: safeAreaHeight/20))
              //  headerView1.addSubview(account)
               // account.leadingAnchor.constraint(equalTo: headerView1.leadingAnchor, constant: safeAreaWidth/20).isActive = true
               // account.centerYAnchor.constraint(equalTo: headerView1.centerYAnchor).isActive = true
                headerView1.backgroundColor = .veryLightGray
                return headerView1*/
            case 1:
                let headerView2 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: safeAreaHeight/20))
               // headerView2.addSubview(general)
              //  general.leadingAnchor.constraint(equalTo: headerView2.leadingAnchor, constant: safeAreaWidth/20).isActive = true
               // general.centerYAnchor.constraint(equalTo: headerView2.centerYAnchor).isActive = true
                headerView2.backgroundColor = .veryLightGray
                return headerView2
            default:
                let headerView3 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: safeAreaHeight/20))
              //  headerView3.addSubview(legal)
              //  legal.leadingAnchor.constraint(equalTo: headerView3.leadingAnchor, constant: safeAreaWidth/20).isActive = true
               // legal.centerYAnchor.constraint(equalTo: headerView3.centerYAnchor).isActive = true
                headerView3.backgroundColor = .veryLightGray
                return headerView3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }
        return safeAreaHeight/17
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        print(section)
        if section == 3{
            let height = safeAreaHeight - (safeAreaHeight/17)*3 - (safeAreaHeight/13)*8 - (safeAreaHeight*0.08) - (safeAreaHeight/150)
        
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: height))
            footerView.backgroundColor = .veryLightGray
          /*  footerView.addSubview(logout)
            logout.font = UIFont(name: "Helvetica-Bold", size: safeAreaHeight/40)
            
             logout.topAnchor.constraint(equalTo: footerView.topAnchor, constant: safeAreaHeight/34).isActive = true
                logout.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: safeAreaWidth/20).isActive = true*/
            return footerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
              let height = safeAreaHeight - (safeAreaHeight/17)*3 - (safeAreaHeight/13)*8 - (safeAreaHeight*0.08) - (safeAreaHeight/150)
            return height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return safeAreaHeight/13
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch section {
        case 0:
            count = 2
        case 1:
            count = 3
        case 2:
            count = 2
        default:
            count = 1
        }
        return count
    }
     
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell

        var titles = [String]()
        var images = [String]()
        let section = indexPath.section
    
        if section == 0 {
            titles = ["Edit Profile", "Notification"]
            images = ["editprofile","notification"]
        }else if section == 1{
            titles = [ "Share our App", "Leave a Review", "Give a Feedback"]
            images = ["shareicon","review", "feedback"]
        }else if section == 2{
            titles = ["Terms of Use","Privacy Policy"]
            images = ["termsofuse","privacy"]
        }else{
            titles = ["Log Out"]
            images = ["logout"]
        }
    
        let image = UIImage(named: images[indexPath.row])!.withRenderingMode(.alwaysTemplate)
    
        cell.setUpSetting(title: titles[indexPath.row] , image: image)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        cell.label.font = UIFont(name: "Helvetica", size: safeAreaHeight/40)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
        
        }
        else if section == 1 {
            switch indexPath.row {
            case 0:
               print("here")
            case 1:
                share()
            case 2:
                review()
            default:
               feedback()
            }
        }
        else{
            
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
             guard let url = URL(string: url) else {
                 return
             }
             let safariVC = SFSafariViewController(url:url)
             present(safariVC, animated: true)
      }
    
    func feedback(){
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["junkyamazaki@gmail.com"])
        composer.setSubject("App Feedback")
        
        present(composer, animated: true)
    }
    
    @objc func tappedBackBtn(){
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true)
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

