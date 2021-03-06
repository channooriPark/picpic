//
//  SecondCategoryViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 11..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SecondCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, TagListCellDelegate {

    var category: String!
    var categoryNum: String!
    var _hud: MBProgressHUD = MBProgressHUD()
    var currentPage = "1"
    var postInfos: Array<[String: AnyObject]> = []
    var postGifData: [String: UIImage] = [:]
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.title = category
        
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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerNib(UINib(nibName: "SecondCell", bundle: nil), forCellWithReuseIdentifier: "secondCell")
        self.collectionView.registerNib(UINib(nibName: "SecondCategoryCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        
        _hud.mode = MBProgressHUDModeIndeterminate
        _hud.center = self.view.center
        self.view.addSubview(_hud)
        _hud.hide(false)
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        layout.columnCount = 3
        self.collectionView.collectionViewLayout = layout
        // Do any additional setup after loading the view.
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.addInfiniteScrollingWithActionHandler({ _ in self.refreshWithAdditionalPage(self.currentPage)})
        self.refresh()
        // Do any additional setup after loading the view.
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        
        self.collectionView.addGestureRecognizer(doubleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func refresh()
    {
        if !self.collectionView.infiniteScrollingView.enabled
        {
            self.collectionView.infiniteScrollingView.enabled = true
        }
        
        self._hud.show(true)
        self.postInfos = []
        self.postGifData = [:]
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        currentPage = "1"
        
        let mes = JSON(["my_id" : appdelegate.email, "page" : "1", "category_num" : self.categoryNum])

        appdelegate.doIt(522, message: mes, callback: {(json) in
            self.postInfos = json["data"].arrayObject! as! [[String: AnyObject]]
            self.collectionView.reloadData()
            self._hud.hide(true)
        })
    }
    
    func refreshWithAdditionalPage(currentPage: String)
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let newPage = Int(self.currentPage)! + 1
        
        let mes: JSON = JSON(["my_id" : appdelegate.email, "page" : "\(newPage)", "category_num" : self.categoryNum])
        
        appdelegate.doIt(522, message: mes, callback: {(json) in
            if json["data"].type == .Null
            {
                self._hud.hide(true)
                self.collectionView.infiniteScrollingView.stopAnimating()
                self.collectionView.infiniteScrollingView.enabled = false
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
 
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func doubleTapped(gesture: UITapGestureRecognizer)
    {
        
        let point = gesture.locationInView(self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItemAtPoint(point) else
        {
            return
        }
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! SecondCell
            
        cell.likeButtonTouched()
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
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("secondCell", forIndexPath: indexPath) as! SecondCell
        
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
        
        let dateFormatter =  NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let date = dateFormatter.dateFromString(dic["date"] as! String)
        let interval = NSDate().timeIntervalSinceDate(date!)
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let intervalText = (interval / 3600 < 12) ? String(format: "%d시간전", Int(interval / 3600)) : dateFormatter.stringFromDate(date!)
        
        
        cell.idLabel.text = (dic["id"] as? String)
        cell.dateLabel.text = Config.getInstance().uploadedDate(dic["date"]as! String)//intervalText
        cell.dateLabel.sizeToFit()
        
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.lineSpacing = 4
        label.font = UIFont.systemFontOfSize(11)
        
        label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
        label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        label.text = (dic["body"] as! String)
        
        label.handleHashtagTap({(string) in
            let vc = TagNativeViewController()
            vc.tagName = string.substringFromIndex(string.startIndex.advancedBy(1))
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        label.frame = CGRectMake(4, 2, cell.bodyView.frame.width, CGFloat(12 * self.rowsNeededForText(label.text!)))
        cell.bodyViewHeightConstraint.constant = CGFloat(12 * self.rowsNeededForText(label.text!))
        cell.bodyView.addSubview(label)
        
        cell.playCountLabel.text = String(dic["play_cnt"] as! Int)
        cell.playCountLabel.sizeToFit()
        cell.profileImageView.sd_setImageWithURL(NSURL(string: "http://gif.picpic.world/" + (dic["profile_picture"] as! String)))
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
        cell.profileImageView.layer.masksToBounds = true
        
        cell.likeCountLabel.text = String(format: "%d", dic["like_cnt"] as! Int)
        cell.commentCountLabel.text = String(format: "%d", dic["com_cnt"] as! Int)
        
        if (dic["like_yn"] as! String) != "N"
        {
            cell.likeButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
        }
        
        if (dic["follow_yn"] as! String) != "N"
        {
            cell.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
        }
//        cell.followButton.hidden = true
        
        cell.layer.cornerRadius = 3.0
        cell.layer.masksToBounds = true
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postInfos.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        let dic = self.postInfos[indexPath.item]
        let width = dic["width1"] as! CGFloat
        var height = dic["height1"] as! CGFloat
            
        let body = dic["body"] as! String
        let ratio = width / 240
            
        let cnt = body.componentsSeparatedByString("\n").count - 1
            
            
            
        height += ((148 + 12 * CGFloat(cnt)) * ratio)
            
        return CGSizeMake(width, height)
        
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 0, 4, 0)
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
        }
        else
        {
            self.postInfos[indexPath.item]["follow_yn"] = "N"
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
            self.refresh()
        })
    }
    
    func likeCountButtonTouched(indexPath: NSIndexPath)
    {
        
    }
    
    func likeButtonTouched(indexPath: NSIndexPath)
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let message : JSON = ["post_reply_id" : self.postInfos[indexPath.item]["post_id"] as! String, "click_id" : appdelegate.email, "like_form": "P"]
        
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! SecondCell
        
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
                cell.likeCountLabel.text = "\(self.postInfos[indexPath.item]["like_cnt"] as! Int)"
            })
        }
        else
        {
            self.postInfos[indexPath.item]["like_yn"] = "N"
            self.postInfos[indexPath.item]["like_cnt"] = (self.postInfos[indexPath.item]["like_cnt"] as! Int) - 1
            appdelegate.doIt(303, message: message, callback: { _ in
                cell.likeCountLabel.text = "\(self.postInfos[indexPath.item]["like_cnt"] as! Int)"
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
        
    }

}
