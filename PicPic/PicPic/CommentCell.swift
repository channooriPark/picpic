//
//  CommentCell.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 23..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userIDText: UITextView!
    @IBOutlet weak var uploadTimeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bodyLabel: RichTextView!
    
    @IBOutlet weak var hiddenButton1: UIButton!
    @IBOutlet weak var hiddenButton2: UIButton!
    @IBOutlet weak var upperContentView: UIView!
    @IBOutlet weak var upperContentViewLeftConst: NSLayoutConstraint!
    @IBOutlet weak var upperContentViewRightConst: NSLayoutConstraint!
    var panStartPoint: CGPoint?
    var startingRightConst: CGFloat?
    var panRecognizer: UIPanGestureRecognizer?
    
    var delegate: SwipableCellButtonActionDelegate?
    
    let kBounceValue:CGFloat = 20.0
    var writType : Int = 0
    var comType : Int = 0 // 0이면 내 댓글 1이면 남 댓글
    
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var index = 0
    var data : JSON = ["like" : 0,
        "reply_id" : "",
        "id" : "",
        "body" : "",
        "time" : "",
        "profile_picture" : "",
        "like_yn" : "",
        "email" : ""]
    let imageURL = ImageURL()
    var count : Int = 0
    var like_yn = ""
    var month = ["January","Febuary","March","April","May","June","July","August","September","October","November","December"]
    let log = LogPrint()
    var height : CGFloat!
    @IBOutlet weak var dateWid: NSLayoutConstraint!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    var comment : CommentViewController!
    @IBOutlet weak var profileHei: NSLayoutConstraint!
    @IBOutlet weak var profileWid: NSLayoutConstraint!
    var cellIndex : NSIndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIScreen.mainScreen().bounds.width == 320.0 {
            profileWid.constant = 36
            profileHei.constant = 36
            profileImage.frame = CGRectMake(14, 8, profileWid.constant, profileHei.constant)
        }
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        heartImage.hidden = true
        likeCountLabel.hidden = true
        
        self.panRecognizer = UIPanGestureRecognizer.init(target: self, action: "panThisCell:")
        self.panRecognizer?.delegate = self
        self.upperContentView.addGestureRecognizer(self.panRecognizer!)
    }
    
    override func prepareForReuse() {
        // cell이 재사용될때 open되있을수 있으므로 close
        super.prepareForReuse()
        self.resetConstToZero(false, notifyDelegateDidClose: false)
    }
    
    func setBody(){
        var urlString : String!
        if data["url"].string == "" {
            urlString = nil
        }else {
            urlString = data["url"].stringValue
        }
        bodyLabel.putText(data["body"].string!,url: urlString)
        bodyLabel.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let fixedWidth = bodyLabel.frame.size.width
        bodyLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = bodyLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = bodyLabel.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        bodyLabel.frame = newFrame;
        
        
        bodyLabel.scrollEnabled = false
        bodyLabel.sizeToFit()
        
        self.height = 70 + (bodyLabel.frame.size.height - 27)
        
        let uploadDateText = data["time"].string!
        
        if self.data["like_yn"].stringValue == "Y" {
            self.heartImage.hidden = false
            self.likeCountLabel.hidden = false
            self.like_yn = "Y"
            count = self.data["like"].int!
            self.likeCountLabel.text = String(count)
            self.likeButton.setTitle("\(self.appdelegate.ment["like_cancel"].stringValue)", forState: UIControlState.Normal)
            like_yn = self.data["like_yn"].string!
        }else {
            self.heartImage.hidden = true
            self.likeCountLabel.hidden = true
            self.like_yn = "N"
            count = self.data["like"].int!
            self.likeCountLabel.text = String(count)
            self.likeButton.setTitle("\(self.appdelegate.ment["like"].stringValue)", forState: UIControlState.Normal)
            like_yn = self.data["like_yn"].string!
        }
        
        
        
        uploadedDate(uploadDateText)
        let dateString : NSString = uploadTimeLabel.text!
        let dateSize = dateString.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(10)])
        dateWid.constant = dateSize.width + 7
        
