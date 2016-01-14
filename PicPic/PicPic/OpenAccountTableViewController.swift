//
//  OpenAccountTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 6..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class OpenAccountTableViewController: UITableViewController {

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var email : String!
    @IBOutlet weak var username: UISwitch!
    @IBOutlet weak var profile: UISwitch!
    @IBOutlet weak var usernameC: UISwitch!
    @IBOutlet weak var comlike: UISwitch!
    @IBOutlet weak var postlike: UISwitch!
    @IBOutlet weak var postcom: UISwitch!
    @IBOutlet weak var repic: UISwitch!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var changeProfileLabel: UILabel!
    @IBOutlet weak var changeIDLabel: UILabel!
    @IBOutlet weak var postLikeLabel: UILabel!
    @IBOutlet weak var commentLikeLabel: UILabel!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var repicLabel: UILabel!
    @IBOutlet weak var complete: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        complete.title = self.appdelegate.ment["complete1"].stringValue
        if self.appdelegate.standardUserDefaults.valueForKey("pl") != nil {
            if self.appdelegate.standardUserDefaults.valueForKey("pl")as! String == "Y" {
                postlike.on = true
            }else {
                postlike.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("cl")as! String == "Y" {
                comlike.on = true
            }else {
                comlike.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("pc")as! String == "Y" {
                postcom.on = true
            }else {
                postcom.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("rm")as! String == "Y" {
                repic.on = true
            }else {
                repic.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("fp")as! String == "Y" {
                profile.on = true
            }else {
                profile.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("fri")as! String == "Y" {
                username.on = true
            }else {
                username.on = false
            }
            if self.appdelegate.standardUserDefaults.valueForKey("fi")as! String == "Y" {
                usernameC.on = true
            }else {
                usernameC.on = false
            }
        }
        
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        
        self.navigationItem.title = self.appdelegate.ment["settings_public_setting"].stringValue
        
        userNameLabel.text = self.appdelegate.ment["settings_public_setting_search_yn"].stringValue
        changeProfileLabel.text = self.appdelegate.ment["settings_public_setting_change_profile"].stringValue
        changeIDLabel.text = self.appdelegate.ment["settings_public_setting_change_id"].stringValue
        postLikeLabel.text = self.appdelegate.ment["settings_public_setting_like_post"].stringValue
        commentLikeLabel.text = self.appdelegate.ment["settings_public_setting_like_comment"].stringValue
        postCommentLabel.text = self.appdelegate.ment["settings_public_setting_post_comment"].stringValue
        repicLabel.text = self.appdelegate.ment["settings_public_setting_repic"].stringValue
        
        
        
        self.email = self.appdelegate.email
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    @IBAction func complete(sender: AnyObject) {
        var pl : String = ""
        var cl : String = ""
        var pc : String = ""
        let fm = "Y"
        let fja = "Y"
        let fca = "Y"
        var rm : String = ""
        let cmp = "Y"
        let cmc = "Y"
        var fp :String = ""
        var fi : String = ""
        var fri :String = ""
        
        if postlike.on == true {
            pl = "Y"
        }else {
            pl = "N"
        }
        if comlike.on == true{
            cl = "Y"
        }else {
            cl = "N"
        }
        if postcom.on == true{
            pc = "Y"
        }else {
            pc = "N"
        }
        if repic.on == true{
            rm = "Y"
        }else{
            rm = "N"
        }
        if profile.on == true{
            fp = "Y"
        }else {
            fp = "N"
        }
        if usernameC.on == true{
            fi = "Y"
        }else {
            fi = "N"
        }
        if username.on == true{
            fri = "Y"
        }else {
            fri = "N"
        }
        
        let message : JSON = ["myId":self.email,"pl_yn":pl,"cl_yn":cl,"pc_yn":pc,"fm_yn":fm,"fja_yn":fja,"fca_yn":fca,"rm_yn":rm,"cmp_yn":cmp,"cmc_yn":cmc,"fp_yn":fp,"fi_yn":fi,"fri_yn":fri]
        
        self.appdelegate.standardUserDefaults.setValue(pl, forKey: "pl")
        self.appdelegate.standardUserDefaults.setValue(cl, forKey: "cl")
        self.appdelegate.standardUserDefaults.setValue(pc, forKey: "pc")
        self.appdelegate.standardUserDefaults.setValue(rm, forKey: "rm")
        self.appdelegate.standardUserDefaults.setValue(fp, forKey: "fp")
        self.appdelegate.standardUserDefaults.setValue(fi, forKey: "fi")
        self.appdelegate.standardUserDefaults.setValue(fri, forKey: "fri")
        
        
//        let connection = URLConnection(serviceCode: 210, message: message)
//        let readData = connection.connection()
        self.appdelegate.doIt(210, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.appdelegate.testNavi.popViewControllerAnimated(true)
            }
        }
    }
    
    
    

}
