//
//  TagCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 24..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var cellIndexPath: NSIndexPath!
    var delegate: TagListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let singleTap = UITapGestureRecognizer()
        singleTap.addTarget(self, action: "singleTapped")
        self.addGestureRecognizer(singleTap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func singleTapped()
    {
        self.delegate?.cellTapped(self.cellIndexPath)
    }
}
