//
//  FollowNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 1..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

enum FollowType
{
    case Follower, Following, Like, TagFollower
}

class FollowNativeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowerViewCellProtocol {
    
    var email: String!
    var tagId: String!
    var type: FollowType!
    var datas: Array<[String: String]> = []
    var currentPage = "1"
    var _hud: MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var tableView: UITableView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        //좋아하는사람 팔로우한사람 팔로잉한사람
        if self.type == .Like
        {
            self.navigationItem.title = self.appdelegate.ment["timeline_like_user"].stringValue
        }
        else if self.type == .Following
        {
            self.navigationItem.title = self.appdelegate.ment["follow_he_list"].stringValue
        }
        else
        {
            self.navigationItem.title = self.appdelegate.ment["follow_me_list"].stringValue
        }
        
        self.navigationItem.backBarButtonItem = nil
        let barButton = UIBarButtonItem()
        let button = UIButton(frame: CGRectMake(0, 0, 30, 30))
        button.setImage(UIImage(named:"back_white"), forState: .Normal)
        button.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        barButton.customView = button
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _hud.mode = MBProgressHUDModeIndeterminate
        _hud.center = self.view.center
        self.view.addSubview(_hud)
        _hud.hide(false)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "FollowerViewCell", bundle: nil), forCellReuseIdentifier: "followerCell")
        self.tableView.addInfiniteScrollingWithActionHandler({_ in self.refreshWithAdditionalPage()})
        
        self.refresh()
        // Do any additional setup after loading the view.
    }
    
    func refresh()
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch self.type!
        {
        case .Follower:
            let message = JSON(["my_id" : self.email, "user_id" : self.tagId, "page" : "1"])
            appdelegate.doIt(408, message: message, callback: {(json) in
                if json["data"].type == .Null {return}
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas = json["data"].arrayObject as! Array<[String: String]>
                    self.tableView.reloadData()
                }
            })
        case .Following:
            let message = JSON(["my_id" : self.email, "user_id" : self.tagId, "page" : "1"])
            appdelegate.doIt(404, message: message, callback: {(json) in
                if json["data"].type == .Null {return}
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas = json["data"].arrayObject as! Array<[String: String]>
                    self.tableView.reloadData()
                }
            })
        case .Like:
            let message = JSON(["my_id" : self.email, "post_reply_id" : self.tagId, "page" : "1"])
            appdelegate.doIt(320, message: message, callback: {(json) in
                if json["data"].type == .Null {return}
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas = json["data"].arrayObject as! Array<[String: String]>
                    self.tableView.reloadData()
                }
            })
        case .TagFollower:
            let message = JSON(["my_id" : self.email, "tag_id" : self.tagId, "page" : "1"])
            appdelegate.doIt(409, message: message, callback: {(json) in
                if json["data"].type == .Null {return}
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas = json["data"].arrayObject as! Array<[String: String]>
                    self.tableView.reloadData()
                }
            })
            
        }
    }
    
    func refreshWithAdditionalPage()
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let newPage = Int(self.currentPage)! + 1
        
        switch self.type!
        {
        case .Follower:
            let message = JSON(["my_id" : self.email, "user_id" : self.tagId, "page" : "\(newPage)"])
            appdelegate.doIt(408, message: message, callback: {(json) in
                if json["data"].type == .Null {
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.tableView.infiniteScrollingView.enabled = false
                    self.tableView.reloadData()
                    return
                }
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas.appendContentsOf(json["data"].arrayObject as! Array<[String: String]>)
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.currentPage = "\(newPage)"
                    self.tableView.reloadData()
                }
            })
        case .Following:
            let message = JSON(["my_id" : self.email, "user_id" : self.tagId, "page" : "\(newPage)"])
            appdelegate.doIt(404, message: message, callback: {(json) in
                if json["data"].type == .Null {
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.tableView.infiniteScrollingView.enabled = false
                    self.tableView.reloadData()
                    return
                }
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas.appendContentsOf(json["data"].arrayObject as! Array<[String: String]>)
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.currentPage = "\(newPage)"
                    self.tableView.reloadData()
                }
            })
        case .Like:
            let message = JSON(["my_id" : self.email, "post_reply_id" : self.tagId, "page" : "\(newPage)"])
            appdelegate.doIt(320, message: message, callback: {(json) in
                if json["data"].type == .Null {
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.tableView.infiniteScrollingView.enabled = false
                    self.tableView.reloadData()
                    return
                }
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas.appendContentsOf(json["data"].arrayObject as! Array<[String: String]>)
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.currentPage = "\(newPage)"
                    self.tableView.reloadData()
                }
            })
        case .TagFollower:
            let message = JSON(["my_id" : self.email, "tag_id" : self.tagId, "page" : "\(newPage)"])
            appdelegate.doIt(409, message: message, callback: {(json) in
                if json["data"].type == .Null {
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.tableView.infiniteScrollingView.enabled = false
                    self.tableView.reloadData()
                    return
                }
                if (json["data"].arrayObject!.first as! [String: String])["email"] != "null"
                {
                    self.datas.appendContentsOf(json["data"].arrayObject as! Array<[String: String]>)
                    self._hud.hide(true)
                    self.tableView.infiniteScrollingView.stopAnimating()
                    self.currentPage = "\(newPage)"
                    self.tableView.reloadData()
                }
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back()
    {
        var count = (self.navigationController?.viewControllers.count)!-2
        if count < 0 {
            count = 0
        }
        let a = self.navigationController?.viewControllers[count] as! SubViewController
        
        if a.type == "post" {
            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
            post.postImage.enterForeground()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("followerCell") as! FollowerViewCell
        let dic = self.datas[indexPath.row]
        cell.delegate = self
        cell.cellIndexPath = indexPath
        
        if self.type == .Like
        {
            cell.profileImageView.sd_setImageWithURL(NSURL(string:"http://gif.picpic.world/" + dic["profile_picture"]!)!)
        }
        else
        {
            cell.profileImageView.sd_setImageWithURL(NSURL(string:"http://gif.picpic.world/" + dic["url"]!)!)
        }
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
        cell.profileImageView.layer.masksToBounds = true
        
        cell.idLabel.text = dic["id"]!
        cell.idLabel.sizeToFit()
        
        if dic["follow_yn"]! != "N"
        {
            cell.followButton.setImage(UIImage(named:"icon_find_plus_c"), forState: .Normal)
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        print(datas[indexPath.row])
        let vc = UserNativeViewController()
        vc.userEmail = self.datas[indexPath.item]["email"]! 
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func followTouched(indexPath: NSIndexPath) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.datas[indexPath.item]["follow_yn"]  == "N"
        {
            self.datas[indexPath.item]["follow_yn"] = "Y"
        }
        else
        {
            self.datas[indexPath.item]["follow_yn"] = "N"
        }
        
        let type : String!
        let email = self.datas[indexPath.item]["email"]!
        
        if appdelegate.userData["register_form"].string == "10001" {
            type = "N"
        }else if appdelegate.userData["register_form"].string == "10002" {
            type = "F"
        }else if appdelegate.userData["register_form"].string == "10003" {
            type = "G"
        }else {
            type = "R"
        }
        
        let message : JSON = ["myId":appdelegate.email,"email":[["email" : email]],"type":type]
        appdelegate.doIt(402, message: message, callback: {(json) in
            self.tableView.reloadData()
        })
    }
}
