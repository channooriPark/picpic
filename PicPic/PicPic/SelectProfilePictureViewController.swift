//
//  SelectProfilePictureViewController.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 10. 14..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import CryptoSwift

class SelectProfilePictureViewController: UIViewController , UIAlertViewDelegate{

    
    @IBOutlet weak var profileImage: UIImageView!
    var uploadImage : UIImage!
    var imageToggle : Bool = false
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var language = NSLocale.preferredLanguages()[0]
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var completeButton: UIButton!
    var _ing : Bool = false
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.hidden = true
        backView.hidden = true
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        setData()
        
        completeButton.setTitle(self.appdelegate.ment["join_complete"].stringValue, forState: .Normal)
    }
    
    func setData(){
        let nation : NSArray = language.componentsSeparatedByString("-")
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let currentDate = formatter.stringFromDate(date)
        self.language = checkNational(nation[0] as! String)
        
        self.appdelegate.userData["register_form"].string = "10001"
        self.appdelegate.userData["regist_day"].string = currentDate
        self.appdelegate.userData["country"].string = self.language
        self.appdelegate.userData["profile_picture"].string = "noprofile.png"
        if self.appdelegate.standardUserDefaults.valueForKey("uuid") == nil {
            var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
            uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
            uuid = "iPhone"+uuid!+uuid!
            
            self.appdelegate.standardUserDefaults.setValue(uuid, forKey: "uuid")
            self.appdelegate.deviceId = uuid!
        }else {
            self.appdelegate.deviceId = self.appdelegate.standardUserDefaults.valueForKey("uuid")as! String
        }
        self.appdelegate.userData["device_id"].string = self.appdelegate.deviceId
        self.appdelegate.userData["push_token"].string = self.appdelegate.token as String
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Join(sender: AnyObject) {
        if _ing {
            return
        }
        
        
        _ing = true
        loading.startAnimating()
        backView.hidden = false
        if self.imageToggle {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let date = NSDate()
            let currentdate = formatter.stringFromDate(date)
            let filename = "\(self.appdelegate.userData["email"].string!)_\(currentdate).jpg"
//            print(filename)
            self.appdelegate.userData["profile_picture"].string = filename
            if self.profileImage.image != nil {
                let image = convert_profile_picture(self.profileImage.image!)
                myImageUploadRequest(image, filename: filename)
            }else {
                myImageUploadRequest(nil, filename: "noprofile.png")
            }
        }else{
            myfeed()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController")as! ViewController
            appdelegate.window?.rootViewController = viewController
        }
    }
    
    
    func checkNational(nation:String)->String{
        var language : String = ""
        if nation == "ko" {
            language = "ko_KR"
        }else if nation == "en" {
            language = "en_US"
        }else if nation == "zh" {
            language = "zh_CN"
        }else if nation == "ja" {
            language = "ja_JP"
        }
        return language
    }
    @IBAction func camera(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    

    @IBAction func libarary(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func myfeed(){
        let message : JSON = self.appdelegate.userData
        
        self.appdelegate.doIt(201, message: message) { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.appdelegate.email = self.appdelegate.userData["email"].string!
                
                if self.appdelegate.standardUserDefaults.objectForKey("id") == nil {
                    self.appdelegate.standardUserDefaults.setValue(self.enc(self.appdelegate.userData["email"].string!), forKey: "id")
                    self.appdelegate.standardUserDefaults.setValue(self.enc(self.appdelegate.userData["password"].string!), forKey: "password")
                    self.appdelegate.standardUserDefaults.setValue(self.enc("10001"), forKey: "register_form")
                    self.appdelegate.standardUserDefaults.synchronize()
                }
                self.appdelegate.controller.append(self.appdelegate.contentview)
//                self.appdelegate.contentview.index = self.appdelegate.controller.count-1
                self.appdelegate.contentview.type = "content"
                self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
                self.loading.stopAnimating()
                self.backView.hidden = true
            }else {
                if self.appdelegate.locale == "ko_KR" {
                    let alert = UIAlertView(title: "가입 실패", message: "다시 시도해 주세요", delegate: self, cancelButtonTitle: "확인")
                    alert.show()
                }else {
                    let alert = UIAlertView(title: "Join fail", message: "Sorry, Try again Join", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
        
    }
    
    
    
    let key: String = "secret0key000000"
    let iv: String = "0123456789012345"
    
    func enc(str: String) -> String
    {
        let encryptedBytes: [UInt8] = try! str.encrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let base64Enc = NSData(bytes: encryptedBytes).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return base64Enc
    }
    
    func dec(str: String) -> String
    {
        //let res: String = ""
        let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
        
        let count = decodedData!.length / sizeof(UInt8)
        var byteArray = [UInt8](count: count, repeatedValue: 0)
        decodedData!.getBytes(&byteArray, length:count * sizeof(UInt8))
        
        let decodeStr: [UInt8] = try! byteArray.decrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let data = NSData(bytes: decodeStr, length: Int(decodeStr.count))
        let res = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        return String(res!)
    }
    
    func convert_profile_picture(image: UIImage) -> UIImage {
        
        var image2:UIImage = cropToBounds(image, width: 1024,height: 1024)
        if(image.imageOrientation == UIImageOrientation.Right) {
            image2 = image2.imageRotatedByDegrees1(90.0)
            //print("image right")
        } else if(image.imageOrientation == UIImageOrientation.Left) {
            image2 = image2.imageRotatedByDegrees1(-90.0)
            //print("image left")
        } else if(image.imageOrientation == UIImageOrientation.Up) {
//            image2 = image2.imageRotatedByDegrees1(180.0)
            //print("image up")
        } else if(image.imageOrientation == UIImageOrientation.Down) {
            //print("image down")
        }
        
        if(true) {
            //return image2;
        }
        
        //        let size = CGSize(width: 1024, height: 1024)
        //        let image4: UIImage = resizeImage(image2, targetSize: size)
        
        return image2
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(heightRatio, heightRatio)
        } else {
            newSize = CGSizeMake(widthRatio,  widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, targetSize.width, targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        //let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)!
        
        let image:UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    
    
    
}


extension SelectProfilePictureViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.uploadImage = info[UIImagePickerControllerOriginalImage]as? UIImage
        let image = UIImage(CGImage: self.uploadImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
        profileImage.image = convert_profile_picture(image)
        profileImage.contentMode = .ScaleAspectFit
        self.imageToggle = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}



extension SelectProfilePictureViewController {
    func myImageUploadRequest(image: UIImage!, filename : String)
    {
        var state = false
        var imageData : NSData!
        if image != nil {
            imageData = UIImageJPEGRepresentation(image, 1)!
        }else {
            let imageURL = ImageURL()
            let url = NSURL(string: imageURL.imageurl("noprofile.png"))
            let data = NSData(contentsOfURL: url!)
            imageData = data
        }
        
        if(imageData==nil)  { return; }
//        NSLog("image data OK")
        let myUrl = NSURL(string: "http://gif.picpic.world/uploadToServerForPicPic.php");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        NSLog("Yes")
        
        
        
        request.HTTPBody = createBodyWithParameters(nil, filePathKey: "uploaded_file", imageDataKey: imageData!, boundary: boundary,filename: filename)
        
        self.loading.hidden = false
        self.loading.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
//                print("error=\(error)")
                return
            }
            
            // You can print out response object
//            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("****** response data = \(responseString!)")
            
            
            state = true
            if state {
                self.loading.stopAnimating()
                self.loading.hidden = true
                self.myfeed()
            }
            
            var err: NSError?
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            }catch{
//                print(error)
            }
            
            /*
            if let parseJSON = json {
            var firstNameValue = parseJSON["firstName"] as? String
            println("firstNameValue: \(firstNameValue)")
            }
            */
            
        }
        task.resume()
//        print("imageupload??")
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String,filename:String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
//        NSLog("body")
        return body
    }
    
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}















