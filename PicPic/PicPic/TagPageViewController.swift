//
//  TagPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 12. 23..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagPageViewController: SubViewController {
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let log = LogPrint()
    let imageURL = ImageURL()
    var data : JSON!
    var tagId : String!
    var email : String!
    
    //top view
    var backGifView : UIImageView! // back gifView
    var gifalphaView : UIView!
    var backButton : UIButton!
    var tagTitle : UILabel!
    var followButton : UIButton!
    var createrId : UIButton!
    
    //posting
    var postingView : UIView!
    var postingcount : UILabel!
    var postingTitle : UILabel!
    //follower
    var follower : UIView!
    var followerCount : UILabel!
    var followerTitle : UILabel!
    var followerButton : UIButton!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type = "tag_name"
        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        self.view.backgroundColor = UIColor.blackColor()
        
        backGifView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width-120))
        self.view.addSubview(backGifView)
        gifalphaView = UIView(frame: backGifView.frame)
        gifalphaView.backgroundColor = UIColor.blackColor()
        gifalphaView.alpha = 0.5
        self.view.addSubview(gifalphaView)
        
        
        tagTitle = UILabel()
        var title = tagId as NSString
        if title.length > 20 {
            title = title.substringWithRange(NSMakeRange(0, 17))
            title = (title as String)+"..."
        }
        
        tagTitle.frame = CGRectMake(self.view.frame.size.width/2-(CGFloat(title.length*17)/2), 40, CGFloat(title.length*17)+17, 25)
        tagTitle.center.x = view.center.x
        tagTitle.text = "#"+(title as String)
        tagTitle.font = UIFont(name: "Helvetica-Bold", size: 17)
        tagTitle.textColor = UIColor.whiteColor()
        tagTitle.textAlignment = .Center
        self.view.addSubview(tagTitle)
        
        self.followButton = UIButton(type: .Custom)
        self.followButton.frame = CGRectMake(0, 80, 100, 25)
        self.followButton.addTarget(self, action: "tagFollow", forControlEvents: .TouchUpInside)
        self.followButton.center.x = self.view.center.x
        self.followButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        self.followButton.setBackgroundImage(UIImage(named: "btn_tegfeed_follow"), forState: .Normal)
        self.followButton.setTitle("\(self.appdelegate.ment["follow_plus"].stringValue)", forState: .Normal)
        self.view.addSubview(self.followButton)
        
        let half = self.view.frame.size.width/2
        
        postingView = UIView(frame: CGRectMake(half-80,125,80,32))
        postingcount = UILabel(frame: CGRectMake(0,0,postingView.frame.size.width,11))
        postingcount.textAlignment = .Center
        postingcount.text = "0"
        postingcount.textColor = UIColor.whiteColor()
        postingcount.font = UIFont(name: "Helvetica", size: 11)
        postingTitle = UILabel(frame: CGRectMake(0,postingView.frame.size.height-11,postingView.frame.size.width,11))
        postingTitle.textAlignment = .Center
        postingTitle.text = self.appdelegate.ment["posting"].stringValue
        postingTitle.font = UIFont(name: "Helvetica", size: 11)
        postingTitle.textColor = UIColor.whiteColor()
        self.postingView.addSubview(postingcount)
        self.postingView.addSubview(postingTitle)
        self.view.addSubview(postingView)
        
        follower = UIView(frame: CGRectMake(half,125,80,32))
        followerCount = UILabel(frame: CGRectMake(0,0,follower.frame.size.width,11))
        followerCount.textAlignment = .Center
        followerCount.text = "0"
        followerCount.textColor = UIColor.whiteColor()
        followerCount.font = UIFont(name: "Helvetica", size: 11)
        followerTitle = UILabel(frame: CGRectMake(0,follower.frame.size.height-11,follower.frame.size.width,11))
        followerTitle.textAlignment = .Center
        followerTitle.text = self.appdelegate.ment["follower"].stringValue
        followerTitle.font = UIFont(name: "Helvetica", size: 11)
        followerTitle.textColor = UIColor.whiteColor()
        followerButton = UIButton(type: .Custom)
        followerButton.frame = CGRectMake(0, 0, follower.frame.size.width, follower.frame.size.height)
        followerButton.addTarget(self, action: "followerList", forControlEvents: .TouchUpInside)
        
        self.follower.addSubview(followerCount)
        self.follower.addSubview(followerTitle)
        self.follower.addSubview(followerButton)
        self.view.addSubview(follower)
        
        
        
        
        let message : JSON = ["my_id":email,"tag_str":tagId]
        self.appdelegate.doItSocket(517, message: message) { (readData) -> () in
            self.log.log("readData              \(readData)")
            
            if readData["msg"].string == "success" {
                self.data = readData
                if readData["url"].string != "" {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
                        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                        dispatch_async(backgroundQueue, { () -> Void in
                            let url = NSURL(string: self.imageURL.imageurl(readData["url"].stringValue))
                            if let data = NSData(contentsOfURL: url!){
                                self.backGifView.image = UIImage.gifWithData(data)
                            }
                            dispatch_async(backgroundQueue, { () -> Void in
                                let url = NSURL(string: self.imageURL.gifImageUrl(readData["url"].stringValue))
                                if let data = NSData(contentsOfURL: url!){
                                    self.backGifView.image = UIImage.gifWithData(data)
                                }
                                
                            })
                        })
                    })
                }
                self.postingcount.text = readData["post_cnt"].stringValue
                
                
                if readData["follow_yn"].stringValue == "Y" {
                    self.followButton.setBackgroundImage(UIImage(named: "btn_tegfeed_follow_c"), forState: .Normal)
                    self.followButton.setTitle("\(self.appdelegate.ment["following"].stringValue)", forState: .Normal)
                }else {
                    self.followButton.setBackgroundImage(UIImage(named: "btn_tegfeed_follow"), forState: .Normal)
                    self.followButton.setTitle("\(self.appdelegate.ment["follow_plus"].stringValue)", forState: .Normal)
                }
                
            }
            
            var id = readData["id"].stringValue as NSString
            
            self.createrId = UIButton(type: .Custom)
            self.createrId.frame = CGRectMake(5, self.backGifView.frame.size.height-30, CGFloat(id.length*8)+8, 12)
            self.createrId.setTitle("@"+readData["id"].stringValue, forState: .Normal)
            self.createrId.titleLabel?.font = UIFont(name: "Helvetica", size: 12)
            self.createrId.titleLabel?.textAlignment = .Left
            self.createrId.titleLabel?.adjustsFontSizeToFitWidth = true
            self.createrId.sizeToFit()
            self.createrId.backgroundColor = UIColor.redColor()
            self.createrId.addTarget(self, action: "moveUserFeed", forControlEvents: .TouchUpInside)
            self.view.addSubview(self.createrId)
        }
        backButton = UIButton(type: .Custom)
        backButton.frame = CGRectMake(5, 21, 33, 33)
        backButton.setImage(UIImage(named: "back_white"), forState: .Normal)
        backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        log.log("als;fkjeoiasdjfeo")
    }
    
    func back(){
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        //        print(count)
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search"{
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        if self.appdelegate.myfeed.view.hidden == false {
            self.navigationController?.navigationBarHidden = true
        }
        
        //        self.appdelegate.controller.removeAtIndex(a.index)
        self.appdelegate.tabbar.view.hidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tagFollow() {
        let message : JSON = ["myId":appdelegate.email,"tag_id":data["tag_id"].stringValue]
        //            let connection = URLConnection(serviceCode: 403, message: message)
        //            let readData = connection.connection()
        appdelegate.doItSocket(403, message: message, callback: { (readData) -> () in
            if readData["follow"].stringValue == "Y" {
                self.followButton.setBackgroundImage(UIImage(named: "btn_tegfeed_follow_c"), forState: .Normal)
            }else {
                self.followButton.setBackgroundImage(UIImage(named: "btn_tegfeed_follow"), forState: .Normal)
            }
        })
    }
    
    func followerList() {
        let follower = appdelegate.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
        follower.email = appdelegate.email
        follower.tagId = data["tag_id"].stringValue
        follower.followType = "tag"
        appdelegate.testNavi.hidesBottomBarWhenPushed = true
        appdelegate.testNavi.pushViewController(follower, animated: true)
    }
    
    func moveUserFeed() {
        if appdelegate.controller[appdelegate.controller.count-1].type == "search" {
            appdelegate.tabbar.view.hidden = false
        }
        
        let user = appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
        appdelegate.controller.append(user)
        user.type = "user"
        //            user.index = appdelegate.controller.count - 1
        user.myId = appdelegate.email
        user.userId = data["tag_founder"].stringValue
        appdelegate.testNavi.navigationBarHidden = true
        appdelegate.testNavi.pushViewController(user, animated: true)
    }
    
    
}
