//
//  SettingBlockTableViewCell.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingBlockTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userID: UILabel!
    var data : JSON!
    let imageURL = ImageURL()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    
    func getData() {
        if let url = NSURL(string: imageURL.imageurl(data["url"].string!)){
            let data = NSData(contentsOfURL: url)
            self.profileImage.image = UIImage(data: data!)
        }
        self.userID.text = data["id"].string!
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
