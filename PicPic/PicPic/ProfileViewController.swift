//
//  ViewController.swift
//  createAniGIF
//
//  Created by Shawn Chun on 2015. 11. 3..
//  Copyright © 2015년 shawn. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var picker: UIImagePickerController?
    var _hud: MBProgressHUD?
    
    // 카메라 버튼 눌렀을 때
    @IBAction func moveCamera(sender: UIButton) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraVC = self.storyboard?.instantiateViewControllerWithIdentifier("cameraVC") as? CameraViewController
            self.navigationController?.pushViewController(cameraVC!, animated: true)
        }
        else {
            let alertCamera = UIAlertView(title: "", message: "해당 디바이스에 카메라가 없습니다.", delegate:self, cancelButtonTitle: "확인")
            alertCamera.show()
        }
    }
    
    // 완료 버튼 눌렀을 때
    @IBAction func sendData(sender: UIButton) {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let path_profile = dir.stringByAppendingPathComponent("profile.png")
            if let data_profile = NSData(contentsOfFile: path_profile) {
                controlLoading(true)
                let upload_url = "http://www.shockw.co.kr/getFile.php"
                let parameters = [
                    "": ""
                ]
                let request = urlRequestWithComponents(upload_url, parameters: parameters, imageData: data_profile)
//                print(request.0.URLRequest.URLString)
                Alamofire1.manager.upload(request.0, data: request.1)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                        print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                    }
                    .responseJSON(completionHandler: { (request, response, data, error) in
                        self.dispatch_async_global {
                            if error != nil {
//                                print("error: \(error!)")
                            }
                            self.dispatch_async_main {
                                let alert_ok = UIAlertView.init(title: "", message: self.appdelegate.ment["profile_complete"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                                alert_ok.show()
                                self.controlLoading(false)
                            }
                        }
                    })
            }
            else {
                let alert_no = UIAlertView.init(title: "", message: self.appdelegate.ment["profile_nopicture"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                alert_no.show()
            }
        }
    }
    
    // 파일 업로드 관련 데이터
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        mutableURLRequest.timeoutInterval = 60
        mutableURLRequest.HTTPMethod = "POST"
        let lineEnd = "\r\n"
        let twoHyphens = "--"
        let boundaryConstant = "Boundary-animated_gif"
        mutableURLRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        mutableURLRequest.setValue("multipart/form-data; boundary=\(boundaryConstant)", forHTTPHeaderField: "Content-Type")
        //post data
        let uploadData: NSMutableData = NSMutableData()
        uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(lineEnd)")
        // add params (all params are strings)
        for (key, value) in parameters {
            if value != "" {
                uploadData.appendString("Content-Disposition: form-data; name=\"\(key)\"\(lineEnd)\(lineEnd)")
                uploadData.appendString("\(value)\(lineEnd)")
                uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(lineEnd)")
//                print("\(key): \(value)")
            }
        }
        //data
        let nowDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        uploadData.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image_\(dateFormatter.stringFromDate(nowDate)).png\"\(lineEnd)\(lineEnd)")
        //        uploadData.appendString("Content-Type: image/jpeg\r\n\r\n")
        uploadData.appendData(imageData)
        uploadData.appendString("\(lineEnd)")
        uploadData.appendString("\(twoHyphens)\(boundaryConstant)\(twoHyphens)\(lineEnd)")
        //set body
        mutableURLRequest.HTTPBody = uploadData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    // 갤러리 버튼 눌렀을 때
    @IBAction func chooseProfile(sender: UIButton) {
        picker = UIImagePickerController()
        picker!.delegate = self
        picker!.allowsEditing = false
        picker!.sourceType = .PhotoLibrary
        picker!.mediaTypes = [kUTTypeImage as String]
        if let _: AnyClass = NSClassFromString("UIPopoverPresentationController") {
            picker!.popoverPresentationController?.sourceView = self.view
            picker!.popoverPresentationController?.sourceRect = self.view.frame
        }
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    // 라이브러리에서 이미지를 선택 했을 때
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        print("didFinishPickingMediaWithInfo: \(info.description)")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let pngData = UIImagePNGRepresentation(pickedImage)! as NSData
            if let dir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
                let path_profile = dir.stringByAppendingPathComponent("profile.png")
                pngData.writeToFile(path_profile, atomically: true)
            }
            profileImage.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        changeProfileGIF()
        
        // 로딩중 표시
        _hud = MBProgressHUD()
        _hud!.mode = MBProgressHUDModeIndeterminate
        view.addSubview(_hud!)
        controlLoading(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 프로필 사진에서 바꿔주는 메소드
    func changeProfileGIF() {
        var profile: UIImage = UIImage(named: "profile_sample")!
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let path_profile = dir.stringByAppendingPathComponent("profile.png")
            if let data_profile = NSData(contentsOfFile: path_profile) {
                profile = UIImage(data: data_profile)!
            }
        }
        profileImage.image = profile
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 메인 인디케이터 호출해주는 메소드
    func controlLoading(val: Bool) {
        if val {
            _hud!.show(true)
        }
        else {
            _hud!.hide(true)
        }
    }
    
    func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}