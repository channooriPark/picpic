//
//  TagNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 23..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagNativeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var statusbar: UIView!
    var tagName: String!
    var tagId: String!
    var infoDic: [String : AnyObject] = [:]
    var gifData = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusbar = UIView()
        self.statusbar.frame = UIApplication.sharedApplication().statusBarFrame
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerNib(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "tagCell")
        self.collectionView.registerNib(UINib(nibName: "TagNativeReusableView", bundle: nil), forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "tagReusableView")
        // Do any additional setup after loading the view.
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 3
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.LeftToRight
        self.collectionView.collectionViewLayout = layout
        
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh()
    {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let message : JSON = ["my_id":appdelegate.email,"tag_str":tagName]

        appdelegate.doIt(517, message: message, callback: {(json) in
            self.infoDic = json.dictionaryObject!

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let data = NSData(contentsOfURL: NSURL(string: "http://gif.picpic.world/" + (self.infoDic["url"]! as! String) )!)!
                self.gifData = UIImage.gifWithData(data)!
                dispatch_sync(dispatch_get_main_queue(), { self.collectionView.reloadData()})
            })
            
            let mes: JSON = ["my_id" : appdelegate.email, "tag_id" : self.infoDic["tag_id"] as! String, "page" : "1", "range" : "P", "count" : "20"]
            
            appdelegate.doIt(520, message: mes, callback: {(json) in
                print(json)
            })
        })
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(CHTCollectionElementKindSectionHeader, withReuseIdentifier: "tagReusableView", forIndexPath: indexPath) as! TagNativeReusableView
        
        if self.infoDic.count != 0
        {
            view.tagNameLabel.text = "#" + (self.infoDic["tag_name"]! as! String)
            view.tagNameLabel.sizeToFit()
            view.tagNameLabel.center.x = view.center.x
            
            view.postNumberLabel.text = String(self.infoDic["post_cnt"]! as! Int)
            view.followerNumberButton.titleLabel?.text = String(self.infoDic["follow_cnt"]! as! Int)
            view.tagFounderLabel.text = "@" + (self.infoDic["id"]! as! String)
            
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
        return CGSize(width: 100, height: 100 * (indexPath.item + 1))
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
        return 270
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        self.backButton.hidden = true
    }
    
    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        self.backButton.hidden = false
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
