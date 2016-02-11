//
//  SearchUserCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var cellIndexPath: NSIndexPath!
    var delegate: FollowerViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.idLabel.text = nil
        self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
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
        
        delegate?.followTouched(self.cellIndexPath)
    }
    
}
