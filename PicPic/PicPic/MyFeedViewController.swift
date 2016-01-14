//
//  MyFeedViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyFeedViewController: UIViewController ,UIAlertViewDelegate{
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var postingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var repicButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var tagCountLabel: UILabel!
    @IBOutlet weak var tag_nameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var tempView: UIView!
    var readData : JSON!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let imageURL = ImageURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
            profileImage.layer.borderWidth = 1
            profileImage.layer.masksToBounds = false
            profileImage.layer.borderColor = UIColor.clearColor().CGColor
            profileImage.layer.cornerRadius = profileImage.frame.height/2
            profileImage.clipsToBounds = true
            
            self.view.bringSubviewToFront(self.profileEditButton)
        NSLog("\(self.appdelegate.email)")
        
        if self.appdelegate.email != nil {
            let message : JSON = ["my_id":self.appdelegate.email,"user_id":self.appdelegate.email]
            let connection = URLConnection(serviceCode: 406, message: message)
            readData = connection.connection()
            print(readData)
            self.appdelegate.email = readData["email"].string!
            getData(readData)
        }
        
        
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        print(appdelegate.email)
        if appdelegate.email == nil {
            tempView.hidden = false
            let alert = UIAlertView(title: "", message: "로그인 후 이용바랍니다", delegate: self, cancelButtonTitle: "취소", otherButtonTitles: "로그인")
            alert.show()
        }else {
            tempView.hidden = true
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            //취소
            let timeline : UITabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TimeLineTabBar")as! UITabBarController
            appdelegate.window?.rootViewController = timeline
        }else {
            //로그인
            let viewController : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
            
            
            viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            viewController.navigationBar.shadowImage = UIImage()
            viewController.navigationBar.translucent = true
            viewController.navigationBar.tintColor = UIColor.whiteColor()
            
            appdelegate.window?.rootViewController = viewController
        }
    }
    
       
    
    func getData(json:JSON){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if let profile = json["profile_picture"].string {
                let url = NSURL(string: self.imageURL.imageurl(profile))
                NSLog("\(self.imageURL.imageurl(profile))")
                let data = NSData(contentsOfURL: url!)
                
                self.profileImage.image = UIImage(data: data!)
            }
        }
        if let post = json["post_cnt"].int{
            postingCount.text = String(post)
        }
        if let follow = json["follower_cnt"].int {
            followerCount.text = String(follow)
        }
        if let following = json["follow_cnt"].int {
            followingCount.text = String(following)
        }
        if let id = json["id"].string {
            userIDLabel.text = id
        }
        if let tag = json["p_tag_1"]["tag_name"].string {
            tag_nameLabel.text = tag
        }else {
            tag_nameLabel.text = ""
            tag_nameLabel.frame = CGRectMake(91, 188, 2, 21)
        }
        
        
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingClicked(sender: AnyObject) {
        let setting = self.storyboard?.instantiateViewControllerWithIdentifier("settingNav")as! UINavigationController
//        self.navigationController?.pushViewController(setting, animated: true)
        self.presentViewController(setting, animated: true, completion: nil)

    }

        @IBAction func profileEdit(sender: AnyObject) {
        
    }
    @IBAction func search(sender: AnyObject) {
    }
    
    
    @IBAction func list(sender: AnyObject) {
        listButton.setImage(UIImage(named: "icon_my_list_c"), forState: .Normal)
        gridButton.setImage(UIImage(named: "icon_my_gather"), forState: .Normal)
        
    }
    @IBAction func grid(sender: AnyObject) {
        listButton.setImage(UIImage(named: "icon_my_list"), forState: .Normal)
        gridButton.setImage(UIImage(named: "icon_my_gather_c"), forState: .Normal)
    }
    
    @IBAction func user(sender: AnyObject) {
        userButton.setBackgroundImage(UIImage(named: "btn_myfeed_user_c"), forState: .Normal)
        repicButton.setBackgroundImage(UIImage(named: "btn_myfeed_user"), forState: .Normal)
    }
    @IBAction func repic(sender: AnyObject) {
        userButton.setBackgroundImage(UIImage(named: "btn_myfeed_user"), forState: .Normal)
        repicButton.setBackgroundImage(UIImage(named: "btn_myfeed_user_c"), forState: .Normal)
    }
}
