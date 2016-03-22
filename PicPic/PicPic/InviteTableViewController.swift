//
//  InviteTableViewController.swift
//  PicPic
//
//  Created by Elea on 2016. 2. 15..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//


import UIKit
import FBSDKShareKit

class InviteTableViewController: UITableViewController, GIDSignInDelegate, GIDSignInUIDelegate, GINInviteDelegate {
    
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var ui_tblView: UITableView!
    
    @IBOutlet weak var ui_imvIconFb: UIImageView!
    
    @IBOutlet weak var ui_lblStateFb: UILabel!
    
    @IBOutlet weak var ui_imvInviteFb: UIImageView!
    
    @IBOutlet weak var ui_imvIconGg: UIImageView!
    
    @IBOutlet weak var ui_lblStateGg: UILabel!
    
    @IBOutlet weak var ui_imvInviteGg: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().signInSilently()
        
        if(GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            ui_lblStateGg.text = "연결됨"
            ui_imvIconGg.image = UIImage(named: "icon_find_google_s")
        }
        else {
            ui_lblStateGg.text = "연결안됨"
            ui_imvIconGg.image = UIImage(named: "icon_find_google")
        }
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            ui_lblStateFb.text = "연결됨"
            ui_imvIconFb.image = UIImage(named: "icon_find_facebook_s")
        }
        else {
            ui_lblStateFb.text = "연결안됨"
            ui_imvIconFb.image = UIImage(named: "icon_find_facebook")
        }
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if(GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            ui_lblStateGg.text = "연결됨"
            ui_imvIconGg.image = UIImage(named: "icon_find_google_s")
        }
        else {
            ui_lblStateGg.text = "연결안됨"
            ui_imvIconGg.image = UIImage(named: "icon_find_google")
        }
        
        // 앱내에서 로그인여부 판단(웹상으로 로그인이 되어있을경우 판단 불가)
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            ui_lblStateFb.text = "연결됨"
            ui_imvIconFb.image = UIImage(named: "icon_find_facebook_s")
        }
        else {
            ui_lblStateFb.text = "연결안됨"
            ui_imvIconFb.image = UIImage(named: "icon_find_facebook")
        }
    }
    
    func initValue() {
        
    }
    
    func initView() {
        
        if #available(iOS 9.0, *) {
            ui_tblView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0)
        {
            let content = FBSDKAppInviteContent();
            content.appLinkURL = NSURL(string: "https://fb.me/1670205073228596");
            FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self);
        }
        else
        {
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            
            if(GIDSignIn.sharedInstance().hasAuthInKeychain())
            {
                let invite = GINInvite.inviteDialog()
                GINInvite.inviteDialog().setInviteDelegate(self);
                invite.setMessage("Message")
                invite.setTitle("Title")
                invite.setDeepLink("/invite")
                //invite.setCustomImage("https://example.com/myapp.png")
                //invite.setCallToAc	tionText("Try it!")
                
                invite.open()
            }
            else
            {
                GIDSignIn.sharedInstance().signIn();
            }
        }
    }
    
    func inviteFinishedWithInvitations(invitationIds: [AnyObject]!, error: NSError!) {
        
        // 성공
        if (error == nil) {
            print("Invitations sent")
        }
            // 실패
        else {
            print("Failed: " + error.localizedDescription)
        }
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error != nil)
        {
            print("\(error.localizedDescription)")
        }
        
        toggleAuthUI()
    }
    
    func toggleAuthUI() {
        if (!GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            GIDSignIn.sharedInstance().signIn();
        }
    }
}


extension InviteTableViewController: FBSDKAppInviteDialogDelegate
{
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!)
    {
        if(results != nil)
        {
            // 성공
            print(results);
        }
        
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
        // 실패
        print(error);
    }
}