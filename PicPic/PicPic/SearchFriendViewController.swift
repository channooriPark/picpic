//
//  AlramViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire
import Foundation

class SearchFriendViewController: SubViewController ,UITableViewDataSource , UITableViewDelegate ,SearchFriendDelegate{
    
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var fbImage: UIImageView!
    @IBOutlet weak var fbSelectBar: UIImageView!
    //@IBOutlet weak var ggButton: UIButton!
    //@IBOutlet weak var ggImage: UIImageView!
    //@IBOutlet weak var ggSelectBar: UIImageView!
    @IBOutlet weak var recomImage: UIImageView!
    @IBOutlet weak var recomButton: UIButton!
    @IBOutlet weak var recomSelectBar: UIImageView!
    @IBOutlet weak var fbText: UILabel!
    //@IBOutlet weak var ggText: UILabel!
    @IBOutlet weak var recomText: UILabel!
    @IBOutlet weak var tblFriend: UITableView!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var allFollow: UIButton!
    var fbT = true
    var recomT = false
    var ggT = false
    var id = "";
    var count = 0
    var dict : NSDictionary!
    var postInfos: Array<[String: AnyObject]> = []
    
    var friendData = [FriendEntity]()
    var cells = [SearchFriendTableViewCell]()
    var posts = [[String]]()
    var allFollowT = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        let image = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        image.image = UIImage(named: "back_white")
        let backButton = UIBarButtonItem(customView: image)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backToMyFeed")
        image.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = self.appdelegate.ment["find_friend"].stringValue
        
