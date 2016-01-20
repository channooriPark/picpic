//
//  HomeNativeViewController.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 12..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeNativeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PPMosaicLayoutDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "mainCell")
        
        
        let layout = PPMosaicLayout()
        layout.delegate = self
        self.collectionView.collectionViewLayout = layout
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("mainCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        /*if (indexPath.item % 6) == 0
        {
        
        }
        else
        {
            if (indexPath.item % 6) == 1 || (indexPath.item % 6) == 5
            {
                cell.backgroundColor = UIColor.blueColor()
            }
            if (indexPath.item % 6) == 2 || (indexPath.item % 6) == 4
            {
                cell.backgroundColor = UIColor.redColor()
            }
        }*/
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, numberOfColumnsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize {
        return (indexPath.item == 0 || indexPath.item == 7) ? .Big : .Small
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
