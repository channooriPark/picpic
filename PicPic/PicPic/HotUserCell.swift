//
//  HotUserCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class HotUserCell: UICollectionViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var bodyViewHeightConstraints: NSLayoutConstraint!
    var delegate: FollowerViewCellProtocol?
    var cellIndexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.idLabel.text = nil
        self.profileImageView.image = nil
        self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        
        for view in self.bodyView.subviews
        {
            view.removeFromSuperview()
        }
    }

    @IBAction func followButtonTouched() {
        if self.followButton.imageForState(.Normal) == UIImage(named: "icon_find_plus")
        {
            self.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
        }
        else
        {
            self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        }
        
        self.delegate?.followTouched(self.cellIndexPath)
    }
}
