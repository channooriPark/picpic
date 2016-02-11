//
//  SearchTagCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SearchTagCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagLabel.text = nil
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
