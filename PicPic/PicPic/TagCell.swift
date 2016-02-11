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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
