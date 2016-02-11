//
//  AlramViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 26..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var friendname: UILabel!
    @IBOutlet weak var firstimage: UIImageView!
    @IBOutlet weak var secondimage: UIImageView!
    @IBOutlet weak var thirdimage: UIImageView!
    @IBOutlet weak var fourthimage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
    }
    
    @IBAction func onPlus(sender: AnyObject) {
    
    }
    
}


