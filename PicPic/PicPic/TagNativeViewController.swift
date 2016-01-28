//
//  TagNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 23..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TagNativeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var statusbar: UIView!
    var tagName: String!
    var tagId: String!
    var infoDic: [String : AnyObject] = [:]
    var gifData = UIImage()
    var postInfos: Array<[String: AnyObject]> = []
    var postGifData: [String: UIImage] = [:] {
        didSet{
            if postInfos.count == postGifData.count
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                    self._hud.hide(true)
                    self.collectionView.infiniteScrollingView.stopAnimating()
                })
            }
        }
    }
    var currentPage = "1"
    var currentRange = "N"
    var currentString = ""
    var isWaterFall = true
    var _hud: MBProgressHUD = MBProgressHUD()
    
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
        self.collectionView.registerNib(UINib(nibName: "TagNativeReusableView", bundle: nil), forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "tagReusableView")
        // Do any additional setup after loading the view.
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 3
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        self.collectionView.collectionViewLayout = layout
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.addInfiniteScrollingWithActionHandler({ _ in self.refreshWithAdditionalPage(self.currentPage)})
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh()// 초기 refresh
    {
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let message : JSON = ["my_id":appdelegate.email,"tag_str":tagName]

        appdelegate.doIt(517, message: message, callback: {(json) in
            self.infoDic = json.dictionaryObject!
            Alamofire.request(.GET, "http://gif.picpic.world/" + (self.infoDic["url"]! as! String), parameters: ["foo": "bar"]).response { request, response, data, error in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.gifData = UIImage.gifWithData(data!)!
                })
            }
            
            
            let mes: JSON = ["my_id" :appdelegate.email,"type": "TT","user_id": "", "tag_id" : self.infoDic["tag_id"] as! String, "range" : "N", "str" : "", "page": "1"]
            
            appdelegate.doIt(507, message: mes, callback: {(json) in
                print(json)
                self.postInfos = json["data"].arrayObject as! Array<[String: AnyObject]>
                for (index, dic) in self.postInfos.enumerate()
                {
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
    
    func refreshWithoutProfileReload(range: String, str: String) // 인기, 최신, 검색
    {
        if !self.collectionView.infiniteScrollingView.enabled
        {
            self.collectionView.infiniteScrollingView.enabled = true
        }
        
        self._hud.show(true)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.postInfos = []
        self.postGifData = [:]
        
        currentRange = range
        currentString = str
        currentPage = "1"
        
        let mes: JSON = ["my_id" :appdelegate.email,"type": "TT","user_id": "", "tag_id" : self.infoDic["tag_id"] as! String, "range" : range, "str" : str, "page": "1"]
        
        appdelegate.doIt(507, message: mes, callback: {(json) in
            if json["data"].type == .Null
            {
                return
            }
            self.postInfos = json["data"].arrayObject as! Array<[String: AnyObject]>
            for (index, dic) in self.postInfos.enumerate()
            {
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
        
        let mes: JSON = ["my_id" :appdelegate.email,"type": "TT","user_id": "", "tag_id" : self.infoDic["tag_id"] as! String, "range" : self.currentRange, "str" : self.currentString, "page": "\(newPage)"]
        
        appdelegate.doIt(507, message: mes, callback: {(json) in
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
            for (index, dic) in newData.enumerate()
            {
                let str = dic["url"]! as! String
                let url = str.substringWithRange(str.startIndex ..< str.endIndex.advancedBy(-6)).stringByAppendingString("_1.gif")
                let currentCounts = self.postGifData.count
                Alamofire.request(.GET, "http://gif.picpic.world/" + url, parameters: ["foo": "bar"]).response { request, response, data, error in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.postGifData["\(index + currentCounts)"] = UIImage.gifWithData(data!) ?? UIImage()
                        
                    })
                }
            }
            
            
        })
    }
    

    
//collectionView delegate, datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postGifData.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath) as! TagCell
        
        cell.imageView.image = self.postGifData["\(indexPath.item)"]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(CHTCollectionElementKindSectionHeader, withReuseIdentifier: "tagReusableView", forIndexPath: indexPath) as! TagNativeReusableView
        
        if self.infoDic.count != 0
        {
            view.parent = self
            view.tagNameLabel.text = "#" + (self.infoDic["tag_name"]! as! String)
            view.tagNameLabel.sizeToFit()
            view.tagNameLabel.center.x = view.center.x
            
            view.postNumberLabel.text = String(self.infoDic["post_cnt"]! as! Int)
            view.followerNumberButton.setTitle("\(String(self.infoDic["follow_cnt"]! as! Int))", forState: .Normal)
            view.tagFounderLabel.text = "@" + (self.infoDic["id"]! as! String)
            view.tagId = (self.infoDic["tag_id"]! as! String)
            
            if self.infoDic["follow_yn"] as! String != "N"
            {
                view.followButton.setImage(UIImage(named: "follow_c"), forState: .Normal)
            }
            else
            {
                view.followButton.setImage(UIImage(named: "follow"), forState: .Normal)
            }
            
            view.gifImageView.image = self.gifData
        }
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.postGifData["\(indexPath.item)"]!.size
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
        return 270
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
    
    
    @IBAction func backTouched() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
