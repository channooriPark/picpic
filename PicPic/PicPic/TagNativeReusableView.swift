//
//  TagNativeReusableView.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 24..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagNativeReusableView: UICollectionReusableView, UISearchBarDelegate {

    @IBOutlet weak var imageCoverView: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButtonEnableView: UIView!
    @IBOutlet weak var rightButtonEnableView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var postNumberLabel: UILabel!

    @IBOutlet weak var followerNumberButton: UIButton!
    @IBOutlet weak var tagFounderLabel: UILabel!
    
    @IBOutlet weak var listViewButton: UIButton!
    @IBOutlet weak var waterfallViewButton: UIButton!
    
    var tagId: String!
    var parent: TagNativeViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchBar.enablesReturnKeyAutomatically = false
        self.bringSubviewToFront(self.leftButton)
        self.bringSubviewToFront(self.rightButton)

    }
    

    @IBAction func followTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.followButton.imageForState(.Normal) == UIImage(named: "follow")
        {
            followButton.setImage(UIImage(named: "follow_c"), forState: .Normal)
        }
        else
        {
            followButton.setImage(UIImage(named: "follow"), forState: .Normal)
        }
        let message : JSON = ["myId":appdelegate.email,"tag_id":self.tagId]

        appdelegate.doIt(403, message: message, callback: { (readData) -> () in

            if (readData.dictionaryObject!["follow"] as! String == "Y")
            {
                let newTitle = Int(self.followerNumberButton.titleForState(.Normal)!)! + 1
                self.followerNumberButton.setTitle("\(newTitle)", forState: .Normal)
            }
            else
            {
                let newTitle = Int(self.followerNumberButton.titleForState(.Normal)!)! - 1
                self.followerNumberButton.setTitle("\(newTitle)", forState: .Normal)
            }
        })
    }
    
    @IBAction func followerListTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fl = FollowNativeViewController()
        fl.type = .TagFollower
        fl.email = appdelegate.email
        fl.tagId = self.tagId
        
        self.parent.navigationController?.pushViewController(fl, animated: true)
    }

    @IBAction func leftButtonTouched() {
        
        rightButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState:.Normal)

        leftButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        
        leftButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        leftButtonEnableView.backgroundColor = UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        rightButtonEnableView.backgroundColor = UIColor.whiteColor()
        
        let str = self.searchBar.text ?? ""
        self.parent.refreshWithoutProfileReload("N", str: str)
    }
    @IBAction func rightButtonTouched() {
        
        leftButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        rightButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        rightButtonEnableView.backgroundColor = UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        leftButtonEnableView.backgroundColor = UIColor.whiteColor()
        
        let str = self.searchBar.text ?? ""
        self.parent.refreshWithoutProfileReload("P", str: str)
    }

    @IBAction func listViewButtonTouched() {
        self.listViewButton.setImage(UIImage(named: "icon_my_list_c"), forState: .Normal)
        self.waterfallViewButton.setImage(UIImage(named:"icon_my_gather"), forState: .Normal)
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 1
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        self.parent.isWaterFall = false
        self.parent.collectionView.collectionViewLayout = layout
        self.parent.collectionView.reloadData()
    }
    @IBAction func waterFallViewButtonTouched() {
        self.listViewButton.setImage(UIImage(named: "icon_my_list"), forState: .Normal)
        self.waterfallViewButton.setImage(UIImage(named:"icon_my_gather_c"), forState: .Normal)
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 3
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        self.parent.isWaterFall = true
        self.parent.collectionView.collectionViewLayout = layout
        self.parent.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let str = self.searchBar.text ?? ""
        self.parent.refreshWithoutProfileReload(self.parent.currentRange, str: str)
    }
    
}
