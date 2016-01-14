//
//  MyBar.swift
//  cameraTester
//
//  Created by Changho Kim on 2015. 11. 28..
//  Copyright © 2015년 picpic. All rights reserved.
//

import UIKit

class MyBar : UIView {
    
    var last_bar:UIView?
    var current_time:Double = 0
    var total_time:Double = 5.0
    
    func addBar() {
        
        var wi = 0.0 as CGFloat
        
        if(self.subviews.count != 0) {
            let indx = self.subviews.count-1
            let frame = self.subviews[indx].frame
            
            let posX =   frame.origin.x
            let posY = 0.0 as CGFloat
            let width = frame.width - 1
            let height = 8.0 as CGFloat
            
//            self.subviews[indx].frame = CGRect(x: posX, y: posY, width: width, height: height)
            
            wi = posX + width + 2
        }
        
        let posX =   wi+1 //CGFloat(currentTime) *  Config.getInstance().wid / CGFloat(total_time)
        let posY = 0.0 as CGFloat
        let width = 1.0 as CGFloat
        let height = 8.0 as CGFloat
        //let frame = CGRect(x: posX, y: posY, width: width, height: height)
        
        last_bar = UIView(frame: CGRect(x: posX, y: posY, width: width, height: height))
        last_bar?.backgroundColor = Config.getInstance().color
        
        self.addSubview(last_bar!)
    }
    
    func update(elapsedTime: Double) {
        let posX =  last_bar?.frame.origin.x
        let posY = 0.0 as CGFloat
        let width = CGFloat(elapsedTime) * Config.getInstance().wid / CGFloat(total_time)
        let height = 8.0 as CGFloat
        
        last_bar = UIView(frame: CGRect(x: posX!, y: posY, width: width, height: height))
        
        let indx = self.subviews.count-1
        self.subviews[indx].frame = CGRect(x: posX!, y: posY, width: width, height: height)
    }
    
    func delete() {
        if self.subviews.count > 0 {
            let indx = self.subviews.count-1
            self.subviews[indx].removeFromSuperview()
        }
    }
    
    
    func deleteAll(){
        if self.subviews.count > 0 {
            for view in self.subviews {
                view.removeFromSuperview()
            }
        }
    }
    
}
