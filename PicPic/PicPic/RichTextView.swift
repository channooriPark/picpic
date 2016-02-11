//
//  RichTextView.swift
//  comment
//
//  Created by Changho Kim on 2015. 11. 17..
//  Copyright © 2015년 picpic. All rights reserved.
//
import UIKit

public protocol RichTextViewDelegate {
    func textView(textView: RichTextView!, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    func textViewDidChange(textView: RichTextView!)
}

//class RichTextView : UITextView, UITextViewDelegate {
    
public class RichTextView: UITextView, UITextViewDelegate {
    
    //fpublic var realDelegate: RichTextViewDelegate!

    let log = LogPrint()
    let imageURL = ImageURL()
    var range_start = 0
    
    var text_type = 0
    let TEXT_TYPE_NONE = 0
    let TEXT_TYPE_MARK = 1
    let TEXT_TYPE_UNMARK = 2
    let TEXT_TYPE_REFRESH = 3
    let TEXT_TYPE_MARKING = 4;
    
    var text_color: UIColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
    let text_color_1 = UIColor(red: 0.71, green: 0.89, blue: 0.94, alpha: 0.3) // # 컬러
    let text_color_2 = UIColor(red: 0.82, green: 0.82, blue: 0.36, alpha: 0.3) // @ 컬러
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        
    }
    
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let str = textView.text! as String

        if(str.characters.count==0) {
            range_start = range.location
            if(text == "#") {
                text_color = text_color_1
                text_type = TEXT_TYPE_MARK
            } else if(text == "@") {
                text_color = text_color_2
                text_type = TEXT_TYPE_MARK
            } else {
                text_type = TEXT_TYPE_UNMARK
            }
            return true
        }
        
