//
//  HomeNativeReusableView.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 23..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class HomeNativeReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
    }
}
