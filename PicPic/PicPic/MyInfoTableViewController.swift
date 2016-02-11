//
//  MyInfoTableViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class MyInfoTableViewController: UITableViewController{

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var editProfile: UILabel!
    @IBOutlet weak var changePass: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.topItem?.title = self.appdelegate.ment["settings_myinfo"].stringValue
        self.navigationItem.title = self.appdelegate.ment["settings_myinfo"].stringValue
        emailText.text = self.appdelegate.ment["settings_myinfo_email"].stringValue
        editProfile.text = self.appdelegate.ment["settings_myinfo_change_profile"].stringValue
        changePass.text = self.appdelegate.ment["settings_myinfo_change_password"].stringValue
        self.email.text = self.appdelegate.email
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    func backToMyFeed(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
