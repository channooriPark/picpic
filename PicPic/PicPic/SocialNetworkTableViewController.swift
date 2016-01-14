//
//  SocialNetworkTableViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2016. 1. 3..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SocialNetworkTableViewController: UITableViewController {
    
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var complete: UIBarButtonItem!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var tumblrLabel: UILabel!
    @IBOutlet weak var pinterestLabel: UILabel!
    
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var twitterSwitch: UISwitch!
    @IBOutlet weak var tumblrSwitch: UISwitch!
    @IBOutlet weak var pinterestSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        complete.title = self.appdelegate.ment["complete1"].stringValue
        facebookLabel.text = self.appdelegate.ment["facebook"].stringValue
        twitterLabel.text = self.appdelegate.ment["twitter"].stringValue
        tumblrLabel.text = self.appdelegate.ment["tumblr"].stringValue
        pinterestLabel.text = self.appdelegate.ment["pinterest"].stringValue
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.appdelegate.standardUserDefaults.valueForKey("Facebook_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Facebook_Setting")as! String == "N" {
                self.facebookSwitch.on = false
        }
        else {
            self.facebookSwitch.on = true
        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Twitter_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Twitter_Setting")as! String == "N" {
                self.twitterSwitch.on = false
        }
        else {
            self.twitterSwitch.on = true
        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Tumblr_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Tumblr_Setting")as! String == "N" {
                self.tumblrSwitch.on = false
        }
        else {
            self.tumblrSwitch.on = true
        }
        
        if self.appdelegate.standardUserDefaults.valueForKey("Pinterest_Setting") == nil
            || self.appdelegate.standardUserDefaults.valueForKey("Pinterest_Setting")as! String == "N" {
                self.pinterestSwitch.on = false
        }
        else {
            self.pinterestSwitch.on = true
        }
    }
    @IBAction func complete(sender: AnyObject) {
        if self.facebookSwitch.on {
            self.appdelegate.standardUserDefaults.setValue("Y", forKey: "Facebook_Setting")
        }else {
            self.appdelegate.standardUserDefaults.setValue("N", forKey: "Facebook_Setting")
        }
        
        if self.twitterSwitch.on {
            self.appdelegate.standardUserDefaults.setValue("Y", forKey: "Twitter_Setting")
        }else {
            self.appdelegate.standardUserDefaults.setValue("N", forKey: "Twitter_Setting")
        }
        
        if self.tumblrSwitch.on {
            self.appdelegate.standardUserDefaults.setValue("Y", forKey: "Tumblr_Setting")
        }else {
            self.appdelegate.standardUserDefaults.setValue("N", forKey: "Tumblr_Setting")
        }
        
        if self.pinterestSwitch.on {
            self.appdelegate.standardUserDefaults.setValue("Y", forKey: "Pinterest_Setting")
        }else {
            self.appdelegate.standardUserDefaults.setValue("N", forKey: "Pinterest_Setting")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
