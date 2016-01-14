//
//  ImageURL.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 3..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit


class ImageURL {
    
    var month = ["January","Febuary","March","April","May","June","July","August","September","October","November","December"]
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    func imageurl(imageName : String) -> String {
        let address : String = "http://gif.picpic.world/"+imageName
        return address
    }
    
    func gifImageUrl(url:String)-> String{
        //        let imageName : NSArray = url.componentsSeparatedByString("_")
        let address : String = "http://gif.picpic.world/"+url
        return address
    }
    
    
    func thumnail(url:String)-> String {
        let temp = url.componentsSeparatedByString("_2.")
        return "\(temp[0]).jpg"
    }
    
    //등록 날자 계산 func
    func uploadedDate(uploadDateText : String)-> String{
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"  //원래 date format
        
        //현재 날짜
        let date = NSDate()
        //JSON으로 가져온 데이터 NSDate로 변환
        let uploadTime = formatter.dateFromString(uploadDateText)
        
        //현재 Language 가져오기
        let defaults = NSUserDefaults.standardUserDefaults()
        let languages : NSArray = defaults.objectForKey("AppleLanguages")! as! NSArray
        let currentLanguage = languages.objectAtIndex(0)
        let locale = NSLocale.currentLocale()
        //formatter에 언어 설정
        formatter.locale = locale
        
        
        formatter.dateFormat = "yyyyMMdd" //일수 확인을 위한 format
        var day = Int(formatter.stringFromDate(uploadTime!))
        var currentDate = Int(formatter.stringFromDate(date))
        //일수 차이 계산
        var valueInterval = currentDate! - day!
//        print(valueInterval)
        if valueInterval > 0 {
            var time = ""
            if self.appdelegate.locale == "ko_KR" {
                formatter.dateFormat = "MM\(self.appdelegate.ment["tmonth"].stringValue)월 dd\(self.appdelegate.ment["day"].stringValue)"
                time = formatter.stringFromDate(uploadTime!)
            }else {
                formatter.dateFormat = "MM/dd"
                let day = formatter.stringFromDate(uploadTime!).componentsSeparatedByString("/")
                
                switch day[0] {
                case "1" :
                    time = "\(self.month[0]) \(day[1])"
                    break
                case "2" :
                    time = "\(self.month[1]) \(day[1])"
                    break
                case "3" :
                    time = "\(self.month[2]) \(day[1])"
                    break
                case "4" :
                    time = "\(self.month[3]) \(day[1])"
                    break
                case "5" :
                    time = "\(self.month[4]) \(day[1])"
                    break
                case "6" :
                    time = "\(self.month[5]) \(day[1])"
                    break
                case "7" :
                    time = "\(self.month[6]) \(day[1])"
                    break
                case "8" :
                    time = "\(self.month[7]) \(day[1])"
                    break
                case "9" :
                    time = "\(self.month[8]) \(day[1])"
                    break
                case "10" :
                    time = "\(self.month[9]) \(day[1])"
                    break
                case "11" :
                    time = "\(self.month[10]) \(day[1])"
                    break
                default :
                    time = "\(self.month[11]) \(day[1])"
                    break
                }
            }
            return time
        }else{
            
            //시간 계산을 위한 format
            formatter.dateFormat = "HH"
            
            //시간 차이 계산
            day = Int(formatter.stringFromDate(uploadTime!))
            currentDate = Int(formatter.stringFromDate(date))
            valueInterval = currentDate! - day!
            
            if valueInterval > 0 {
                return "\(valueInterval)\(self.appdelegate.ment["timeline_before_hour"].stringValue)"
            }else {
                formatter.dateFormat = "mm"
                
                day = Int(formatter.stringFromDate(uploadTime!))
                currentDate = Int(formatter.stringFromDate(date))
                valueInterval = currentDate! - day!
                
                if valueInterval > 0 {
                    return "\(valueInterval)\(self.appdelegate.ment["timeline_before_minute"].stringValue)"
                }else {
                    if self.appdelegate.locale == "ko_KR" {
                        return "방금전"
                    }else {
                        return "now"
                    }
                    
                }
            }
            
            
        }
        
    }
}