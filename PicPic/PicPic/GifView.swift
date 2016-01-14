//
//  GifView.swift
//  cameraTester
//
//  Created by Changho Kim on 2015. 11. 30..
//  Copyright © 2015년 picpic. All rights reserved.
//

import UIKit
import ImageIO
import CoreGraphics
import SwiftyJSON
import SpringIndicator

class GifView : UIImageView {
    
    var pausedTime:NSTimeInterval?
    var animation = CAKeyframeAnimation(keyPath: "contents")
    var arr:[UIImage] = []
    var duration:Double = NSTimeInterval(1)
    
    var is_picpic_post:Bool = false
    var backgroundType = 0 // 0: 백그라운드 아님, 1:플레이중 백그라운드, 2:정지중 백그라운드 3:1회 이전에 백그라운드
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var post_id = ""
    var arrwidth : CGFloat = 0
    var arrheight : CGFloat = 0
    var nHeight : CGFloat = 0
    var fileName : String!
    
    var spring:SpringIndicator?
    
    func animateForMaker(images:[UIImage], duration:Double, repeatCount:Float) {
        print(arr.count)
        print(duration)
        self.arr = images
        self.duration = duration
        animation.duration = duration
        animation.values = arr.map {$0.CGImage as! AnyObject}
        animation.repeatCount = repeatCount
        animation.removedOnCompletion = false
        animation.calculationMode = kCAAnimationDiscrete
        animation.delegate = self.superview
        
        self.layer.addAnimation(animation, forKey:"contents")
        self.startAnimating()
    }
    
