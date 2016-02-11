//
//  HotUserPostCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class HotUserPostCell: UICollectionViewCell {

    @IBOutlet weak var gifImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.gifImageView.image = UIImage(named: "non_interest")
    }

}
