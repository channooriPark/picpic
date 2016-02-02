//
//  PostPageViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 12. 1..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import SpringIndicator

class PostPageViewController: SubViewController , UIAlertViewDelegate{
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var postImage: GifView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var body: RichTextView!
    @IBOutlet weak var uploadDate: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var comment: UIButton!
    
    @IBOutlet weak var uploadDataWid: NSLayoutConstraint!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var likeImageButton: UIButton!
    @IBOutlet weak var commentImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var moreImageButton: UIButton!
    @IBOutlet weak var lastCommentView: UIView!
    @IBOutlet weak var lastComUserName: UITextView!
    @IBOutlet weak var lastCombody: UILabel!
    @IBOutlet weak var lastComProfile: UIImageView!
    @IBOutlet weak var playCount: UILabel!
    @IBOutlet weak var postImageHei: NSLayoutConstraint!
    var month = ["January","Febuary","March","April","May","June","July","August","September","October","November","December"]
    @IBOutlet weak var dateWid: NSLayoutConstraint!
    @IBOutlet weak var tapbutton: UIButton!
    @IBOutlet weak var loading: SpringIndicator!
    @IBOutlet weak var usernameWid: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var dataloading: SpringIndicator!
    @IBOutlet weak var likeWid: NSLayoutConstraint!
    @IBOutlet weak var userNameButtonWid: NSLayoutConstraint!
    
    var email : String!
    var postId : String!
    let imageURL = ImageURL()
    var data : JSON!
    let log = LogPrint()
    var likeImage : UIImageView!
    var likeToggle = false
    @IBOutlet weak var bodyHei: NSLayoutConstraint!
    @IBOutlet weak var commentWid: NSLayoutConstraint!
    @IBOutlet weak var leadingusername: NSLayoutConstraint!
    var likeCount = 0
    var comCount = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading(true)
        self.likeImage = UIImageView(image: UIImage(named: "heart"))
        self.likeImage.frame = CGRectMake(self.postImage.frame.size.width/2-50, self.postImage.frame.size.height/2-42.5, 100, 85)
        self.likeImage.alpha = 0.0
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        lastComProfile.layer.borderWidth = 1
        lastComProfile.layer.masksToBounds = false
        lastComProfile.layer.borderColor = UIColor.clearColor().CGColor
        lastComProfile.layer.cornerRadius = lastComProfile.frame.height/2
        lastComProfile.clipsToBounds = true
        let message : JSON = ["my_id":email,"post_id":postId]
        
