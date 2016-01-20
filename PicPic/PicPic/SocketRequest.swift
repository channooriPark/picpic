//
//  SocketRequest.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 14..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import CryptoSwift

public enum SERVICE_CODE: Int{
    case MEMBER_JOIN = 201
    case LOGIN = 202
    
    case REPIC_ADD = 205
    case REPIC_DELETE = 206
    
    case CHANGE_PROFILE_PICTURE = 207
    
    case CHECK_EMAIL = 213
    case CHECK_ID = 214
    case CHANGE_ID = 215
    
    case SIGN_OUT = 218
    case RESET_PASSWD = 220
    case CHANGE_PASSWD = 208
    
    case REQUEST_GIF_MAKE = 233
    
    case PLUS_PLAY_COUNT = 301
    
    case LIKE = 302
    case LIKECANCEL = 303
    
    case USER_PROFILE = 406
    case USER_PROFILE_BY_USER_ID = 518
    
    case FOLLOW_ADD = 402
    case FOLLOW_LIST = 404
    
    case FOLLOWER_LIST = 408
    
    case SEARCH_BY_AND_TAG_ID = 507
    case SEARCH_BY_EMAIL = 511
    
    case POST_BY_ID = 803
    
    case CATEGORY_LIST = 801
    case CATEGORY_SEARCH = 802
    case UPLOAD = 804
    case MAIN = 805
    case SEARCH = 806
    
    case MY_PIC = 807
    case MY_REPIC = 808
}



extension String {
    
    func aesEncrypt(key: String, iv: String) throws -> String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        let enc = try AES(key: key, iv: iv, blockMode:.CBC).encrypt(data!.arrayOfBytes(), padding: PKCS7())
        let encData = NSData(bytes: enc, length: Int(enc.count))
        let base64String: String = encData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
        let result = String(base64String)
        return result
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        let dec = try AES(key: key, iv: iv, blockMode:.CBC).decrypt(data!.arrayOfBytes(), padding: PKCS7())
        let decData = NSData(bytes: dec, length: Int(dec.count))
        let result = NSString(data: decData, encoding: NSUTF8StringEncoding)
        return String(result!)
    }
}