//        userIDText.putText(data["id"].string!)
        
        var attrString = NSAttributedString()
        let para = NSMutableAttributedString()
        let url = "picpic://user_name/\(data["id"].string!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"
        let font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        let _attrs : [String:AnyObject] = [NSFontAttributeName : font! , NSLinkAttributeName : url]
        attrString = NSAttributedString(string: data["id"].string!, attributes:_attrs)
        para.appendAttributedString(attrString)
        self.userIDText.attributedText = para
        
        if writType == 0 {
            //내글
            if data["email"].stringValue == self.appdelegate.email {
                //내 댓글
                self.hiddenButton1.setImage(UIImage(named: "icon_mycomment_modify"), forState: .Normal)
                self.hiddenButton2.setImage(UIImage(named: "icon_mycomment_delete"), forState: .Normal)
                self.comType = 0
            }else {
                //남 댓글
                self.hiddenButton1.setImage(UIImage(named: "icon_mycomment_reteg"), forState: .Normal)
                self.hiddenButton2.setImage(UIImage(named: "icon_mycomment_delete"), forState: .Normal)
                self.comType = 1
            }
        }else {
            //남의 글
            if data["email"].stringValue == self.appdelegate.email {
                //내 댓글
                self.hiddenButton1.setImage(UIImage(named: "icon_mycomment_modify"), forState: .Normal)
                self.hiddenButton2.setImage(UIImage(named: "icon_mycomment_delete"), forState: .Normal)
                self.comType = 0
            }else {
                //남 댓글
                self.hiddenButton1.setImage(UIImage(named: "icon_mycomment_reteg"), forState: .Normal)
                self.hiddenButton2.setImage(UIImage(named: "icon_othercomment_report"), forState: .Normal)
                self.comType = 1
            }
        }
        
        
    }
    
    
    func setData(image: UIImage){
            self.profileImage.image = image
        
        let tap = UITapGestureRecognizer(target: self, action: "user")
        self.profileImage.userInteractionEnabled = true
        self.profileImage.addGestureRecognizer(tap)
    }
    
    func user(){
        let user = self.appdelegate.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
        self.appdelegate.controller.append(user)
        user.type = "user"
//        user.index = self.appdelegate.controller.count - 1
        user.myId = self.appdelegate.email
        user.userId = data["email"].stringValue
        self.appdelegate.testNavi.navigationBarHidden = true
        self.appdelegate.testNavi.pushViewController(user, animated: true)
    }
    
    //등록 날자 계산 func
    func uploadedDate(uploadDateText : String){
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
        
        if valueInterval > 0 {
            var time = ""
            if self.appdelegate.locale == "ko_KR" {
                self.dateWid.constant = 55
                formatter.dateFormat = "MM\(self.appdelegate.ment["tmonth"].stringValue)월 dd\(self.appdelegate.ment["day"].stringValue)"
                time = formatter.stringFromDate(uploadTime!)
            }else {
                formatter.dateFormat = "MM/dd"
                let day = formatter.stringFromDate(uploadTime!).componentsSeparatedByString("/")
                self.dateWid.constant = 80
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
            uploadTimeLabel.text = time
        }else{
            
            //시간 계산을 위한 format
            formatter.dateFormat = "HH"
            
            //시간 차이 계산
            day = Int(formatter.stringFromDate(uploadTime!))
            currentDate = Int(formatter.stringFromDate(date))
            valueInterval = currentDate! - day!
            
            if valueInterval > 0 {
                if self.appdelegate.locale != "ko_KR" {
                    self.dateWid.constant = 80
                }
                
                
                uploadTimeLabel.text = "\(valueInterval)\(self.appdelegate.ment["timeline_before_hour"].stringValue)"
            }else {
                formatter.dateFormat = "mm"
                
                day = Int(formatter.stringFromDate(uploadTime!))
                currentDate = Int(formatter.stringFromDate(date))
                valueInterval = currentDate! - day!
                
                if valueInterval > 0 {
                    if self.appdelegate.locale != "ko_KR" {
                        self.dateWid.constant = 85
                    }
                    
                    uploadTimeLabel.text = "\(valueInterval)\(self.appdelegate.ment["timeline_before_minute"].stringValue)"
                }else {
                    if self.appdelegate.locale != "ko_KR" {
                        self.dateWid.constant = 30
                    }
                    if self.appdelegate.locale == "ko_KR" {
                        uploadTimeLabel.text = "방금전"
                    }else {
                        uploadTimeLabel.text = "now"
                    }
                    
                }
            }
            
            
        }
        
    }

    @IBAction func like(sender: AnyObject) {
        
        let message : JSON = ["post_reply_id":self.data["reply_id"].string!,"click_id":self.appdelegate.email,"like_form":"R"]
        if self.data["like_yn"].string! == "Y" {
            self.appdelegate.doIt(303, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success" {
                    self.count--
                    self.like_yn = "N"
                        self.likeButton.setTitle("\(self.appdelegate.ment["like"].stringValue)", forState: UIControlState.Normal)
                    self.heartImage.hidden = true
                    self.likeCountLabel.hidden = true
                    self.likeCountLabel.text = String(self.count)
                    self.data["like_yn"].string = self.like_yn
                    self.data[].int = self.count
                    self.comment.dataArray[self.index] = self.data
//                    print(self.data)
                }
            })
        }else {
            self.appdelegate.doIt(302, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success" {
                    self.count++
                    self.like_yn = "Y"
                    self.likeButton.setTitle("\(self.appdelegate.ment["like_cancel"].stringValue)", forState: UIControlState.Normal)
                    self.heartImage.hidden = false
                    self.likeCountLabel.hidden = false
                    self.likeCountLabel.text = String(self.count)
                    self.data["like_yn"].string = self.like_yn
//                    self.data["like_yn"].stringValue = self.like_yn
                    self.data["like"].int = self.count
                    self.comment.dataArray[self.index] = self.data
//                    print(self.data)
                }
            })
        }
        
        
        
        
