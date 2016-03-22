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
    
    @IBOutlet weak var btnPlus: UIButton!
    var delegate : SearchFriendDelegate!
    var email : String!
    var followYN : Bool!
    var index : Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
    }
    
//    func setUp1() {
//        let tap = UITapGestureRecognizer(target: self, action: "firstTouched")
//        firstimage.addGestureRecognizer(tap)
//    }
//    
//    func setUp2() {
//        let tap1 = UITapGestureRecognizer(target: self, action: "secondTouched")
//        secondimage.addGestureRecognizer(tap1)
//    }
//    
//    func setUp3() {
//        let tap2 = UITapGestureRecognizer(target: self, action: "thirdTouched")
//        thirdimage.addGestureRecognizer(tap2)
//    }
//    
//    func setUp4() {
//        let tap3 = UITapGestureRecognizer(target: self, action: "fourthTouched")
//        fourthimage.addGestureRecognizer(tap3)
//    }
    
    
    @IBAction func onPlus(sender: AnyObject) {
        if (followYN != nil) == true {
            //yes -> no
            btnPlus.setImage(UIImage(named: "icon_find_plus_c"), forState: .Normal)
            self.followYN = false
        }else {
            //no -> yes
            btnPlus.setImage(UIImage(named: "icon_find_plus"), forState: .Normal)
            self.followYN = true
        }
        print(self.email)
        self.delegate.follow(self.email)
    }
    
    @IBAction func firstcCicked(sender: AnyObject) {
        self.delegate.imageTouched(self.index , secondIndex: 0)
    }
    
    @IBAction func secondClicked(sender: AnyObject) {
        self.delegate.imageTouched(self.index , secondIndex: 1)
    }
    
    @IBAction func thirdClicked(sender: AnyObject) {
        self.delegate.imageTouched(self.index , secondIndex: 2)
    }
    
    @IBAction func fourthClicked(sender: AnyObject) {
        self.delegate.imageTouched(self.index , secondIndex: 3)
    }
    
    
}

protocol SearchFriendDelegate {
    func imageTouched(index : Int, secondIndex : Int)
    func follow(email : String)
}


