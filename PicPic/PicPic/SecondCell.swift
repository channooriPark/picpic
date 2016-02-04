//
//  SecondCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 4..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SecondCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var bodyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func likeButtonTouched() {
    }
    @IBAction func commentButtonTouched() {
    }
    @IBAction func shareButtonTouched() {
    }
    
}