//        print(count)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func buttonTotalWidth() -> CGFloat //full로 열렸을때의 오른쪽으로부터x값
    {
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.hiddenButton1.frame)
    }
    
    func panThisCell(recognizer: UIPanGestureRecognizer)// user가 swipe시작시 콜
    {
        switch (recognizer.state)
        {
        case UIGestureRecognizerState.Began:
            self.panStartPoint = recognizer.translationInView(self.upperContentView)
            self.startingRightConst = self.upperContentViewRightConst.constant
            
        case UIGestureRecognizerState.Changed:
            let currentPoint: CGPoint = recognizer.translationInView(self.upperContentView)
            let deltaX = currentPoint.x - (self.panStartPoint?.x ?? 0)
            
            var panningLeft = false
            if (currentPoint.x < self.panStartPoint?.x)
            {
                panningLeft = true
            }
            
            if (self.startingRightConst == 0) //first began panning
            {
                if !panningLeft
                {
                    let constant: CGFloat = max(-deltaX, 0)
                    if constant == 0
                    {
                        self.resetConstToZero(true, notifyDelegateDidClose: false)
                    }
                    else
                    {
                        self.upperContentViewRightConst.constant = constant
                    }
                }
                else
                {
                    let constant: CGFloat =  min(-deltaX, self.buttonTotalWidth())
                    if constant == self.buttonTotalWidth()
                    {
                        self.setConstToShowAllButton(true, notifyDelegatedDidOpen: false)
                    }
                    else
                    {
                        self.upperContentViewRightConst.constant = constant
                    }
                }
            }
            else
            {
                let adjustment: CGFloat = self.startingRightConst! - deltaX
                if !panningLeft
                {
                    let constant: CGFloat = max(adjustment, 0)
                    if constant == 0
                    {
                        self.resetConstToZero(true, notifyDelegateDidClose: false)
                    }
                    else
                    {
                        self.upperContentViewRightConst.constant = constant
                    }
                }
                else
                {
                    let constant: CGFloat = min(adjustment, self.buttonTotalWidth())
                    if constant == self.buttonTotalWidth()
                    {
                        self.setConstToShowAllButton(true, notifyDelegatedDidOpen: false)
                    }
                    else
                    {
                        self.upperContentViewRightConst.constant = constant
                    }
                }
            }
            self.upperContentViewLeftConst.constant = -self.upperContentViewRightConst.constant
            
            //print("pan moved ", deltaX)
        case UIGestureRecognizerState.Ended:
            if self.startingRightConst == 0
            {
                let halfOfButtonOne = CGRectGetWidth(self.hiddenButton1.frame) / 2
                if self.upperContentViewRightConst.constant >= halfOfButtonOne
                {
                    self.setConstToShowAllButton(true, notifyDelegatedDidOpen: true)
                }
                else
                {
                    self.resetConstToZero(true, notifyDelegateDidClose: true)
                }
            }
            else
            {
                let oneAndAHalfButton = CGRectGetWidth(self.hiddenButton1.frame) * 1.5
                if self.upperContentViewRightConst.constant >= oneAndAHalfButton
                {
                    self.setConstToShowAllButton(true, notifyDelegatedDidOpen: true)
                }
                else
                {
                    self.resetConstToZero(true, notifyDelegateDidClose: true)
                }
            }
            
        case UIGestureRecognizerState.Cancelled:
            if self.startingRightConst == 0
            {
                self.resetConstToZero(true, notifyDelegateDidClose: true)
            }
            else
            {
                self.setConstToShowAllButton(true, notifyDelegatedDidOpen: true)
            }
            
        default:
            break
        }
    }
    
    private func resetConstToZero(animated: Bool, notifyDelegateDidClose notifyDelegate: Bool)// cell close
    {
        if notifyDelegate
        {
            self.delegate?.cellDidClose(self.cellIndex)
        }
        
        if (self.startingRightConst == 0 && self.upperContentViewRightConst.constant == 0)
        {
            return
        }
        
        self.upperContentViewRightConst.constant = -kBounceValue
        self.upperContentViewLeftConst.constant = kBounceValue
        
        self.updateConstIfNeeded(animated, completion: {_ in
            self.upperContentViewRightConst.constant = 0
            self.upperContentViewLeftConst.constant = 0
            
            self.updateConstIfNeeded(animated, completion: {_ in
                self.startingRightConst = self.upperContentViewRightConst.constant
            })
        })
    }
    
    private func setConstToShowAllButton(animated: Bool, notifyDelegatedDidOpen notifyDelegate: Bool)// cell open
    {
        if notifyDelegate
        {
            self.delegate?.cellDidOpen(self)
        }
        if (self.startingRightConst == self.buttonTotalWidth() && self.upperContentViewRightConst == self.buttonTotalWidth())
        {
            return
        }
        
        self.upperContentViewLeftConst.constant = (self.buttonTotalWidth() * -1) - self.kBounceValue
        self.upperContentViewRightConst.constant = self.buttonTotalWidth() + self.kBounceValue
        self.updateConstIfNeeded(animated, completion: {_ in
            self.upperContentViewLeftConst.constant = self.buttonTotalWidth() * -1
            self.upperContentViewRightConst.constant = self.buttonTotalWidth()
            
            self.updateConstIfNeeded(animated, completion: {_ in
                self.startingRightConst = self.upperContentViewRightConst.constant
            })
        })
        
    }
    
    func updateConstIfNeeded(animated:Bool, completion:(finished: Bool)-> Void)// open, close시 애니메이션 구현
    {
        var duration: Double = 0.0
        if animated
        {
            duration = 0.1
        }
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
            
            self.layoutIfNeeded()
            
            }, completion: completion)
        
    }
    
    func openCell()//외부에서 cell open func
    {
        self.setConstToShowAllButton(false, notifyDelegatedDidOpen: false)
    }
    
    
    @IBAction func hiddenButtonTouched(sender: AnyObject) {
        if sender as! UIButton == self.hiddenButton1
        {
            self.delegate?.firstButtonTouched(self.writType, comType: self.comType,data: self.data,index: self.cellIndex)
            
        }
        else if sender as! UIButton == self.hiddenButton2
        {
            self.delegate?.secondBUttonTouched(self.writType, comType: self.comType,data: self.data,index: self.cellIndex)
        }
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol SwipableCellButtonActionDelegate
{
    func firstButtonTouched(writeType:Int,comType:Int,data:JSON,index:NSIndexPath)
    func secondBUttonTouched(writeType:Int,comType:Int,data:JSON,index:NSIndexPath)
    func cellDidOpen(cell: UITableViewCell)
    func cellDidClose(index:NSIndexPath)
}