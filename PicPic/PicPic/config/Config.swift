//
//  Config.swift
//  PowerApp
//
//  Created by Shawn Chun on 2014. 12. 24..
//  Copyright (c) 2014년 Koeracenter. All rights reserved.
//

import UIKit

private let config = Config()

class Config {
    var videoRatio: String = "1:1" {
        didSet {
            if videoRatio == "1:1" {
                hei = UIScreen.mainScreen().bounds.width
            }
            else {
                hei = 4*UIScreen.mainScreen().bounds.width/3
            }
        }
    }
    var wid = UIScreen.mainScreen().bounds.width
    var hei = UIScreen.mainScreen().bounds.width
    var dataType: Int = 0
    var frameCnt: Int = 0
    var ghostAlpha: CGFloat = 0.5
    var photoDataArr: Array<UIImage> = Array()
    let color = UIColor(red: 0.38, green: 0.44, blue: 0.99, alpha: 1.0)
    
    private init() {}
    
    class func getInstance() -> Config {
        return config
    }
}