        self.appdelegate.doIt(504, message: message) { (readData) -> () in
            //profile
            print("readData : ",readData)
            self.loading(false)
            if readData != nil {
                if readData["id"].stringValue != "" {
                    self.loading.startAnimation()
                    self.data = readData
                    
                    
                    var like : NSString = "\(self.appdelegate.ment["like"].stringValue) \(readData["like_cnt"].stringValue)"
                    self.likeCount = readData["like_cnt"].int!
                    if self.appdelegate.locale == "ko_KR" {
                        //kr
                        like = (like as String) + "회"
                    }
                    
                    var com = "\(self.appdelegate.ment["comment"].stringValue) \(readData["reply_cnt"].stringValue)"
                    self.comCount = readData["reply_cnt"].int!
                    if self.appdelegate.locale == "ko_KR" {
                        //kr
                        com = com + "회"
                    }else {
                        self.commentWid.constant = 70
                    }
                    let likeSize : CGSize = like.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(13)])
                    self.comment.setTitle(com, forState: .Normal)
                    self.likeButton.setTitle(like as String, forState: .Normal)
                    self.likeButton.sizeToFit()
                    self.likeWid.constant = likeSize.width + 9
                    //username
                    let id : NSString = readData["id"].stringValue
                    let usernameSize : CGSize = id.sizeWithAttributes([NSFontAttributeName:UIFont.boldSystemFontOfSize(16)])
                    self.userNameButton.setTitle(readData["id"].stringValue, forState: .Normal)
                    self.userNameButton.titleLabel?.adjustsFontSizeToFitWidth = true
                    self.userNameButtonWid.constant = usernameSize.width + 10
                    self.usernameWid.constant = usernameSize.width + 26 + 10
                    
                    self.leadingusername.constant = (UIScreen.mainScreen().bounds.width/2)-(self.usernameWid.constant/2)
                    self.uploadedDate(readData["day"].stringValue)
                    self.uploadDate.adjustsFontSizeToFitWidth = true
                    self.uploadDate.sizeToFit()
                    self.uploadDataWid.constant = self.uploadDate.bounds.size.width + 5
                    
                    //play_cnt
                    self.playCount.text = readData["play_cnt"].stringValue
                    self.postImage.post_id = readData["post_id"].stringValue
                    
                    let profile = readData["profile_picture"].string!
                    var url = NSURL(string:  self.imageURL.imageurl(profile))
                    var data = NSData(contentsOfURL: url!)
                    self.profileImage.image = UIImage(data: data!)
                    if readData["last_com"]["profile_picture"].stringValue != "null" {
                        url = NSURL(string: self.imageURL.imageurl(readData["last_com"]["profile_picture"].stringValue))
                        data = NSData(contentsOfURL: url!)
                        self.lastComProfile.image = UIImage(data: data!)
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        
                        //postImage
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var thumb = readData["url"].stringValue.stringByReplacingOccurrencesOfString("_2.gif", withString: ".jpg")
                            thumb = String(format:"http://gif.picpic.world/%@", arguments:[thumb])
                            let url = NSURL(string: thumb)
                            if let data = NSData(contentsOfURL: url!) {
                                if let img = UIImage(data: data) {
                                    let nWidth = UIScreen.mainScreen().bounds.width;
                                    let nHeight = nWidth * img.size.height / img.size.width
                                    self.postImage.image = img
                                    self.postImageHei.constant = nHeight
                                    self.postImage.frame.size = CGSize(width: nWidth, height: nHeight)
                                }else {
                                    self.postImage.image = UIImage(named: "non_interest")
                                    self.postImage.frame.size = CGSize(width: self.postImage.frame.size.width, height: self.postImage.frame.size.width)
                                    self.postImageHei.constant = self.postImage.frame.size.width
                                }
                            }else {
                                self.postImage.image = UIImage(named: "non_interest")
                                self.postImage.frame.size = CGSize(width: self.postImage.frame.size.width, height: self.postImage.frame.size.width)
                                self.postImageHei.constant = self.postImage.frame.size.width
                            }
                            self.likeImage.frame.origin = CGPoint(x: self.postImage.frame.size.width/2-50, y: self.postImage.frame.size.height/2-42.5 + self.postImage.frame.origin.y)
                            self.view.addSubview(self.likeImage)
                            self.view.bringSubviewToFront(self.likeImage)
                            print("body frame before1",self.body.frame.origin.y)
                            self.body.frame.origin.y = self.postImage.frame.size.height + 3
                            self.body.updateConstraints()
                            self.view.updateConstraints()
                            print("body frame 1",self.body.frame.origin.y)
                        })
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //print("gif 다운로드")
                            self.postImage.animateForPicPicPost2(readData["url"].stringValue, spring: self.loading)
                            
