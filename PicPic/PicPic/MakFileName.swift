//
//  MakFileName.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 4..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit

class MakeFileNmae {
    let baseDigits : NSString = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    func getFileName(mId:String) ->String{
        var fileName = ""
        let currentTime:Int64  = currentTimeMillis()
        let currentTimeStr = fromCurrnet(currentTime)
        fileName = "\(fromMId(mId))_\(currentTimeStr)"
        return fileName
    }
    
    
    func fromMId(base62Number:String) ->String{
        var returnVal:String = ""
        returnVal = (base62Number.stringByReplacingOccurrencesOfString("PIC", withString:""))
        let i = NSNumberFormatter().numberFromString(returnVal)?.intValue
        returnVal = toBase62(i!)
        return returnVal
    }
    
    func fromCurrnet(base62Number:Int64) -> String{
        return toBase62Long(base62Number)
    }
    
    func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    func toBase62(decimalNumber:Int32) -> String{
        return fromDecimalToOtherBase(62,decimalNumber: decimalNumber)
    }
    
    func toBase62Long(decimalNumber:Int64) -> String{
        return fromDecimalToOtherBaseLong(62,decimalNumber: decimalNumber)
    }
    
    func fromDecimalToOtherBase(base: Int32,var decimalNumber:Int32) ->String{
        var tempVal = ""
        if decimalNumber == 0 {
            tempVal = "0"
        }else{
            tempVal = ""
        }
        var mod:Int32 = 0
        var _mod:Int = 0;
        while decimalNumber != 0 {
            mod = decimalNumber%base
            //tempVal = baseDigits.substringWithRange(Range(0, 3))+tempVal
            _mod = Int(mod)
            tempVal = "\(baseDigits.substringWithRange(NSRange(location: _mod, length: 1)))\(tempVal)"
            //NSLog(baseDigits.substringWithRange(NSRange(location: _mod, length: 1)))
            //NSLog(tempVal);
            decimalNumber = decimalNumber/base // need checking
            //NSLog("\(decimalNumber)")
        }
        return tempVal
    }
    
    
    func fromDecimalToOtherBaseLong(base:Int32,var decimalNumber:Int64 ) -> String{
        
        var tempVal:String = ""
        if decimalNumber == 0 {
            tempVal = "0"
        }else{
            tempVal = ""
        }
        var mod: Int64  = 0
        var _mod: Int = 0;
        while decimalNumber != 0 {
            mod = decimalNumber%Int64(base)
            _mod = Int(mod)
            tempVal = "\(baseDigits.substringWithRange(NSRange(location: _mod, length: 1)))\(tempVal)"
            decimalNumber = decimalNumber/Int64(base) // need checking
        }
        
        return tempVal
    }

}
