//
//  SecondCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 4..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SecondCell: UICollectionViewCell {

    @IBOutlet weak var userView: UIView!
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
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var heartImage: UIImageView!
    var cellIndexPath: NSIndexPath!
    var delegate: TagListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "userViewTouched:")
        self.userView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        self.idLabel.text = nil
        self.dateLabel.text = nil
        self.playCountLabel.text = nil
        self.gifImageView.image = UIImage(named: "non_interest")
        self.heartImage.image = UIImage(named: "heart")
        
        for view in bodyView.subviews
        {
            view.removeFromSuperview()
        }
        
        self.likeButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
        
        self.likeCountLabel.text = "0"
        self.commentCountLabel.text = "0"
    }
    func userViewTouched(sender: AnyObject) {
        self.delegate?.userViewTouched(self.cellIndexPath)
    }

    @IBAction func followButtonTouched() {
        self.delegate?.followButtonTouched(self.cellIndexPath)
        if self.followButton.imageForState(.Normal) == UIImage(named: "icon_find_plus")
        {
            self.followButton.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
        }
        else
        {
            self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        }
        self.followButton.layoutIfNeeded()
    }
    @IBAction func likeButtonTouched() {
        self.delegate?.likeButtonTouched(self.cellIndexPath)
        if self.likeButton.imageForState(.Normal) == UIImage(named: "icon_timeline_like")
        {
            self.heartImage.fadeOut(completion: { (finished: Bool) -> Void in
                self.heartImage.fadeIn(completion: { (finished: Bool) -> Void in
                    self.heartImage.fadeOut()
                })
            })
            self.likeButton.setImage(UIImage(named: "icon_timeline_like_c"), forState: .Normal)
        }
        else
        {
            self.likeButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
        }
    }
    @IBAction func commentButtonTouched() {
        self.delegate?.commentButtonTouched(self.cellIndexPath)
    }
    @IBAction func shareButtonTouched() {
        self.delegate?.shareButtonTouched(self.cellIndexPath)
    }
    
}
