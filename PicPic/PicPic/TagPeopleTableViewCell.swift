//
//  TagPeopleTableViewCell.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 17..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagPeopleTableViewCell: UITableViewCell {


    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var data : JSON!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    
    func setData(image:UIImage) {
        self.userName.text = data["id"].string!
        self.profileImage.image = image
    }
    

}
