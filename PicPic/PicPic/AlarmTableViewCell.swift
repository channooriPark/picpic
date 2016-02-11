//
//  AlarmTableViewCell.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 30..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class AlarmTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var followOkButton: UIButton!
    @IBOutlet weak var followNoButton: UIButton!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let imageURL = ImageURL()
    var data : JSON!
    var post : UIImage!
    let log = LogPrint()
    var alarm : AlramViewController!
    var type : String!
    
    @IBOutlet weak var profileWid: NSLayoutConstraint!
    @IBOutlet weak var profileHei: NSLayoutConstraint!
    @IBOutlet weak var postImageWid: NSLayoutConstraint!
    @IBOutlet weak var postImageHei: NSLayoutConstraint!
    @IBOutlet weak var followWid: NSLayoutConstraint!
    @IBOutlet weak var followHei: NSLayoutConstraint!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        if UIScreen.mainScreen().bounds.width == 320.0 {
            body.font = UIFont.systemFontOfSize(12)
            profileWid.constant = 41
            profileHei.constant = 41
        }
        
        

    }
    
    func setData(image : UIImage!) {
        self.profileImage.image = image
        log.log("\(self.profileImage.image?.size)")
        log.log("\(self.profileImage.frame)")
        
        if self.post != nil {
            self.postImage.image = self.post
            let postTap = UITapGestureRecognizer(target: self, action: "movePost")
            postTap.numberOfTapsRequired =  1
            self.postImage.userInteractionEnabled = true
            self.postImage.addGestureRecognizer(postTap)
        }
        if let button = oneButton {
            if data["follow_yn"].string! == "Y" {
                self.oneButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }else {
                self.oneButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
            }
        }
    }
    
    func movePost(){
        let post = self.appdelegate.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
        self.appdelegate.controller.append(post)
//        post.index = self.appdelegate.controller.count - 1
        post.type = "post"
        post.email = self.appdelegate.email
        post.postId = self.data["target_id_1"].string!
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.pushViewController(post, animated: true)
    }
    
    func user(){
        let user = self.appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
        self.appdelegate.controller.append(user)
        user.type = "user"
//        user.index = self.appdelegate.controller.count - 1
        user.myId = self.appdelegate.email
        user.userId = self.data["who_email"].string!
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.pushViewController(user, animated: true)
        
    }
    
    
    func setMent(){
        if UIScreen.mainScreen().bounds.width == 320.0 {
            if type == "alarmPhoto" {
                postImageWid.constant = 62
                postImageHei.constant = 62
            }else if type == "alarmOneButton" {
                followWid.constant = 30
                followHei.constant = 30
            }
        }
        let profileTap = UITapGestureRecognizer(target: self, action: "user")
        profileTap.numberOfTapsRequired =  1
        self.profileImage.userInteractionEnabled = true
        self.profileImage.addGestureRecognizer(profileTap)
        ment(self.data["type"].string!, id: self.data["who_id"].string!, andTag: nil)
        self.dateLabel.text = imageURL.uploadedDate(self.data["date"].string!)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func follow(sender: AnyObject) {
        let type : String!
        
        log.log("\(self.appdelegate.userData["register_form"].stringValue)")
        
        if self.appdelegate.userData["register_form"].string == "10001" {
            type = "N"
        }else if self.appdelegate.userData["register_form"].string == "10002" {
            type = "F"
        }else if self.appdelegate.userData["register_form"].string == "10003" {
            type = "G"
        }else {
            type = "R"
        }
        
        
        let message : JSON = ["myId":self.appdelegate.email,"email":[["email":self.data["who_email"].string!]],"type":type]
        self.appdelegate.doIt(402, message: message, callback: { (readData) -> () in
            if readData["follow"].string! == "Y" {
                self.oneButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }else {
                self.oneButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
            }
        })
    }
    
    func ment(type:String,id:String,andTag:String?){
        if type == "PL" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_post_like_ment"].stringValue)"
        }else if type == "CL" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_comment_like_ment"].stringValue)"
        }else if type == "PC" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_post_comment_ment"].stringValue)"
        }else if type == "FM" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_follow_me_ment"].stringValue)"
        }else if type == "RM" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_post_repic_ment"].stringValue)"
        }else if type == "CMP" {
            self.body.text = "\(self.appdelegate.ment["notification_report_post_ment"].stringValue)"
        }else if type == "CMC" {
            self.body.text = "\(self.appdelegate.ment["notification_report_comment_ment"].stringValue)"
        }else if type == "FP" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_profile_change_ment"].stringValue)"
        }else if type == "FI" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_id_change_ment"].stringValue)"
        }else if type == "FJA" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_and_join_1_ment"].stringValue) \(andTag)\(self.appdelegate.ment["notification_and_join_2_ment"].stringValue)"
        }else if type == "FCA" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_and_create_1_ment"].stringValue) \(andTag)\(self.appdelegate.ment["notification_and_create_2_ment"].stringValue)"
        }else if type == "TMC" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_comment_tag_ment"].stringValue)"
        }else if type == "TMP" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_comment_post_ment"].stringValue)"
        }else if type == "RP" {
            self.body.text = "\(id) \(self.appdelegate.ment["notification_replay_comment_ment"].stringValue)"
            
        }
    }

}
