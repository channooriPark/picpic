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
        self.label.text = nil
    }
    
    func singleTapped()
    {
        self.delegate?.cellTapped(self.cellIndexPath)
    }
}
