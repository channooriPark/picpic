//
//  MyFeedNativeReusableView.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 3..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyFeedNativeReusableView: UICollectionReusableView, UISearchBarDelegate {
    
    @IBOutlet weak var imageCoverView: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var tagIdButton: UIButton!

    @IBOutlet weak var tagCountButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButtonEnableView: UIView!
    @IBOutlet weak var rightButtonEnableView: UIView!
    
    
    @IBOutlet weak var postNumberLabel: UILabel!
    
    @IBOutlet weak var followerNumberButton: UIButton!
    @IBOutlet weak var followingNumberButton: UIButton!
    
    
    @IBOutlet weak var listViewButton: UIButton!
    @IBOutlet weak var waterfallViewButton: UIButton!
    
    var email: String!
    var parent: MyFeedNativeViewController!
    var firstTagName: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchBar.enablesReturnKeyAutomatically = false
        self.bringSubviewToFront(self.leftButton)
        self.bringSubviewToFront(self.rightButton)
    }
    
    
    
    
    
    @IBAction func profileEditTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let edit = appdelegate.storyboard.instantiateViewControllerWithIdentifier("MyfeedEditProfileNav")as! UINavigationController
        self.parent.navigationController?.presentViewController(edit, animated: true, completion: nil)
    }
    
    @IBAction func tagTouched() {
        if self.firstTagName == ""
        {
            return
        }
        let vc = TagNativeViewController()
        vc.tagName = self.firstTagName
        self.parent.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followerListTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fl = FollowNativeViewController()
        fl.type = .Follower
        fl.email = appdelegate.email
        fl.tagId = self.email
        
        self.parent.navigationController?.pushViewController(fl, animated: true)
    }
    @IBAction func followingListTouched() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fl = FollowNativeViewController()
        fl.type = .Following
        fl.email = appdelegate.email
        fl.tagId = self.email
        
        self.parent.navigationController?.pushViewController(fl, animated: true)
    }
    
    @IBAction func leftButtonTouched() {
        
        rightButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState:.Normal)
        
        leftButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        
        leftButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        leftButtonEnableView.backgroundColor = Config.getInstance().color //UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        rightButtonEnableView.backgroundColor = UIColor.whiteColor()
        
        let str = self.searchBar.text ?? ""
        self.parent.refreshWithoutProfileReload(false, str: str)
    }
    @IBAction func rightButtonTouched() {
        
        leftButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        rightButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        rightButtonEnableView.backgroundColor = Config.getInstance().color //UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        leftButtonEnableView.backgroundColor = UIColor.whiteColor()
        
        let str = self.searchBar.text ?? ""
        self.parent.refreshWithoutProfileReload(true, str: str)
    }
    
    @IBAction func listViewButtonTouched() {
        self.listViewButton.setImage(UIImage(named: "icon_my_list_c"), forState: .Normal)
        self.waterfallViewButton.setImage(UIImage(named:"icon_my_gather"), forState: .Normal)
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 1
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.ShortestFirst
        self.parent.isWaterFall = false
        self.parent.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
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
        self.parent.refreshWithoutProfileReload(self.parent.isRepic, str: str)
    }
}
