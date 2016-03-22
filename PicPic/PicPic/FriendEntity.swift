//
//  FriendEntity.swift
//  PicPic
//
//  Created by JIS-MAC on 1/21/16.
//  Copyright © 2016 찬누리 박. All rights reserved.
//

import Foundation


class FriendEntity {
    
    var name:String!
    
    var profileUrl:String!
    var firstImageUrl:String!
    var secondImageUrl:String!
    var thirdImageUrl:String!
    var fourthImageUrl:String!
    var follow_yn:String!
    var email : String!
    
    init(name:String, profile:String, first:String, sencond:String, third:String, fourth:String, follow_yn:String,email : String) {
        
        self.name = name;
        self.profileUrl = profile
        self.firstImageUrl = first
        self.secondImageUrl = sencond
        self.thirdImageUrl = third
        self.fourthImageUrl = fourth
        self.follow_yn = follow_yn
        self.email = email
    }
    
    
}