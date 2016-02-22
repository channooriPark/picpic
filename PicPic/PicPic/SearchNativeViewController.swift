//
//  SearchNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 2. 8..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit

class SearchNativeViewController: UIViewController, UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var tagButtonEnableView: UIView!
    @IBOutlet weak var userButtonEnableView: UIView!
    @IBOutlet weak var contentView: UIView!

    
    var statusbar: UIView!
    var userTable: SearchUserViewController?
    var tagTable: SearchTagViewController?
    var hotUser: SearchHotUserViewController?
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.placeholder = self.appdelegate.ment["search_tag"].stringValue
        tagButton.setTitle(self.appdelegate.ment["interest_search_tag"].stringValue, forState: .Normal)
        userButton.setTitle(self.appdelegate.ment["interest_search_user"].stringValue, forState: .Normal)

        self.statusbar = UIView()
        self.statusbar.frame = UIApplication.sharedApplication().statusBarFrame
        self.statusbar.backgroundColor = UIColor(netHex: 0x484848)
        self.view.addSubview(statusbar)


        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func tagButtonTouched() {
        self.userTable?.view.removeFromSuperview()
        self.userTable = nil
        self.hotUser?.view.removeFromSuperview()
        self.hotUser = nil
        
        let enabledColor = Config.getInstance().color //UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        
        self.tagButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        
        self.tagButton.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
        self.userButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        
        self.tagButtonEnableView.backgroundColor = enabledColor
        self.userButtonEnableView.backgroundColor = UIColor(netHex: 0xE8E5F2)
        
        self.searchBar.placeholder = self.appdelegate.ment["search_tag"].stringValue
    }
    @IBAction func userButtonTouched()
    {
        self.tagTable?.view.removeFromSuperview()
        self.tagTable = nil
        
        if self.searchBar.text!.isEmpty
        {
            if self.hotUser == nil
            {
                self.hotUser = SearchHotUserViewController()
            }
            self.hotUser!.view.frame = self.contentView.frame
            self.addChildViewController(self.hotUser!)
            self.view.addSubview(self.hotUser!.view)
        }
        
        let enabledColor = Config.getInstance().color //UIColor(red: 148/255, green: 158/255, blue: 241/255, alpha: 1.0)
        
        self.tagButton.setTitleColor(UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0), forState: .Normal)
        self.userButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.tagButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.userButton.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
        
        self.tagButtonEnableView.backgroundColor = UIColor(netHex: 0xE8E5F2)
        self.userButtonEnableView.backgroundColor = enabledColor
        
        self.searchBar.placeholder = self.appdelegate.ment["search_user"].stringValue
    }
    @IBAction func backButtonTouched()
    {
        self.appdelegate.tabbar.view.hidden = false
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty
        {
            if self.tagButtonEnableView.backgroundColor == UIColor(netHex: 0xE8E5F2) //user
            {
                self.tagTable?.view.removeFromSuperview()
                self.tagTable = nil
                self.hotUser?.view.removeFromSuperview()
                self.hotUser = nil
                if self.userTable == nil
                {
                    self.userTable = SearchUserViewController()
                }
                self.userTable!.setTableWithNewString(searchText)
                self.userTable!.view.frame = self.contentView.frame
                self.addChildViewController(self.userTable!)
                self.view.addSubview(self.userTable!.view)
            }
            else //tag
            {
                self.userTable?.view.removeFromSuperview()
                self.userTable = nil
                self.hotUser?.view.removeFromSuperview()
                self.hotUser = nil
                if self.tagTable == nil
                {
                    self.tagTable = SearchTagViewController()
                }
                self.tagTable!.setTableWithNewString(searchText)
                self.tagTable!.view.frame = self.contentView.frame
                self.addChildViewController(tagTable!)
                self.view.addSubview(tagTable!.view)
            }
        }
        else// 빈화면, hot user
        {
            self.tagTable?.view.removeFromSuperview()
            self.userTable?.view.removeFromSuperview()
            self.tagTable = nil
            self.userTable = nil
            
            if self.tagButtonEnableView.backgroundColor == UIColor(netHex: 0xE8E5F2) //hot
            {
                if self.hotUser == nil
                {
                    self.hotUser = SearchHotUserViewController()
                }
                self.hotUser!.view.frame = self.contentView.frame
                self.addChildViewController(self.hotUser!)
                self.view.addSubview(self.hotUser!.view)
            }
            else
            {
                self.hotUser?.view.removeFromSuperview()
                self.hotUser = nil
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
}
