//
//  TagNativeReusableView.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 24..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class TagNativeReusableView: UICollectionReusableView {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func followTouched() {
    }
    
    @IBAction func followerListTouched() {
    }

    @IBAction func leftButtonTouched() {
        
        rightButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState:.Normal)

        leftButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        
        leftButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        leftButtonEnableView.backgroundColor = UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        rightButtonEnableView.backgroundColor = UIColor.whiteColor()

    }
    @IBAction func rightButtonTouched() {
        
        leftButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        rightButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        
        rightButtonEnableView.backgroundColor = UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        leftButtonEnableView.backgroundColor = UIColor.whiteColor()
        leftButton.layoutIfNeeded()
        rightButton.layoutIfNeeded()
    }

    
}
