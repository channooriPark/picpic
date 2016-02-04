//
//  FollowerViewCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 2..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class FollowerViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var delegate: FollowerViewCellProtocol?
    var cellIndexPath: NSIndexPath!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.idLabel.text = nil
        followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func followButtonTouched() {
        self.delegate?.followTouched(self.cellIndexPath)
    }
}

protocol FollowerViewCellProtocol
{
    func followTouched(indexPath: NSIndexPath)
}
