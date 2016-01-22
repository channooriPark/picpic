//
//  HomeFriendCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 23..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class HomeFriendCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var cellIndexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        self.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Disabled)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.profileImageView.image = nil
        self.nameLabel.text = nil

    }
    @IBAction func followTouched() {
        self.followButton.enabled = false
    }
}