        if( (str.characters.count - range.location) <= 1) { // 커서가 제일 뒤에 있는 경우

            if(text == " " || text == "\n") {
                if(text_type == TEXT_TYPE_MARKING) {
                    text_type = TEXT_TYPE_UNMARK
                    range_start = range.location
                }
            } else if(text_type == TEXT_TYPE_NONE) {
                if(text == "#") {
                    range_start = range.location
                    text_color = text_color_1
                    text_type = TEXT_TYPE_MARK
                } else if(text == "@") {
                    range_start = range.location
                    text_color = text_color_2
                    text_type = TEXT_TYPE_MARK
                }
            } else if(text_type == TEXT_TYPE_MARKING) {
                if(str == "") {
                    range_start = range.location
                    text_type = TEXT_TYPE_UNMARK
                }
            }
        } else { // 텍스트 중간에 커서가 있는 경우
            if(str.characters.count>0) {
                text_type = TEXT_TYPE_REFRESH
            } else {
                //return false
            }
        }
        return true // realDelegate.textView(self, shouldChangeTextInRange: range, replacementText: text)
        
    }
    
    
    
    public func textViewDidChange(textView: UITextView) {
        if(text_type == TEXT_TYPE_NONE) {
            
        } else if(text_type == TEXT_TYPE_MARK) {
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.addAttribute(NSBackgroundColorAttributeName, value: text_color, range: NSMakeRange(range_start, 1))
            
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_MARKING
        } else if(text_type == TEXT_TYPE_UNMARK) {
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.appendAttributedString(textView.attributedText)
            attributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(range_start, 1))
            textView.attributedText = attributedString
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_REFRESH) {
            let preAttributedRange: NSRange = textView.selectedRange
            
            let font = textView.font!
            
            let attrs = [ NSFontAttributeName : font]
            let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
            let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
            
            let txt = textView.text! as String
            let str_arr = txt.componentsSeparatedByString("\n")
            
            let para = NSMutableAttributedString()
            
            for(var i=0;i<str_arr.count;i++) {
                let str = str_arr[i]
                
                let str_arr2 = str.componentsSeparatedByString(" ")
                
                for(var j=0;j<str_arr2.count;j++) {
                    let str = str_arr2[j]
                    
                    var attrString = NSAttributedString()
                    
                    if(str.hasPrefix("#")) {
                        attrString = NSAttributedString(string: str, attributes:attrs1)
                        para.appendAttributedString(attrString)
                    } else if(str.hasPrefix("@")) {
                        attrString = NSAttributedString(string: str, attributes:attrs2)
                        para.appendAttributedString(attrString)
                    } else {
                        attrString = NSAttributedString(string: str, attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                    if( (j+1) != str_arr2.count) {
                        attrString = NSAttributedString(string: " ", attributes:attrs)
                        para.appendAttributedString(attrString)
                    }
                }
                if( (i+1) != str_arr.count) {
                    let attrString = NSAttributedString(string: "\n", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }

            textView.attributedText = para
            textView.selectedRange = preAttributedRange
            text_type = TEXT_TYPE_NONE
        } else if(text_type == TEXT_TYPE_MARKING) {
            
        }
        //realDelegate.textViewDidChange(self)
    }
    
    public func putText(str:String,url:String?) {
        
        self.text = str;
        initCommentStyle(self,url: url)
    }
    
    public func putPost(str:String) {
        
        self.text = str;
        initCommentStylePost(self)
    }
    
    
    public func initCommentStylePost(textView:UITextView) {
        
        if textView.text.characters.count > 20 {
            for var i = 0; i < textView.text.characters.count; i++ {
                if i%20 == 0 {
                    
                }
            }
        }
        
        let font = textView.font!
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attrs = [ NSFontAttributeName : font,NSParagraphStyleAttributeName:style]
//        let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
//        let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
        
        let txt = textView.text! as String
        let str_arr = txt.componentsSeparatedByString("\n")
        
        let para = NSMutableAttributedString()
        
        for(var i=0;i<str_arr.count;i++) {
            let str = str_arr[i]
            
            let str_arr2 = str.componentsSeparatedByString(" ")
            
            for(var j=0;j<str_arr2.count;j++) {
                let str = str_arr2[j]
                
                var attrString = NSAttributedString()
                
                if(str.hasPrefix("#")) {
                    let string = str.componentsSeparatedByString("#")
                    let _attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14), NSLinkAttributeName : "picpic://tag_name/\(string[1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)",NSParagraphStyleAttributeName:style]
                    
                    attrString = NSAttributedString(string: str, attributes:_attrs)
                    para.appendAttributedString(attrString)
                    //para.addAttribute(NSLinkAttributeName, value: "picpic://user", range: NSMakeRange(13, 4))
                    
                } else if(str.hasPrefix("@")) {
                    let string = str.componentsSeparatedByString("@")
                    let _attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14),NSLinkAttributeName : "picpic://user_name/\(string[1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)",NSParagraphStyleAttributeName:style]
                    log.log("\(_attrs)")
                    attrString = NSAttributedString(string: str, attributes:_attrs)
                    para.appendAttributedString(attrString)
                } else {
                    attrString = NSAttributedString(string: str, attributes:attrs)
                    para.appendAttributedString(attrString)
                }
                if( (j+1) != str_arr2.count) {
                    attrString = NSAttributedString(string: " ", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            if( (i+1) != str_arr.count) {
                let attrString = NSAttributedString(string: "\n", attributes:attrs)
                para.appendAttributedString(attrString)
            }
        }
        self.attributedText = para
        
        
    }
    
    
    
    public func initCommentStyle(textView:UITextView,url:String?) {
        
        if textView.text.characters.count > 20 {
            for var i = 0; i < textView.text.characters.count; i++ {
                if i%20 == 0 {
                    
                }
            }
        }
    
        let font = textView.font!
        let bodyFont = UIFont(name: "HelveticaNeue-Bold", size: 15)
        let attrs = [ NSFontAttributeName : font]
        let attrs1 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_1]
        let attrs2 = [NSFontAttributeName : font, NSBackgroundColorAttributeName:text_color_2]
        
        let txt = textView.text! as String
        let str_arr = txt.componentsSeparatedByString("\n")
        
        let para = NSMutableAttributedString()
        var attrString = NSAttributedString()
        
        
        
        for(var i=0;i<str_arr.count;i++) {
            let str = str_arr[i]
            
            let str_arr2 = str.componentsSeparatedByString(" ")
            
            for(var j=0;j<str_arr2.count;j++) {
                let str = str_arr2[j]
                
                
                
                
                
                if(str.hasPrefix("#")) {
                    let string = str.componentsSeparatedByString("#")
                    let _attrs = [NSFontAttributeName : bodyFont!, NSLinkAttributeName : "picpic://tag_name/\(string[1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"]
                    
                    attrString = NSAttributedString(string: str, attributes:_attrs)
                    para.appendAttributedString(attrString)
                    //para.addAttribute(NSLinkAttributeName, value: "picpic://user", range: NSMakeRange(13, 4))
                    
                } else if(str.hasPrefix("@")) {
                    let string = str.componentsSeparatedByString("@")
                    let _attrs = [NSFontAttributeName : bodyFont!, NSLinkAttributeName : "picpic://user_name/\(string[1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"]
                    log.log("\(_attrs)")
                    attrString = NSAttributedString(string: str, attributes:_attrs)
                    para.appendAttributedString(attrString)
                } else {
                    attrString = NSAttributedString(string: str, attributes:attrs)
                    para.appendAttributedString(attrString)
                }
                if( (j+1) != str_arr2.count) {
                    attrString = NSAttributedString(string: " ", attributes:attrs)
                    para.appendAttributedString(attrString)
                }
            }
            if( (i+1) != str_arr.count) {
                let attrString = NSAttributedString(string: "\n", attributes:attrs)
                para.appendAttributedString(attrString)
            }
            
            let textAttachment = NSTextAttachment()
            
//            if let urlString = url {
//                attrString = NSAttributedString(string: " ")
//                para.appendAttributedString(attrString)
//                let url = NSURL(string: imageURL.gifImageUrl(urlString))
//                if let imagedata = NSData(contentsOfURL: url!){
//                    textAttachment.image = UIImage.animatedImageWithAnimatedGIFURL(url)
//                    
//                    let oldWidth = textAttachment.image!.size.width
//                    let scaleFactor = oldWidth/(textView.frame.size.width - 10)
//                    textAttachment.image = UIImage(CGImage: textAttachment.image!.CGImage!, scale: scaleFactor, orientation: UIImageOrientation.Up)
//                    let attrStringWithImage : NSAttributedString = NSAttributedString(attachment: textAttachment)
//                    let stringCount = para.length
//                    para.replaceCharactersInRange(NSMakeRange(stringCount-1, 1), withAttributedString: attrStringWithImage)
//                }
//            }
            
        }
        self.attributedText = para
 
    
    }
    
    
    
    
}