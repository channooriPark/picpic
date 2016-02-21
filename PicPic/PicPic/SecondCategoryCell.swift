//
//  SecondCategoryCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 9..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SecondCategoryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var cellIndexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.label.text = nil
    }
    
}
