//: Playground - noun: a place where people can play

import Cocoa


var str = "Hello, playground"
var str1 = "안녕하세요"

str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
str1.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
let rangeStart = 2

let text = str1 as NSString

let end = text.length - rangeStart

let subString = text.substringWithRange(NSMakeRange(rangeStart, end))

