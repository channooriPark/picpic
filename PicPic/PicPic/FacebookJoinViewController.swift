//
//  FacebookJoinViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 3..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import CryptoSwift

class FacebookJoinViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var profileImage: UIImageView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var filename : String!
    var imageToggle = false
    var uploadImage : UIImage!
    @IBOutlet weak var completeButton: UIButton!
    let log = LogPrint()
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageData : NSData!
        let urlString = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/picture?type=large&return_ssl_resources=1)"
        let url = NSURL(string: urlString)
        imageData = NSData(contentsOfURL: url!)
        profileImage.image = UIImage(data: imageData)
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        completeButton.setTitle(self.appdelegate.ment["join_complete"].stringValue, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancle(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func gallery(sender: AnyObject) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            let alertCamera = UIAlertView(title: "", message: "해당 디바이스에 카메라가 없습니다.", delegate:self, cancelButtonTitle: "확인")
            alertCamera.show()
        }
    }
    
    @IBAction func camera(sender: AnyObject) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            let alertCamera = UIAlertView(title: "", message: "해당 디바이스에 카메라가 없습니다.", delegate:self, cancelButtonTitle: "확인")
            alertCamera.show()
        }
    }
    @IBAction func join(sender: AnyObject) {
        if self.profileImage.image != nil {
            log.log("image not nil")
            self.backView.hidden = false
            self.loading.startAnimating()
            let image = convert_profile_picture(self.profileImage.image!)
            myImageUploadRequest(image, filename: filename)
        }else {
            myImageUploadRequest(nil, filename: "noprofile.png")
        }
//        let connection = URLConnection(serviceCode: 201, message: self.appdelegate.userData)
//        let readData = connection.connection()
        log.log("\(self.appdelegate.userData)")
        self.appdelegate.doIt(201, message: self.appdelegate.userData) { (readData) -> () in
            if readData["msg"].string! == "success" {
                self.log.log("success")
                self.appdelegate.email = self.appdelegate.userData["email"].string!
                self.appdelegate.standardUserDefaults.setValue(self.enc(FBSDKAccessToken.currentAccessToken().userID), forKey: "id")
                self.appdelegate.standardUserDefaults.setValue(self.enc(FBSDKAccessToken.currentAccessToken().userID), forKey: "password")
                self.appdelegate.standardUserDefaults.setValue(self.enc("10002"), forKey: "register_form")
                self.appdelegate.standardUserDefaults.synchronize()
                self.appdelegate.controller.append(self.appdelegate.contentview)
//                self.appdelegate.contentview.index = self.appdelegate.controller.count-1
                self.appdelegate.contentview.type = "content"
                self.appdelegate.window?.rootViewController = self.appdelegate.testNavi
            }else {
//                print("aaa")
                self.log.log("fail")
                self.backView.hidden = true
                self.loading.stopAnimating()
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
        let res = try! NSString(data: data, encoding: NSUTF8StringEncoding)
        
        return String(res!)
    }
    
    
    

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.uploadImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        profileImage.contentMode = .ScaleAspectFit
        profileImage.image = convert_profile_picture(self.uploadImage)
        self.imageToggle = true
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let myUrl = NSURL(string: "http://gif.picpic.world/uploadToServerForPicPic.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createBodyWithParameters(nil, filePathKey: "uploaded_file", imageDataKey: imageData, boundary: boundary)
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
            
            
            
            self.backView.hidden = true
            self.loading.stopAnimating()
            
            
            var err: NSError?
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            }catch{
//                print(error)
            }
        }
        task.resume()
        
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
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
        return body
    }
    
    
}
