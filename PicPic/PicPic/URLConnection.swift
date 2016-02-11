//
//  URLConnection.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 22..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class URLConnection {
    let serviceCode : Int
    let message : JSON
    var json : JSON!

    
    init(serviceCode:Int,message: JSON){
        self.serviceCode = serviceCode
        self.message = message
    }
    
    init(){
        self.serviceCode = 0
        self.message = []
    }
    
    
    
//    func Uconnection() -> JSON{
//        
//        let data : String = String(self.message)
//        let sendMessage :String = data.stringByReplacingOccurrencesOfString("[", withString: "").stringByReplacingOccurrencesOfString("]", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
//        let sendData = sendMessage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
////        let temp : String = "http://192.168.1.105:8080/_app/socket.jsp?code=\(self.serviceCode)&message=\(sendData)"
//        let temp : String = "http://192.168.1.105:8080/_app/socket.jsp?code=\(self.serviceCode)&message=\(sendData)"
//        if let reposURL = NSURL(string: temp){
//            if let JSONData = NSData(contentsOfURL: reposURL){
//                self.json = JSON(data: JSONData)
//            }
//        }
//        return self.json
//    }
    //http://mpipe.cloudapp.net/socket.jsp
}