        allFollow.setTitle(self.appdelegate.ment["allFollow"].stringValue, forState: .Normal)
        fbText.text = self.appdelegate.ment["find_friend_facebook"].stringValue
        recomText.text = self.appdelegate.ment["find_friend_recommend"].stringValue
        
        
        if self.appdelegate.locale != "ko_KR" {
            fbText.font = UIFont(name: "Helvetica", size: 12)
            //ggText.font = UIFont(name: "Helvetica", size: 12)
            recomText.font = UIFont(name: "Helvetica", size: 12)
        }else{
            fbText.font = UIFont(name: "Helvetica", size: 14)
            //ggText.font = UIFont(name: "Helvetica", size: 14)
            recomText.font = UIFont(name: "Helvetica", size: 14)
        }
        self.type = "searchFriend"
        facebook()
        
    }
    
    func backToMyFeed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func onFacebook(sender: AnyObject) {
        facebook()
    }
    
    @IBAction func onRecommend(sender: AnyObject) {
        recommend()
    }
    
    
    func facebook() {
        fbT = true
        recomT = false
        
        fbText.textColor = UIColor.blackColor()
        fbSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        recomText.textColor = UIColor.lightGrayColor()
        recomSelectBar.image = UIImage()
        
        fbImage.image = UIImage(named: "icon_find_facebook_s")
        recomImage.image = UIImage(named: "icon_timeline_picpic")
        
        self.whereLabel.text = self.appdelegate.ment["facebook_friend"].stringValue
        
        
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            getFriendData(0);
        }
        else
        {
            facebookLogined()
        }
    }
    
    func facebookLogined() {
        print("facebookLogin")
        let login : FBSDKLoginManager = FBSDKLoginManager()
        
        login.logInWithReadPermissions(["public_profile","email","user_friends","user_about_me","user_birthday"], fromViewController: self) { (result, error) -> Void in
            if error != nil {
                NSLog("Process error")
            }else if result.isCancelled {
                NSLog("Cancelled")
            }else {
                self.getFriendData(0);
            }
        }
    }

    
    func recommend() {
        fbT = false
        recomT = true
        
        recomText.textColor = UIColor.blackColor()
        recomSelectBar.image = UIImage(named: "imv_find_selectbar")
        
        fbText.textColor = UIColor.lightGrayColor()
        fbSelectBar.image = UIImage()
        
        fbImage.image = UIImage(named: "icon_find_facebook")
        recomImage.image = UIImage(named: "icon_timeline_picpic_c")
        
        self.whereLabel.text = self.appdelegate.ment["recommend_friend"].stringValue
        
        getFriendData(1);
    }
    
    
    func getFriendData(inwhere : Int) {
        self.friendData.removeAll()
        
        var inWhereString:String!
        var count = 0
        
        switch (inwhere) {
            
        case 0: // fb
            self.posts.removeAll()
            self.friendData.removeAll()
            self.tblFriend.reloadData()
            inWhereString = self.appdelegate.ment["facebook_friend"].stringValue
            let params = ["fields": "id, name, first_name, last_name, picture.type(large), email"]
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
            graphRequest.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                if(error == nil)
                {
                    let data = JSON(result)
                    print("result Data : ",data["data"].arrayValue)
                    var friends = [JSON]()
                    for var i = 0; i<data["data"].arrayValue.count; i++ {
                        friends.append(["email":data["data"][i]["id"].stringValue])
                    }
                    print(friends)
                    let register_form = self.appdelegate.dec(self.appdelegate.standardUserDefaults.valueForKey("register_form")as! String)
                    var message : JSON = ["my_id":self.appdelegate.email,"friends":[[]],"register_form":register_form]
                    message["friends"] = JSON(friends)
                    print("message : ",message)
                    self.appdelegate.doIt(401, message: message, callback: { (readData) -> () in
                        for data in readData["data"].arrayValue {
                            let friend_name = data["id"].stringValue //userID
                            let friend_picture =  data["profile_picture"].stringValue //profile Image
                            let follow_yn = data["follow_yn"].stringValue //follow
                            let arr = data["posts"].arrayValue
                            var post = [String]()
                            print("readData print friend name : ",friend_name)
                            if data["posts"].type == .Null {
                                let friend = FriendEntity(name: friend_name, profile:"http://gif.picpic.world/" + friend_picture, first: "", sencond: "", third: "", fourth: "", follow_yn:follow_yn, email : data["email"].stringValue)
                                self.friendData.append(friend)
                            }else {
                                for temp in arr {
                                    //post = post_id array value. that will go to post page view controller
                                    if temp["post_id"].type != .Null {
                                        post.append(temp["post_id"].stringValue)
                                    }
                                }
                                self.posts.append(post)
                                let friend = FriendEntity(name: friend_name, profile:"http://gif.picpic.world/" + friend_picture,
                                    first:arr.count > 0 ? arr[0]["url"].stringValue : "",
                                    sencond: arr.count > 1 ? arr[1]["url"].stringValue : "",
                                    third: arr.count > 2 ? arr[2]["url"].stringValue : "",
                                    fourth: arr.count > 3 ? arr[3]["url"].stringValue : "",
                                    follow_yn:follow_yn, email : data["email"].stringValue)
                                print("friend email  : ",friend.email)
                                self.friendData.append(friend)
                            }
                        if (inwhere == 0 || inwhere == 1) {
                            self.whereLabel.text = String(format: "%@ %d", inWhereString, self.friendData.count) + self.appdelegate.ment["friend_counter"].stringValue
                            } else {
                            self.whereLabel.text = inWhereString
                            }
                            self.tblFriend.reloadData()
                        }
                        for i in 0 ..< self.friendData.count {
                            if self.friendData[i].follow_yn == "N" {
                                self.allFollowT = false
                                self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next"), forState: .Normal)
                                self.allFollow.setTitleColor(Config.getInstance().color, forState: .Normal)
                            }
                        }
                        if self.allFollowT {
                            self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next_c"), forState: .Normal)
                            self.allFollow.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        }
                        self.tblFriend.reloadData()
                    })
                }
                else
                {
                    print(error)
                }
            })
            count = 10
            break;
            
        case 1: // recommend
            self.posts.removeAll()
            self.friendData.removeAll()
            self.tblFriend.reloadData()
            inWhereString = self.appdelegate.ment["recommend_friend"].stringValue
            count = 3
            
            let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let message : JSON = ["my_id":appdelegate.email]
            
            appdelegate.doIt(411, message: message, callback: {(readData) in
                
                for data in readData["friends"].arrayValue {
                    print(data)
                    var userId = String();
                    userId = data["email"].stringValue
                    let friend_name = data["id"].stringValue
                    let friend_picture =  data["profile_picture"].stringValue
                    let follow_yn = data["follow_yn"].stringValue
                    var arr = data["posts"].arrayValue
                    var post = [String]()
                    
                    for temp in arr {
                        if temp["post_id"].type != .Null {
                            post.append(temp["post_id"].stringValue)
                        }
                    }
                    self.posts.append(post)
                    let friend = FriendEntity(name: friend_name, profile:"http://gif.picpic.world/" + friend_picture,
                        first:arr.count > 0 ? arr[0]["url"].stringValue : "",
                        sencond: arr.count > 1 ? arr[1]["url"].stringValue : "",
                        third: arr.count > 2 ? arr[2]["url"].stringValue : "",
                        fourth: arr.count > 3 ? arr[3]["url"].stringValue : "",
                        follow_yn:follow_yn,email : userId)
                    
                    self.friendData.append(friend)
                    
                    if (inwhere == 0 || inwhere == 1) {
                        self.whereLabel.text = String(format: "%@ %d", inWhereString, self.friendData.count) + self.appdelegate.ment["friend_counter"].stringValue
                    } else {
                        self.whereLabel.text = inWhereString
                    }
                    for i in 0 ..< self.friendData.count {
                        if self.friendData[i].follow_yn == "N" {
                            self.allFollowT = false
                            self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next"), forState: .Normal)
                            self.allFollow.setTitleColor(Config.getInstance().color, forState: .Normal)
                        }
                    }
                    if self.allFollowT {
                        self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next_c"), forState: .Normal)
                        self.allFollow.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    }
                    self.tblFriend.reloadData()
                }
            })
            break
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //move to user page
        let index = indexPath.row
        print(index)
        let friend = friendData[index]
        print(friend.name)
        print(friend.email)
        let vc = UserNativeViewController()
        vc.userEmail = friend.email
        self.navigationController!.pushViewController(vc, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "friendidentifier"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)as! SearchFriendTableViewCell
        
        let row = indexPath.row
        
        
        let friend = friendData[row]
        cell.friendname.text = friend.name
        print(friend.follow_yn)
        if friend.follow_yn == "Y" {
            cell.btnPlus.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            cell.followYN = true
        }else {
            cell.btnPlus.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
            cell.followYN = false
        }
        print("팔로우 상태는 ? : ",cell.followYN)
        cell.email = friend.email
        cell.index = indexPath.row
        cell.delegate = self
        cell.parent = self
        let s = (friend.profileUrl)! as String
        let firstImageUrl = (friend.firstImageUrl)! as String
        let secondImageUrl = (friend.secondImageUrl)! as String
        let thirdImageUrl = (friend.thirdImageUrl)! as String
        let fourthImageUrl = (friend.fourthImageUrl)! as String
        
        print(firstImageUrl)
        
        cell.profileImage.sd_setImageWithURL(NSURL(string: s as String))
        
        if(!firstImageUrl.isEmpty)
        {
            
            Alamofire.request(.GET, "http://gif.picpic.world/" + firstImageUrl, parameters: ["foo": "bar"]).response { request, response, data, error in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.firstimage.image = UIImage.gifWithData(data!) ?? UIImage()
                    })
                })
            }
        }
        
        if(!secondImageUrl.isEmpty)
        {
            Alamofire.request(.GET, "http://gif.picpic.world/" + secondImageUrl, parameters: ["foo": "bar"]).response { request, response, data, error in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.secondimage.image = UIImage.gifWithData(data!) ?? UIImage()
                    })
                })
            }
        }
        
        if(!thirdImageUrl.isEmpty)
        {
            Alamofire.request(.GET, "http://gif.picpic.world/" + thirdImageUrl, parameters: ["foo": "bar"]).response { request, response, data, error in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.thirdimage.image = UIImage.gifWithData(data!) ?? UIImage()
                    })
                })
            }
        }
        
        if(!fourthImageUrl.isEmpty)
        {
            Alamofire.request(.GET, "http://gif.picpic.world/" + fourthImageUrl, parameters: ["foo": "bar"]).response { request, response, data, error in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.fourthimage.image = UIImage.gifWithData(data!) ?? UIImage()
                    })
                })
            }
        }
        
        self.cells.append(cell)
        return cell;
        
    }
    
    func follow(email: String) {
        var type = ""
        if fbT {
            type = "F"
        }else if recomT {
            type = "R"
        }
        
        let message : JSON = ["myId":self.appdelegate.email,"email":[["email":email]],"type":type]
        self.appdelegate.doIt(402, message: message, callback: { (readData) -> () in
            print("follow   ",readData)
        })
    }
    
    func imageTouched(index: Int, secondIndex: Int) {
        let post = appdelegate.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
        self.appdelegate.controller.append(post)
        post.type = "post"
        post.email = self.appdelegate.email
        post.postId = self.posts[index][secondIndex]
        
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    
    @IBAction func allFollowTouched(sender: AnyObject) {
        if self.allFollowT {
            return
        }else {
            self.allFollow.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next_c"), forState: .Normal)
            self.allFollowT = true
        }
        
        var type = ""
        if fbT {
            type = "F"
        }else if recomT {
            type = "R"
        }
        var emailArr = [JSON]()
        for i in 0 ..< self.cells.count {
            emailArr.append(JSON(["email":self.cells[i].email]))
        }
        var message : JSON = ["myId":self.appdelegate.email,"email":[[]],"type":type]
        message["email"] = JSON(emailArr)
        print(message)
        self.appdelegate.doIt(402, message: message, callback: { (readData) -> () in
            print("follow   ",readData)
            if readData["follow"].stringValue == "Y" {
                for i in 0..<self.cells.count {
                    self.cells[i].btnPlus.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
                    
                }
            }else {
                for i in 0..<self.cells.count {
                    self.cells[i].btnPlus.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
                }
            }
        })
    }
    
    func allFollowCheck() {
        for i in 0 ..< self.friendData.count {
            if self.friendData[i].follow_yn == "N" {
                self.allFollowT = false
                self.allFollow.setBackgroundImage(UIImage(named: "btn_join_next"), forState: .Normal)
                self.allFollow.setTitleColor(Config.getInstance().color, forState: .Normal)
            }
        }
    }
    
    
}



