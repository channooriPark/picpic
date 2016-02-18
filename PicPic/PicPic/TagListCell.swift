//
//  TagListCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 27..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class TagListCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var userView: UIView!

    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var bodyViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var lastCommentView: UIView!

    @IBOutlet weak var lastCommentImageView: UIImageView!
    @IBOutlet weak var lastCommentTitleLabel: UILabel!
    @IBOutlet weak var lastCommentTextLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var heartImage: UIImageView!
    
    var cellIndexPath: NSIndexPath!
    var delegate: TagListCellDelegate?
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "userViewTouched:")
        self.userView.addGestureRecognizer(tap)
        
        let commentTap = UITapGestureRecognizer()
        commentTap.addTarget(self, action: "commentButtonTouched")
        self.lastCommentView.addGestureRecognizer(commentTap)
        
        let singleTap = UITapGestureRecognizer()
        singleTap.addTarget(self, action: "singleTapped")
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer()
        doubleTap.numberOfTapsRequired = 2
        singleTap.requireGestureRecognizerToFail(doubleTap)
        doubleTap.addTarget(self, action: "doubleTapped")
        self.addGestureRecognizer(doubleTap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifImageView.image = nil
        self.userIdLabel.text = nil
        self.playCountLabel.text = nil
        self.followButton.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
        self.heartImage.image = UIImage(named: "heart")
        
        self.lastCommentImageView.image = nil
        self.lastCommentTitleLabel.text = nil
        self.lastCommentTextLabel.text = nil
        
        self.likeCountButton.setTitle("\(self.appdelegate.ment["like"].stringValue) 0\(self.appdelegate.ment["timeline_count"].stringValue)", forState: .Normal)
        self.commentCountButton.setTitle("\(self.appdelegate.ment["comment"].stringValue) 0\(self.appdelegate.ment["timeline_count"].stringValue)", forState: .Normal)
        
        for view in self.bodyView.subviews
        {
            view.removeFromSuperview()
        }
        
        self.likeButton.setImage(UIImage(named: "icon_timeline_like"), forState: .Normal)
    }
    
    @IBAction func userViewTouched(sender: AnyObject) {
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
    
    @IBAction func likeCountButtonTouched() {
        self.delegate?.likeCountButtonTouched(self.cellIndexPath)
    }
    
    @IBAction func likeButtonTouched() {
        self.delegate?.likeButtonTouched(self.cellIndexPath)
    }
    
    @IBAction func commentButtonTouched() {
        self.delegate?.commentButtonTouched(self.cellIndexPath)
    }

    @IBAction func shareButtonTouched() {
        self.delegate?.shareButtonTouched(self.cellIndexPath)
    }
    
    @IBAction func moreButtonTouched() {
        self.delegate?.moreButtonTouched(self.cellIndexPath)
    }
    
    func singleTapped()
    {
        self.delegate?.cellTapped(self.cellIndexPath)
    }
    
    func doubleTapped()
    {
        self.likeButtonTouched()
    }
}

protocol TagListCellDelegate
{
    func userViewTouched(indexPath: NSIndexPath)
    func followButtonTouched(indexPath: NSIndexPath)
    func likeCountButtonTouched(indexPath: NSIndexPath)
    func likeButtonTouched(indexPath: NSIndexPath)
    func commentButtonTouched(indexPath: NSIndexPath)
    func shareButtonTouched(indexPath: NSIndexPath)
    func moreButtonTouched(indexPath: NSIndexPath)
    func cellTapped(indexPath: NSIndexPath)
}
