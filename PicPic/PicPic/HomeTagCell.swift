//
//  HomeTagCell.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 20..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class HomeTagCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var cellIndexPath: NSIndexPath!
    var gradient: CAGradientLayer?
    
    override func awakeFromNib() {
        
        self.gradient = CAGradientLayer()
        self.gradient!.frame = self.bgView.bounds
        self.gradient!.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.02).CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).CGColor]
        self.bgView.layer.insertSublayer(self.gradient!, atIndex: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.gifImageView.image = UIImage(named: "non_interest")
        self.tagLabel.text = nil
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradient?.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 4.5)
    }
    
}