                            self.postImageHei.constant = self.postImage.nHeight
                            self.likeImage.frame.origin = CGPoint(x: self.postImage.frame.size.width/2-50, y: self.postImage.frame.size.height/2-42.5 + self.postImage.frame.origin.y)
                            self.view.bringSubviewToFront(self.likeImage)
                            print("body frame before",self.body.frame.origin.y)
                            self.body.frame.origin.y = self.postImage.frame.size.height + 3
                            self.view.updateConstraints()
                            print("body frame   ",self.body.frame.origin.y)
                        })
                        
                    })
                    
                    
                    
                    //contents
                    self.body.scrollEnabled = false
                    self.body.putPost(readData["contents"].stringValue)
                    self.body.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    self.body.sizeToFit()
                    let fixedWidth = self.body.frame.size.width
                    self.body.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                    let newSize = self.body.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                    var newFrame = self.body.frame
                    let content = self.body.contentSize
                    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: content.height)
                    self.bodyHei.constant = content.height
                    self.body.scrollEnabled = false
                    
                    //lastComment
                    if readData["last_com"]["id"].string != "null" {
                        var attrString = NSAttributedString()
                        let para = NSMutableAttributedString()
                        let urlString = "picpic://comment/\(readData["post_id"].string!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)/\(readData["email"].string!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"
                        let font = UIFont(name: "HelveticaNeue-Bold", size: 15)
                        let _attrs : [String:AnyObject] = [NSFontAttributeName : font! , NSLinkAttributeName : urlString]
                        attrString = NSAttributedString(string: readData["last_com"]["id"].string!, attributes:_attrs)
                        para.appendAttributedString(attrString)
                        self.lastComUserName.attributedText = para
                        self.lastCombody.text = readData["last_com"]["body"].stringValue
                    }else {
                        self.lastCommentView.hidden = true
                        self.scrollView.contentSize.height -= 50
                    }
                    
                    
                    if readData["like_yn"].stringValue == "Y" {
                        self.likeImageButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
                        self.likeToggle = true
                    }
                }else {
                    let alert = UIAlertView(title: "", message: self.appdelegate.ment["delete_post"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                    alert.show()
                }
                
            }else {
                let alert = UIAlertView(title: "", message: self.appdelegate.ment["data_error"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert.show()
            }
            
            
        }
        let profiletap = UITapGestureRecognizer(target: self, action: "userViewTap")
        let nametap = UITapGestureRecognizer(target: self, action: "userViewTap")
        self.profileImage.userInteractionEnabled = true
        self.profileImage.addGestureRecognizer(profiletap)
        
        //        self.userNameButton.addTarget(self, action: "userViewTap", forControlEvents: .TouchUpInside)
        self.userNameButton.titleLabel?.userInteractionEnabled = true
        self.userNameButton.titleLabel?.addGestureRecognizer(nametap)
        
        let comprofiletap = UITapGestureRecognizer(target: self, action: "profileTap")
        self.lastComProfile.userInteractionEnabled = true
        self.lastComProfile.addGestureRecognizer(comprofiletap)
        
        
        let doubletap = UITapGestureRecognizer(target: self, action: "animationStop:")
        doubletap.numberOfTapsRequired = 1
        
       let buttonTap = UITapGestureRecognizer(target: self, action: "dou")
        buttonTap.numberOfTapsRequired = 2
        
        doubletap.requireGestureRecognizerToFail(buttonTap)
        
        self.tapbutton.addGestureRecognizer(doubletap)
        self.tapbutton.addGestureRecognizer(buttonTap)
        
        
        let lastviewtap = UITapGestureRecognizer(target: self, action: "lastcom_comment")
        self.lastCommentView.addGestureRecognizer(lastviewtap)
        
        
        print(self.likeButton.titleLabel?.text)
        //print(self.likeButton.frame)
        print(self.comment.titleLabel?.text)
        self.postImage.addSubview(self.likeImage)
        self.view.bringSubviewToFront(self.likeImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  viewWillDisappear  ")
        self.clickCheckCom = false
        
    }
    
    func loading(state:Bool) {
        if state {
            backView.hidden = false
            dataloading.startAnimation(true)
            NSThread.sleepForTimeInterval(0.2)
        }else {
            backView.hidden = true
            dataloading.stopAnimation(true)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            backTo()
        }
    }
 
    @IBAction func animationStop(sender: UITapGestureRecognizer) {
            self.postImage.pause()
    }
    
    func dou(){
        doubleLike()
    }
    
    func test() {
        //print("test")
    }
    
    func setCommentCount(count:Int){
        var com = "\(self.appdelegate.ment["comment"].stringValue) \(count)"
        if self.appdelegate.locale == "ko_KR" {
            //kr
            com = com + "회"
        }else {
            self.commentWid.constant = 70
        }
        self.comment.setTitle(com, forState: .Normal)
    }
    
    func doubleLike(){
            if !likeToggle {
                self.likeImage.fadeOut(completion: { (finished: Bool) -> Void in
                    self.likeImage.fadeIn(completion: { (finished: Bool) -> Void in
                        self.likeImage.fadeOut()
                    })
                })
                self.likeImageButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
                
                let message : JSON = ["post_reply_id":data["post_id"].stringValue,"click_id":self.email,"like_form":"P"]
                self.appdelegate.doIt(302, message: message, callback: { (readData) -> () in
                    if readData["msg"].string! == "success"{
                        if self.appdelegate.second.view.hidden == false {
                            if self.appdelegate.second.webState == "follow" {
                                self.appdelegate.second.following()
                            }else if self.appdelegate.second.webState == "all" {
                                self.appdelegate.second.all()
                            }else if self.appdelegate.second.webState == "category" {
                                self.appdelegate.second.category()
                            }
                        }
                    }
                    self.likeToggle = true
                    self.likeCount++
                    var like = "\(self.appdelegate.ment["like"].stringValue) \(self.likeCount)"
                    if self.appdelegate.locale == "ko_KR" {
                        //kr
                        like = like + "회"
                    }
                    self.likeButton.setTitle(like, forState: .Normal)
                })
                
            }else {
                self.likeImageButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
                let message : JSON = ["post_reply_id":data["post_id"].stringValue,"click_id":self.email,"like_form":"P"]
                self.appdelegate.doIt(303, message: message, callback: { (readData) -> () in
                    if readData["msg"].string! == "success"{
                        if self.appdelegate.second.view.hidden == false {
                            if self.appdelegate.second.webState == "follow" {
                                self.appdelegate.second.following()
                            }else if self.appdelegate.second.webState == "all" {
                                self.appdelegate.second.all()
                            }else if self.appdelegate.second.webState == "category" {
                                self.appdelegate.second.category()
                            }
                        }
                        self.likeToggle = false
                        self.likeCount--
                        var like = "\(self.appdelegate.ment["like"].stringValue) \(self.likeCount)"
                        if self.appdelegate.locale == "ko_KR" {
                            //kr
                            like = like + "회"
                        }
                        self.likeButton.setTitle(like, forState: .Normal)
                    }
                })
            }
    }
    
    @IBAction func back(sender: AnyObject) {
        log.log("back button clicked")
        backTo()
    }
    
    func backTo() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        if a.type == "tag" || a.type == "post" || a.type == "user" || a.type == "search" || a.type == "tag_name" {
            self.navigationController?.navigationBarHidden = true
        }else {
            self.navigationController?.navigationBarHidden = false
        }
        
        if !self.appdelegate.myfeed.view.hidden {
            self.navigationController?.navigationBarHidden = true
        }
        
        self.appdelegate.tabbar.view.hidden = false
        self.postImage.enterBackground()
        self.postImage.gifRemoveObserver()
        self.navigationController?.popViewControllerAnimated(true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    
    @IBAction func like(sender: AnyObject) {
        if !likeToggle {
            self.likeImage.fadeOut(completion: { (finished: Bool) -> Void in
                self.likeImage.fadeIn(completion: { (finished: Bool) -> Void in
                    self.likeImage.fadeOut()
                })
            })
            self.likeImageButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
            let message : JSON = ["post_reply_id":data["post_id"].stringValue,"click_id":self.email,"like_form":"P"]
            self.appdelegate.doIt(302, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success"{
                    
                }
                self.likeToggle = true
                self.likeCount++
                var like = "\(self.appdelegate.ment["like"].stringValue) \(self.likeCount)"
                if self.appdelegate.locale == "ko_KR" {
                    //kr
                    like = like + "회"
                }
                self.likeButton.setTitle(like, forState: .Normal)
            })
            
        }else {
            self.likeImageButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
            let message : JSON = ["post_reply_id":data["post_id"].stringValue,"click_id":self.email,"like_form":"P"]
            self.appdelegate.doIt(303, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success"{
                    self.likeToggle = false
                    self.likeCount--
                    var like = "\(self.appdelegate.ment["like"].stringValue) \(self.likeCount)"
                    if self.appdelegate.locale == "ko_KR" {
                        //kr
                        like = like + "회"
                    }
                    self.likeButton.setTitle(like, forState: .Normal)
                }
            })
        }
    }
    
    func userViewTap() {
        //userpage
        //print("aaaaaaaaaaaaaaa")
        let user = self.storyboard!.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
        self.appdelegate.controller.append(user)
        user.type = "user"
//        user.index = self.appdelegate.controller.count - 1
        user.myId = self.email
        user.userId = data["email"].stringValue
        self.postImage.enterBackground()
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.pushViewController(user, animated: true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func profileTap() {
        //print("bbbbbbbbbbbbbbbbbbbbbbbbb")
        let user = self.storyboard!.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
        self.appdelegate.controller.append(user)
        user.type = "user"
//        user.index = self.appdelegate.controller.count - 1
        user.myId = self.email
        user.userId = data["last_com"]["email"].stringValue
        self.postImage.enterBackground()
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.pushViewController(user, animated: true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    var clickCheckCom = false
    @IBAction func comment(sender: AnyObject) {
        if clickCheckCom {
            return
        }
        
        clickCheckCom = true
        let comment = storyboard!.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
        self.appdelegate.controller.append(comment)
        comment.type = "comment"
//        comment.index = self.appdelegate.controller.count - 1
        comment.my_id = self.email
        comment.post_id = self.data["post_id"].stringValue
        comment.postEmail = self.data["email"].stringValue
        self.navigationController?.navigationBarHidden = false
        self.appdelegate.testNavi.pushViewController(comment, animated: true)
        self.appdelegate.main.view.hidden = true
        self.appdelegate.tabbar.view.hidden = true
        self.postImage.enterBackground()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func lastcom_comment(){
        if clickCheckCom {
            return
        }
        
        clickCheckCom = true
        let comment = storyboard!.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
        self.appdelegate.controller.append(comment)
        comment.type = "comment"
        comment.my_id = self.email
        comment.post_id = self.data["post_id"].stringValue
        comment.postEmail = self.data["email"].stringValue
        self.navigationController?.navigationBarHidden = false
        self.appdelegate.testNavi.pushViewController(comment, animated: true)
        self.appdelegate.main.view.hidden = true
        self.appdelegate.tabbar.view.hidden = true
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    
    @IBAction func share(sender: AnyObject) {
        let count = self.appdelegate.testNavi.viewControllers.count - 1
        //            message = ["my_id":self.email,"post_id":send_id]
        //            let connection = URLConnection(serviceCode: 504, message: message)
        //            let readData = connection.connection()
        let share = self.storyboard!.instantiateViewControllerWithIdentifier("ShareViewController")as! ShareViewController
        share.post_id = data["post_id"].stringValue
        share.url = data["url"].stringValue
        if data["repic_yn"].stringValue == "Y" {
            share.repicState = true
        }else {
            share.repicState = false
        }
        self.appdelegate.testNavi.viewControllers[count].addChildViewController(share)
        self.appdelegate.testNavi.viewControllers[count].view.addSubview(share.view)
    }
    
    @IBAction func more(sender: AnyObject) {
        if self.appdelegate.email == data["email"].stringValue {
            let count = self.appdelegate.testNavi.viewControllers.count - 1
            let moreme = self.storyboard!.instantiateViewControllerWithIdentifier("MoreMeViewController")as! MoreMeViewController
            moreme.post_id = data["post_id"].stringValue
            moreme.email = data["email"].stringValue
            
            self.appdelegate.testNavi.viewControllers[count].addChildViewController(moreme)
            self.appdelegate.testNavi.viewControllers[count].view.addSubview(moreme.view)
        }else {
            let count = self.appdelegate.testNavi.viewControllers.count - 1
            let moreother = self.storyboard!.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
            moreother.post_id = data["post_id"].stringValue
            self.appdelegate.testNavi.viewControllers[count].addChildViewController(moreother)
            self.appdelegate.testNavi.viewControllers[count].view.addSubview(moreother.view)
        }
    }
    
    @IBAction func likeList(sender: AnyObject) {
        let like = self.storyboard!.instantiateViewControllerWithIdentifier("LikeListViewController")as! LikeListViewController
        like.email = self.email
        like.tagId = self.data["post_id"].stringValue
        self.appdelegate.testNavi.navigationBarHidden = false
        self.appdelegate.tabbar.view.hidden = true
        self.postImage.enterBackground()
        self.appdelegate.testNavi.pushViewController(like, animated: true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    @IBAction func commentAgain(sender: AnyObject) {
        comment(sender)
    }
    
    func refreshData() {
        let message : JSON = ["my_id":email,"post_id":postId]
        self.appdelegate.doIt(504, message: message) { (readData) -> () in
            if readData != nil {
                self.data = readData
            }
        }
    }
    
    
    
    //등록 날자 계산 func
    func uploadedDate(uploadDateText : String){
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"  //원래 date format
        
        //현재 날짜
        let date = NSDate()
        //JSON으로 가져온 데이터 NSDate로 변환
        let uploadTime = formatter.dateFromString(uploadDateText)
        
        //현재 Language 가져오기
        let defaults = NSUserDefaults.standardUserDefaults()
        let languages : NSArray = defaults.objectForKey("AppleLanguages")! as! NSArray
        let currentLanguage = languages.objectAtIndex(0)
        let locale = NSLocale.currentLocale()
        //formatter에 언어 설정
        formatter.locale = locale
        
        
        formatter.dateFormat = "yyyyMMdd" //일수 확인을 위한 format
        var day = Int(formatter.stringFromDate(uploadTime!))
        var currentDate = Int(formatter.stringFromDate(date))
        
        //일수 차이 계산
        var valueInterval = currentDate! - day!
        
        if valueInterval > 0 {
            var time = ""
            if self.appdelegate.locale == "ko_KR" {
                self.dateWid.constant = 52
                formatter.dateFormat = "MM\(self.appdelegate.ment["tmonth"].stringValue)월 dd\(self.appdelegate.ment["day"].stringValue)"
                time = formatter.stringFromDate(uploadTime!)
            }else {
                formatter.dateFormat = "MM/dd"
                let day = formatter.stringFromDate(uploadTime!).componentsSeparatedByString("/")
                self.dateWid.constant = 80
                switch day[0] {
                case "1" :
                    time = "\(self.month[0]) \(day[1])"
                    break
                case "2" :
                    time = "\(self.month[1]) \(day[1])"
                    break
                case "3" :
                    time = "\(self.month[2]) \(day[1])"
                    break
                case "4" :
                    time = "\(self.month[3]) \(day[1])"
                    break
                case "5" :
                    time = "\(self.month[4]) \(day[1])"
                    break
                case "6" :
                    time = "\(self.month[5]) \(day[1])"
                    break
                case "7" :
                    time = "\(self.month[6]) \(day[1])"
                    break
                case "8" :
                    time = "\(self.month[7]) \(day[1])"
                    break
                case "9" :
                    time = "\(self.month[8]) \(day[1])"
                    break
                case "10" :
                    time = "\(self.month[9]) \(day[1])"
                    break
                case "11" :
                    time = "\(self.month[10]) \(day[1])"
                    break
                default :
                    time = "\(self.month[11]) \(day[1])"
                    break
                }
            }
            uploadDate.text = time
        }else{
            
            //시간 계산을 위한 format
            formatter.dateFormat = "HH"
            
            //시간 차이 계산
            day = Int(formatter.stringFromDate(uploadTime!))
            currentDate = Int(formatter.stringFromDate(date))
            valueInterval = currentDate! - day!
            
            if valueInterval > 0 {
                if self.appdelegate.locale != "ko_KR" {
                    self.dateWid.constant = 80
                }
                
                
                self.uploadDate.text = "\(valueInterval)\(self.appdelegate.ment["timeline_before_hour"].stringValue)"
            }else {
                formatter.dateFormat = "mm"
                
                day = Int(formatter.stringFromDate(uploadTime!))
                currentDate = Int(formatter.stringFromDate(date))
                valueInterval = currentDate! - day!
                
                if valueInterval > 0 {
                    if self.appdelegate.locale != "ko_KR" {
                        self.dateWid.constant = 85
                    }
                    
                    uploadDate.text = "\(valueInterval)\(self.appdelegate.ment["timeline_before_minute"].stringValue)"
                }else {
                    if self.appdelegate.locale != "ko_KR" {
                        self.dateWid.constant = 30
                    }
                    if self.appdelegate.locale == "ko_KR" {
                        uploadDate.text = "방금전"
                    }else {
                        uploadDate.text = "now"
                    }
                    
                }
            }
            
            
        }
        
    }
    
    
}
