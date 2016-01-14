//
//  SaveCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SaveCell: UICollectionViewCell {

    var delegate: SaveCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnAdd.hidden = true
        self.btnDelete.hidden = true
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    @IBAction func actAdd() {
        delegate?.addSelected()
    }
    
    @IBAction func actDelete() {
        delegate?.deleteSelected()
    }
}

protocol SaveCellDelegate
{
    func addSelected()
    func deleteSelected()
}