    func animate(images:[UIImage], duration:Double, repeatCount:Float) {
        self.arr = images
        self.duration = duration
        animation.duration = duration
        animation.values = arr.map {$0.CGImage as! AnyObject}
        animation.repeatCount = repeatCount
        animation.removedOnCompletion = false
        animation.calculationMode = kCAAnimationDiscrete
        animation.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "enterForeground",
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "enterBackground",
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.layer.addAnimation(self.animation, forKey:"contents")
            self.startAnimating()
        }
    }
    
    func animateForPicPicPost(fileName:String) {
        is_picpic_post = true
        var thumb = fileName.stringByReplacingOccurrencesOfString("_2.gif", withString: ".jpg")
        thumb = String(format:"http://gif.picpic.world/%@", arguments:[thumb])
        print(thumb)
        
        self.image = UIImage(data: NSData(contentsOfURL: NSURL(string: thumb)!)!)
        print(self.image?.size)
        self.frame.size = (self.image?.size)!
        
        let gifPath = String(format:"http://gif.picpic.world/%@", arguments:[fileName])
        
        print(gifPath)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("gif 다운로드")
            
            let img = CGImageSourceCreateWithURL(NSURL(string: gifPath)!, nil)
            UIImage.animatedInfoWithSource(img!, frames: &self.arr, duration: &self.duration)
            
            print(self.arr.count)
            print(self.duration)
            
            self.animate(self.arr,duration: self.duration,repeatCount: 1)
        })
        
        
    }
    
    func animateForPicPicPost2(fileName:String,spring:SpringIndicator) {
        is_picpic_post = true
        self.spring = spring
        self.fileName = fileName
        let gifPath = String(format:"http://gif.picpic.world/%@", arguments:[fileName])
        if let img = CGImageSourceCreateWithURL(NSURL(string: gifPath)!, nil) {
            UIImage.animatedInfoWithSource(img, frames: &self.arr, duration: &self.duration)
            arrwidth = self.arr[0].size.width
            arrheight = self.arr[0].size.height
            let nWidth = UIScreen.mainScreen().bounds.width
            nHeight = nWidth * self.arrheight / self.arrwidth
            self.animate(self.arr,duration: self.duration,repeatCount: 1)
            self.force_play()
        }
        
    }
    
    func animateForPicPicTagGif(fileName:String) {
        is_picpic_post = true
        let gifPath = String(format:"http://gif.picpic.world/%@", arguments:[fileName])
        
        print("다운로드 ",gifPath)
        if let img = CGImageSourceCreateWithURL(NSURL(string: gifPath)!, nil) {
            UIImage.animatedInfoWithSource(img, frames: &self.arr, duration: &self.duration)
            arrwidth = self.arr[0].size.width
            arrheight = self.arr[0].size.height
            let nWidth = UIScreen.mainScreen().bounds.width;
            nHeight = nWidth * self.arrheight / self.arrwidth
            self.animate(self.arr,duration: self.duration,repeatCount: 1)
            self.force_play()
        }
        
    }
    
    var currentFrameIndex = 0
    var timer:NSTimer?
    
    func animateForTest(fileName:String) {
        is_picpic_post = true
        var thumb = fileName.stringByReplacingOccurrencesOfString("_2.gif", withString: ".jpg")
        thumb = String(format:"http://gif.picpic.world/%@", arguments:[thumb])
        print(thumb)
        
        self.image = UIImage(data: NSData(contentsOfURL: NSURL(string: thumb)!)!)
        
        let gifPath = String(format:"http://gif.picpic.world/%@", arguments:[fileName])
        
        print(gifPath)
        
        
        let img = CGImageSourceCreateWithURL(NSURL(string: gifPath)!, nil)
        UIImage.animatedInfoWithSource(img!, frames: &arr, duration: &duration)
        
        let interval = duration / Double(arr.count)
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("nextFrame"), userInfo: nil, repeats: true)
        
        animateForMaker(arr,duration: duration,repeatCount: 1)
    }
    
    override func animationDidStart(anim: CAAnimation) {
        if(is_picpic_post) {
            self.spring?.stopAnimation(true)
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
//        print("animation   ",animation)
        if(isPaused) {
        }else {
            if is_picpic_post {
                    self.layer.removeAnimationForKey("content")
//                    animation.repeatCount = 1 //Float.infinity
                    animation.duration = duration
                    animation.values = arr.map {$0.CGImage as! AnyObject}
                    self.layer.addAnimation(animation, forKey:"contents")
                    self.startAnimating()
                    if post_id != "" {
                        let message : JSON = ["post_id":post_id]
                        self.appdelegate.doIt(301, message: message, callback: { (readData) -> () in
                        })
                }
            }
        }
    }
    
//    func pause() {
//        print(self.layer.speed )
//        if(self.layer.speed == 0) {
//            self.layer.speed = 1.0
//            self.layer.timeOffset = 0.0
//            self.layer.beginTime = 0.0
//            let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime!
//            self.layer.beginTime = timeSincePause
//        } else {
//            pausedTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
//            self.layer.timeOffset = pausedTime!
//            self.layer.speed = 0
//        }
//    }
    
    
    
    func force_pause() {
        if(self.layer.speed == 1) {
            pausedTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
            self.layer.timeOffset = pausedTime!
            self.layer.speed = 0
        }
    }
    
    func force_play() {
        if(self.layer.speed == 0) {
            self.layer.speed = 1.0
            self.layer.timeOffset = 0.0
            self.layer.beginTime = 0.0
            let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime!
            self.layer.beginTime = timeSincePause
            self.startAnimating()
            print("speed",self.layer.speed)
        }
    }
    
    func pause() {
        print("pause================================================================= ",self.layer.speed )
        if(self.layer.speed == 0) {
            self.layer.speed = 1.0
            
            self.layer.speed = 1.0
            self.layer.timeOffset = 0.0
            self.layer.beginTime = 0.0
            let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime!
            self.layer.beginTime = timeSincePause
            isPaused = false
        } else {
            pausedTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
            self.layer.timeOffset = pausedTime!
            self.layer.speed = 0
            isPaused = true
        }
    }
    
    var isPaused = false
    
    func pause1() {
        print("pause================================================================= ",self.layer.speed )
        pausedTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        self.layer.timeOffset = pausedTime!
        self.layer.speed = 0
        isPaused = true
    }
    
    
    func play() {
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime!
        self.layer.beginTime = timeSincePause
        self.layer.repeatCount = 1
        self.layer.speed = 1.0
    }
    
    
//    func enterForeground () {
//        print("enterForeground")
//        print("animation",self.animation)
//        if(backgroundType == 1) {
//            force_play()
//            backgroundType = 0
//        }
//    }
//    
//    var is_background = false
//    func enterBackground() {
//        print("enterBackground")
//        print("animation",self.animation)
//        is_background = true
//        
//        if(self.layer.speed == 1) {
//            backgroundType = 1
//            force_pause()
//        } else {
//            backgroundType = 2
//        }
//    }
    
    func enterBackground() {
        print("enter b...........")
        pause1();
        self.layer.removeAnimationForKey("contents")
        print("after b...........")
    }
    
    func enterForeground() {
        print("enter f...........")
        isPaused = false
        self.layer.addAnimation(animation, forKey: "contents")
        self.startAnimating()
        play()
    }
    


    
}