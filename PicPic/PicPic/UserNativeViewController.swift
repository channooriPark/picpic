//
//  UserNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 28..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class UserNativeViewController: SubViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, TagListCellDelegate {

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    var userEmail: String!
    var userData : JSON!
    
    var statusbar: UIView!
    var infoDic: [String : AnyObject] = [:]
    var gifData: UIImage?
    var postInfos: Array<[String: AnyObject]> = []
    var postGifData: [String: UIImage] = [:]
    var currentPage = "1"
    var isRepic = false
    var currentString = ""
    var isWaterFall = true
    var _hud: MBProgressHUD = MBProgressHUD()
    
//    let mes: JSON = ["my_id" :appdelegate.email,"type": "TT","user_id": self.userEmail, "range" : "N", "str" : "", "page": "1"]
//    appdelegate.doIt(511, message: mes, callback: {(json) in print(json)})
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusbar = UIView()
        self.statusbar.frame = UIApplication.sharedApplication().statusBarFrame
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)
        
        _hud.mode = MBProgressHUDModeIndeterminate
        _hud.center = self.view.center
        self.view.addSubview(_hud)
        _hud.hide(false)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "tagCell")
        self.collectionView.registerNib(UINib(nibName: "TagListCell", bundle: nil), forCellWithReuseIdentifier: "tagTimelineCell")
        
        self.collectionView.registerNib(UINib(nibName: "UserNativeReusableView", bundle: nil), forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "userReusableView")
        // Do any additional setup after loading the view.
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 3
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        self.collectionView.collectionViewLayout = layout
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.addInfiniteScrollingWithActionHandler({ _ in self.refreshWithAdditionalPage(self.currentPage)})
        self.refresh()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        
        self.collectionView.addGestureRecognizer(doubleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh()// 초기 refresh
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let message : JSON = ["my_id":appdelegate.email,"user_id":self.userEmail]
        
        appdelegate.doIt(406, message: message, callback: {(json) in
            
            self.infoDic = json.dictionaryObject!
            self.userData = json
            print("json data ",self.infoDic)
            
            if let string = json["withdraw_yn"].string {
                if string as! String == "Y" {
                    
                    //탈퇴사용자 alert
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                    self.collectionView.infiniteScrollingView.enabled = false
                    let alert = UIAlertController(title: nil, message: self.appdelegate.ment["toast_msg_not_exists_user"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: {_ in self.backButtonTouched()}))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
            }
            
            
            let mes: JSON = ["my_id" :appdelegate.email,"user_id": self.userEmail, "range" : "N", "str" : "", "page": "1"]
            
            appdelegate.doIt(511, message: mes, callback: {(json) in
                print(json)
                
                if json["data"].type == .Null || json["data"].rawValue.isKindOfClass(NSNull)
                {
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                    self.collectionView.infiniteScrollingView.enabled = false
                    self.collectionView.reloadData()
                    
                }
                guard let array = json["data"].arrayObject as? Array<[String: AnyObject]> else
                {
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                    self.collectionView.infiniteScrollingView.enabled = false
                    self.collectionView.reloadData()
                    return
                }
                self.postInfos = array
                self._hud.hide(true)
                for (index, dic) in self.postInfos.enumerate()
                {
                    if let string = dic["is_closed"]
                    {
                        if string as! String == "Y"
                        {
                            if let string = dic["follow_yn"] {
                                if string as! String == "N" {
                                    //사용자비공개 alert
                                    self._hud.hide(true)
                                    self.collectionView.infiniteScrollingView.stopAnimating()
                                    self.collectionView.infiniteScrollingView.enabled = false
                                    let alert = UIAlertController(title: nil, message: self.appdelegate.ment["toast_msg_is_closed_y"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: {_ in self.backButtonTouched()}))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                    }
                    self.collectionView.infiniteScrollingView.stopAnimating()
                    self.collectionView.reloadData()
                    let str = dic["url"]! as! String
                    let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                    
                    Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            self.postGifData["\(index)"] = UIImage.gifWithData(data!) ?? UIImage()
                            
                        })
                    }
                }
            })
        })
        
    }
    
    func refreshWithoutProfileReload(repic: Bool, str: String) // user, repic, 검색
    {
        if !self.collectionView.infiniteScrollingView.enabled
        {
            self.collectionView.infiniteScrollingView.enabled = true
        }
        
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.postInfos = []
        self.postGifData = [:]
        
        currentString = str
        currentPage = "1"
        isRepic = repic
        
        let mes: JSON = ["my_id" :appdelegate.email,"user_id": self.userEmail, "range" : "N", "str" : str, "page": "1"]
        
        let code = repic ? 510 : 511
        
        appdelegate.doIt(code, message: mes, callback: {(json) in
            if json["data"].type == .Null
            {
                self._hud.hide(true)
                self.collectionView.infiniteScrollingView.stopAnimating()
                self.collectionView.infiniteScrollingView.enabled = false
                self.collectionView.reloadData()
                return
            }
            
            self.postInfos = json["data"].arrayObject as! Array<[String: AnyObject]>
            self._hud.hide(true)
            
            for (index, dic) in self.postInfos.enumerate()
            {
                if let string = dic["is_closed"]
                {
                    if string as! String == "Y"
                    {
                        if let string = dic["follow_yn"] {
                            if string as! String == "N" {
                                //사용자비공개 alert
                                self._hud.hide(true)
                                self.collectionView.infiniteScrollingView.stopAnimating()
                                self.collectionView.infiniteScrollingView.enabled = false
                                let alert = UIAlertController(title: nil, message: self.appdelegate.ment["toast_msg_is_closed_y"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: self.appdelegate.ment["popup_confirm"].stringValue, style: UIAlertActionStyle.Default, handler: {_ in self.backButtonTouched()}))
                                self.presentViewController(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                }
                self.collectionView.infiniteScrollingView.stopAnimating()
                self.collectionView.reloadData()
                let str = dic["url"]! as! String
                let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                
                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.postGifData["\(index)"] = UIImage.gifWithData(data!) ?? UIImage()
                        
                    })
                }
            }
        })
    }
    
    func refreshWithAdditionalPage(currentPage: String)
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let newPage = Int(self.currentPage)! + 1
        
        let mes: JSON = ["my_id" :appdelegate.email,"user_id": self.userEmail, "range" : "N", "str" : self.currentString, "page": "\(newPage)"]
        let code = self.isRepic ? 510 : 511
        
        appdelegate.doIt(code, message: mes, callback: {(json) in
            if json["data"].type == .Null
            {
                self._hud.hide(true)
                self.collectionView.infiniteScrollingView.stopAnimating()
                self.collectionView.infiniteScrollingView.enabled = false
                self.collectionView.reloadData()
                return
            }
            let newData = json["data"].arrayObject as! Array<[String: AnyObject]>
            self.currentPage = "\(newPage)"
            self.postInfos.appendContentsOf(newData)
            self._hud.hide(true)
            self.collectionView.infiniteScrollingView.stopAnimating()
            self.collectionView.reloadData()
//            for (index, dic) in newData.enumerate()
//            {
//                let str = dic["url"]! as! String
//                let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
//                let currentCounts = self.postGifData.count
//                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                        self.postGifData["\(index + currentCounts)"] = UIImage.gifWithData(data!) ?? UIImage()
//                        
//                    })
//                }
//            }
            
            
        })
    }
    
    //collectionView delegate, datasource
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postInfos.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func doubleTapped(gesture: UITapGestureRecognizer)
    {
        if !self.isWaterFall
        {
            let point = gesture.locationInView(self.collectionView)
            guard let indexPath = self.collectionView.indexPathForItemAtPoint(point) else
            {
                return
            }
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! TagListCell
            
            cell.likeButtonTouched()
        }
        else
        {
            return
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let post = appdelegate.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
        appdelegate.controller.append(post)
        //            post.index = appdelegate.controller.count - 1
        post.type = "post"
        post.email = appdelegate.email
        post.postId = self.postInfos[indexPath.item]["post_id"] as! String
        
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.isWaterFall
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath) as! TagCell
            
            let dic = self.postInfos[indexPath.item]
            
            if self.postGifData["\(indexPath.item)"] == nil
            {
                let str = dic["url"]! as! String
                let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                
                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.postGifData["\(indexPath.item)"] = UIImage.gifWithData(data!) ?? UIImage()
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = self.postGifData["\(indexPath.item)"]
                        })
                    })
                }
            }
            else
            {
                cell.imageView.image = self.postGifData["\(indexPath.item)"]
            }
            cell.cellIndexPath = indexPath
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("tagTimelineCell", forIndexPath: indexPath) as! TagListCell
            let dic = self.postInfos[indexPath.item]
            
            if self.postGifData["\(indexPath.item)"] == nil
            {
                let str = dic["url"]! as! String
                let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                
                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.postGifData["\(indexPath.item)"] = UIImage.gifWithData(data!) ?? UIImage()
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.gifImageView.image = self.postGifData["\(indexPath.item)"]
                        })
                    })
                }
            }
            else
            {
                cell.gifImageView.image = self.postGifData["\(indexPath.item)"]
            }
            
            cell.cellIndexPath = indexPath
            cell.delegate = self
            
            cell.userIdLabel.text = (dic["id"] as? String)
            cell.dateLabel.text = Config.getInstance().uploadedDate(dic["date"]as!String) //intervalText
            
            let label = ActiveLabel()
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.font = UIFont.systemFontOfSize(15)
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.text = (dic["body"] as! String)
            
            label.handleHashtagTap({(string) in
                let vc = TagNativeViewController()
                vc.tagName = string.substringFromIndex(string.startIndex.advancedBy(1))
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            label.handleMentionTap({(string) in
                let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let msg = JSON(["my_id" : appdelegate.email, "user_id" : string.substringFromIndex(string.startIndex.advancedBy(1))])
                appdelegate.doIt(518, message: msg, callback: {(json) in
                    let vc = UserNativeViewController()
                    
                    vc.userEmail = json["email"].stringValue
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            })
            
            label.frame = CGRectMake(0, 0, cell.bodyView.frame.width, CGFloat(20 * self.rowsNeededForText(label.text!)))
            cell.bodyViewHeightConstraint.constant = CGFloat(20 * self.rowsNeededForText(label.text!))
            cell.bodyView.addSubview(label)
            
            cell.playCountLabel.text = String(dic["play_cnt"] as! Int)
            cell.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (dic["profile_picture"] as! String)))
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.profileImageView.layer.masksToBounds = true
            
            cell.lastCommentImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.lastCommentImageView.layer.masksToBounds = true
            
            cell.likeCountButton.setTitle(String(format: "\(self.appdelegate.ment["like"].stringValue) %d\(self.appdelegate.ment["timeline_count"].stringValue)", dic["like_cnt"] as! Int), forState: .Normal)
            cell.commentCountButton.setTitle(String(format: "\(self.appdelegate.ment["comment"].stringValue) %d\(self.appdelegate.ment["timeline_count"].stringValue)", dic["com_cnt"] as! Int), forState: .Normal)
            
            if (dic["like_yn"] as! String) != "N"
            {
                cell.likeButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
            }
            
            if (dic["follow_yn"] as! String) != "N"
            {
                cell.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }//re
            
            if (dic["last_com"] as! [String : String])["body"] != "null"
            {
                cell.lastCommentImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (dic["last_com"] as! [String : String])["profile_picture"]!))
                cell.lastCommentTitleLabel.text = (dic["last_com"] as! [String : String])["id"]
                cell.lastCommentTextLabel.text = (dic["last_com"] as! [String : String])["body"]
                
                cell.lastCommentTitleLabel.sizeToFit()
                cell.lastCommentTextLabel.sizeToFit()
            }
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(CHTCollectionElementKindSectionHeader, withReuseIdentifier: "userReusableView", forIndexPath: indexPath) as! UserNativeReusableView
        
        if self.infoDic.count != 0
        {
            view.parent = self
            view.email = self.userEmail
            view.idLabel.text = "@" + (self.infoDic["id"] as! String)
            view.idLabel.sizeToFit()
            view.idLabel.center.x = view.center.x
            
            view.postNumberLabel.text = String(self.infoDic["post_cnt"]! as! Int)
            view.followingNumberButton.setTitle("\(String(self.infoDic["follow_cnt"]! as! Int))", forState: .Normal)
            view.followerNumberButton.setTitle("\(String(self.infoDic["follower_cnt"]! as! Int))", forState: .Normal)
            
            let tags = self.infoDic["p_tag_1"] as! Array<[String : String]>
            view.firstTagName = tags.first!["tag_name"]! != "null" ? tags.first!["tag_name"]! : ""
            view.tagIdButton.setTitle("#" + view.firstTagName, forState: .Normal)
            view.tagIdButton.sizeToFit()
            view.tagCountButton.setTitle("+" + String(tags.count), forState: .Normal)
//            view.tagFounderLabel.text = "@" + (self.infoDic["id"]! as! String)
//            view.tagId = (self.infoDic["tag_id"]! as! String)
            
            if self.infoDic["follow_yn"] as! String != "N"
            {
                view.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            }
            else
            {
                view.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
            }
            
            view.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (infoDic["profile_picture"] as! String)))
            view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width / 2
            view.profileImageView.layer.masksToBounds = true
            
            view.gifImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (infoDic["profile_picture"] as! String)))
            //view.gifImageView.image = self.gifData
        }
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let dic = self.postInfos[indexPath.item]
        let imgSize =  CGSizeMake(dic["width1"] as! CGFloat, dic["height1"] as! CGFloat)
        
        //18, 45, 21, 50
        let body = dic["body"] as! String
        let ratio = imgSize.width / self.view.bounds.width
        
        let cnt = body.componentsSeparatedByString("\n").count - 1
        
        
        
        let height = imgSize.height + ((182 + 18 * CGFloat(cnt)) * ratio)
        
        return (self.isWaterFall) ? imgSize : CGSizeMake(imgSize.width, height)
    }
    
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(3, 0, 3, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderInSection section: NSInteger) -> CGFloat {
        if infoDic.count == 0
        {
            return 0
        }
        return 300
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        self.backButton.hidden = true
    }
    
    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        self.backButton.hidden = false
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func rowsNeededForText(txt: String) -> Int
    {
        var cnt = 1
        
        cnt += txt.componentsSeparatedByString("\n").count
        
        for string in txt.componentsSeparatedByString("\n")
        {
            cnt  += (string.characters.count / 36)
        }
        
        return cnt
    }
    
    @IBAction func backButtonTouched() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func moreButtonTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
        moreother.email = self.userEmail
        
        self.addChildViewController(moreother)
        self.view.addSubview(moreother.view)
    }
    
    
    @IBAction func userShareButtonTouched(sender: AnyObject) {
        let share = self.appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageShareViewController")as! UserPageShareViewController
        share.userId = self.userData["id"].stringValue
        share.profileURL = self.userData["profile_picture"].stringValue
        self.addChildViewController(share)
        self.view.addSubview(share.view)
    }
    
    
    
    
    //TagListCellDelegate
    func userViewTouched(indexPath: NSIndexPath)
    {
        let vc = UserNativeViewController()
        vc.userEmail = self.postInfos[indexPath.item]["email"]! as! String
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func followButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.postInfos[indexPath.item]["follow_yn"] as! String == "N"
        {
            self.postInfos[indexPath.item]["follow_yn"] = "Y"
            self.infoDic["follow_yn"] = "Y"
        }
        else
        {
            self.postInfos[indexPath.item]["follow_yn"] = "N"
            self.infoDic["follow_yn"] = "N"
        }
        
        let type : String!
        let email = self.postInfos[indexPath.item]["email"]! as! String
        
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
            self.refreshWithoutProfileReload(self.isRepic, str: self.currentString)
        })
    }
    
    func likeCountButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fl = FollowNativeViewController()
        fl.ftype = .Like
        fl.email = appdelegate.email
        fl.tagId = self.postInfos[indexPath.item]["post_id"] as! String
        
        self.navigationController?.pushViewController(fl, animated: true)
    }
    func likeButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let message : JSON = ["post_reply_id" : self.postInfos[indexPath.item]["post_id"] as! String, "click_id" : appdelegate.email, "like_form": "P"]
        
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! TagListCell
        
        if cell.likeButton.imageForState(.Normal) == UIImage(named: "icon_timeline_like")
        {
            cell.heartImage.fadeOut(completion: { (finished: Bool) -> Void in
                cell.heartImage.fadeIn(completion: { (finished: Bool) -> Void in
                    cell.heartImage.fadeOut()
                })
            })
            cell.likeButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
        }
        else
        {
            cell.likeButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
        }
        
        if self.postInfos[indexPath.item]["like_yn"] as! String == "N"
        {
            self.postInfos[indexPath.item]["like_yn"] = "Y"
            self.postInfos[indexPath.item]["like_cnt"] = (self.postInfos[indexPath.item]["like_cnt"] as! Int) + 1
            appdelegate.doIt(302, message: message, callback: { _ in
                cell.likeCountButton.setTitle(String(format: "\(self.appdelegate.ment["like"].stringValue) %d\(self.appdelegate.ment["timeline_count"].stringValue)", self.postInfos[indexPath.item]["like_cnt"] as! Int), forState: .Normal)
            })
        }
        else
        {
            self.postInfos[indexPath.item]["like_yn"] = "N"
            self.postInfos[indexPath.item]["like_cnt"] = (self.postInfos[indexPath.item]["like_cnt"] as! Int) - 1
            appdelegate.doIt(303, message: message, callback: { _ in
                cell.likeCountButton.setTitle(String(format: "\(self.appdelegate.ment["like"].stringValue) %d\(self.appdelegate.ment["timeline_count"].stringValue)", self.postInfos[indexPath.item]["like_cnt"] as! Int), forState: .Normal)
            })
        }
    }
    func commentButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let comment = appdelegate.storyboard.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
        comment.type = "comment"
        
        comment.my_id = appdelegate.email
        comment.post_id = self.postInfos[indexPath.item]["post_id"] as! String
        comment.postEmail = self.postInfos[indexPath.item]["email"] as! String
        
        self.navigationController?.pushViewController(comment, animated: true)
    }
    func shareButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let message = JSON(["my_id" : appdelegate.email, "post_id" : self.postInfos[indexPath.item]["post_id"] as! String])
        
        appdelegate.doIt(504, message: message, callback: {(json) in
            
            let share = appdelegate.storyboard.instantiateViewControllerWithIdentifier("ShareViewController")as! ShareViewController
            share.post_id = json.dictionaryObject!["post_id"] as! String
            share.url = json.dictionaryObject!["url"] as! String
            share.repicState = (json.dictionaryObject!["repic_yn"] as! String == "N") ? false : true
            
            self.addChildViewController(share)
            self.view.addSubview(share.view)
        })
    }
    func moreButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
        moreother.email = self.postInfos[indexPath.item]["email"] as! String
        
        self.addChildViewController(moreother)
        self.view.addSubview(moreother.view)
    }
}
