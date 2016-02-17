//
//  MyFeedNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 3..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MyFeedNativeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, TagListCellDelegate {

    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
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
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !self.view.hidden
        {
            self.navigationController?.navigationBarHidden = true
        }

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
        
        self.collectionView.registerNib(UINib(nibName: "MyFeedNativeReusableView", bundle: nil), forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "myFeedReusableView")
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
        //self.refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh()// 초기 refresh
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let message : JSON = ["my_id":appdelegate.email,"user_id":appdelegate.email]
        
        appdelegate.doIt(406, message: message, callback: {(json) in
            self.infoDic = json.dictionaryObject!
            
            
            let mes: JSON = ["my_id" :appdelegate.email,"user_id": appdelegate.email, "range" : "N", "str" : "", "page": "1"]
            
            appdelegate.doIt(511, message: mes, callback: {(json) in
                print(json)
                if json["data"].type == .Null
                {
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                    self.collectionView.infiniteScrollingView.enabled = false
                    self.collectionView.reloadData()
                    return
                }
                
                self.postInfos = json["data"].arrayObject as! Array<[String: AnyObject]>
                self.collectionView.reloadData()
                self._hud.hide(true)
                self.collectionView.infiniteScrollingView.stopAnimating()

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
        
        let mes: JSON = ["my_id" :appdelegate.email,"user_id": appdelegate.email, "range" : "N", "str" : str, "page": "1"]
        
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
            self.collectionView.reloadData()
            self._hud.hide(true)
            self.collectionView.infiniteScrollingView.stopAnimating()

        })
    }
    
    func refreshWithAdditionalPage(currentPage: String)
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let newPage = Int(self.currentPage)! + 1
        
        let mes: JSON = ["my_id" :appdelegate.email,"user_id": appdelegate.email, "range" : "N", "str" : self.currentString, "page": "\(newPage)"]
        let code = self.isRepic ? 510 : 511
        
        appdelegate.doIt(code, message: mes, callback: {(json) in
            if json["data"].type == .Null || json["data"].stringValue == "null"
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
            self.collectionView.reloadData()
            self._hud.hide(true)
            self.collectionView.infiniteScrollingView.stopAnimating()

        })
    }
    
    func fire()
    {
        self.refresh()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postInfos.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
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
            cell.dateLabel.text =  Config.getInstance().uploadedDate(dic["date"] as! String) //intervalText
            
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
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(CHTCollectionElementKindSectionHeader, withReuseIdentifier: "myFeedReusableView", forIndexPath: indexPath) as! MyFeedNativeReusableView
        
        if self.infoDic.count != 0
        {
            let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            view.parent = self
            view.email = appdelegate.email
            view.idLabel.text = "@" + (self.infoDic["id"] as! String)
            view.idLabel.sizeToFit()
            view.idLabel.center.x = view.center.x
            
            view.postNumberLabel.text = String(self.infoDic["post_cnt"]! as! Int)
            view.followingNumberButton.setTitle("\(String(self.infoDic["follow_cnt"]! as! Int))", forState: .Normal)
            view.followerNumberButton.setTitle("\(String(self.infoDic["follower_cnt"]! as! Int))", forState: .Normal)
            
            let tags = self.infoDic["p_tag_1"] as! Array<[String : String]>
            view.firstTagName = tags.first!["tag_name"]! != "null" ? tags.first!["tag_name"]! : ""
            view.tagIdButton.setTitle("#" + view.firstTagName, forState: .Normal)
            view.tagCountButton.setTitle("+" + String(tags.count), forState: .Normal)
            view.tagIdButton.sizeToFit()
            
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
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.collectionView.contentOffset.y > 150 {
            self.settingButton.hidden = true
        }else {
            self.settingButton.hidden = false 
        }
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
    
    
    @IBAction func moreButtonTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moreother = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
        moreother.post_id = appdelegate.email
        
        self.addChildViewController(moreother)
        self.view.addSubview(moreother.view)
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
        fl.type = .Like
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
        moreother.post_id = self.postInfos[indexPath.item]["post_id"] as! String
        
        self.addChildViewController(moreother)
        self.view.addSubview(moreother.view)
    }
    
    @IBAction func settingButtonTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let setting = appdelegate.storyboard.instantiateViewControllerWithIdentifier("settingNav")as! UINavigationController
        self.navigationController?.presentViewController(setting, animated: true, completion: nil)
    }

    
    
    

}
