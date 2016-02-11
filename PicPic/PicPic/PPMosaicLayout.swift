//
//  PPMosaicLayout.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 10..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

// columncount % interitemspacing != 0 일경우 에러 why?

import UIKit

enum PPMosaicCellSize
{
    case Big
    case Small
}

class PPMosaicLayout: UICollectionViewLayout {
    
    // default constants
    let kPPDefaultNumberOfColumnsInSection = 3
    let kPPDefaultCellSize = PPMosaicCellSize.Small
    let kPPDefaultHeaderFooterHeight: CGFloat = 0.0
    let kPPDefaultHeaderShouldOverlayContent = false
    let kPPDefaultFooterShouldOverlayContent = false
    
    var delegate: PPMosaicLayoutDelegate?
    

    var columnHeightsPerSection: Array<Array<CGFloat>>?
    var cellLayoutAttributes: Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>?
    var supplementaryLayoutAttributes: Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>?
    
    override func prepareLayout() {
        super.prepareLayout()
        
        self.resetLayoutState()
        //variables initialze
        
        
        if self.columnHeightsPerSection == nil
        {
            var newArray: Array<Array<CGFloat>> = []
            
            for index in 0..<self.collectionView!.numberOfSections()
            {
                var columnArray: Array<CGFloat> = []
                for _ in 0..<self.numberOfColumnsInSection(index)
                {
                    columnArray.append(0)
                }
                newArray.append(columnArray)
            }
            
            self.columnHeightsPerSection = newArray
        }

        if self.cellLayoutAttributes == nil
        {
            self.cellLayoutAttributes = [:]
        }
        
        if self.supplementaryLayoutAttributes == nil
        {
            self.supplementaryLayoutAttributes = [:]
        }
        
        // Calculate layout for each section
        for sectionIndex in 0 ..< self.collectionView!.numberOfSections()
        {
            let interitemSpacing = self.interitenSpacingAtSection(sectionIndex)
            
            // Add top section insets
            self.growColumnHeightsBy(self.insetsForSectionAtIndex(sectionIndex).top, section: sectionIndex)
            
            // Adds header view
            let headerLayoutAttributes = self.addLayoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, indexPath: NSIndexPath(forItem: 0, inSection: sectionIndex))
            if (!self.headerShouldOverlayContent())
            {
                self.growColumnHeightsBy(headerLayoutAttributes.frame.size.height + interitemSpacing, section: sectionIndex)
            }

            // Calculate Cell attributes in each section

            for cellIndex in 0 ..< self.collectionView!.numberOfItemsInSection(sectionIndex)
            {
                let cellIndexPath = NSIndexPath(forItem: cellIndex, inSection: sectionIndex)
                let mosaicCellSize = self.mosaicCellSizeForItemAtIndexPath(cellIndexPath)
                
                if mosaicCellSize == .Big
                {
                    let indicesOfShortestColumns = self.indexOfShortestColumnInSectionForBigCell(sectionIndex)
                    let layoutAttributes = self.addBigMosaicLayoutAttributesForIndexPath(cellIndexPath, inColumn: indicesOfShortestColumns)

                    
                    self.columnHeightsPerSection![sectionIndex][indicesOfShortestColumns] += layoutAttributes.frame.size.height + interitemSpacing
                    self.columnHeightsPerSection![sectionIndex][indicesOfShortestColumns + 1] += layoutAttributes.frame.size.height + interitemSpacing
                    
                    /*print("Added big cell")
                    print(self.columnHeightsPerSection![sectionIndex])
                    print("")*/
                }
                else if mosaicCellSize == .Small
                {
                    let indexOfShortestColumn = self.indexOfShortestColumnInSection(sectionIndex)
                    let layoutAttributes = self.addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath, inColumn: indexOfShortestColumn)

                    
                    self.columnHeightsPerSection![sectionIndex][indexOfShortestColumn] += layoutAttributes.frame.size.height + interitemSpacing
                    
                    /*print("Added small cell")
                    print(self.columnHeightsPerSection![sectionIndex])
                    print("")*/
                }
            }
            
            //Adds footer view
            let footerLayoutAttributes = self.addLayoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, indexPath: NSIndexPath(forItem: 1, inSection: sectionIndex))
            
            if (!self.footerShouldOverlayContent())
            {
                self.growColumnHeightsBy(footerLayoutAttributes.frame.size.height, section: sectionIndex)
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesInRect: Array<UICollectionViewLayoutAttributes> = []
        
        // Cells
        for (_, attributes) in self.cellLayoutAttributes!.enumerate()
        {
            if CGRectIntersectsRect(rect, attributes.1.frame)
            {
                attributesInRect.append(attributes.1)
            }
        }
        
        // Supplementary views
        for (_, attributes) in self.supplementaryLayoutAttributes!.enumerate()
        {
            if CGRectIntersectsRect(rect, attributes.1.frame)
            {
                attributesInRect.append(attributes.1)
            }
        }
        
        return attributesInRect
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cellLayoutAttributes![indexPath]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.supplementaryLayoutAttributes![indexPath]
    }
    
    override func collectionViewContentSize() -> CGSize {
        let width = self.collectionView!.bounds.width
        var height: CGFloat = 0.0
        
        for (secIndex, heights) in self.columnHeightsPerSection!.enumerate()
        {
            let indexOfTallesColumn = self.indexOfTallestColumnInSection(secIndex)
            height += heights[indexOfTallesColumn]
        }
        
        return CGSizeMake(width, height)
    }
    
    // Orientation
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        
        if(!CGSizeEqualToSize(oldBounds.size, newBounds.size))
        {
            self.prepareLayout()
            return true
        }
        return false
    }
    
    func resetLayoutState()
    {
        
        self.columnHeightsPerSection = nil
        self.cellLayoutAttributes = nil
        self.supplementaryLayoutAttributes = nil
    }
    
    // Layout Attributes Helpers
    
    func addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath: NSIndexPath, inColumn column: Int) -> UICollectionViewLayoutAttributes
    {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
        layoutAttributes.frame = self.mosaicCellRectWithSize(.Small, atIndexPath: cellIndexPath, inColumn: column)
        
        self.cellLayoutAttributes!.updateValue(layoutAttributes, forKey: cellIndexPath)
        
        return layoutAttributes
    }
    
    func addBigMosaicLayoutAttributesForIndexPath(cellIndexPath: NSIndexPath, inColumn column: Int) -> UICollectionViewLayoutAttributes
    {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
        layoutAttributes.frame = self.mosaicCellRectWithSize(.Big, atIndexPath: cellIndexPath, inColumn: column)
        
        self.cellLayoutAttributes!.updateValue(layoutAttributes, forKey: cellIndexPath)
        
        return layoutAttributes
    }
    
    func mosaicCellRectWithSize(mosaicCellSize: PPMosaicCellSize, atIndexPath cellIndexPath: NSIndexPath, inColumn column: Int) -> CGRect
    {
        let sectionIndex = cellIndexPath.section
        
        let cellHeight = self.cellHeightForMosaicSize(mosaicCellSize, section: sectionIndex)
        let cellWidth = cellHeight
        let columnHeight = self.columnHeightsPerSection![sectionIndex][column]
        
        var originX = CGFloat(column) * self.columnWidthInSection(sectionIndex)
        let originY = self.verticalOffsetForSection(sectionIndex) + columnHeight
        
        let sectionInset = self.insetsForSectionAtIndex(sectionIndex)
        let interitemSpacing = self.interitenSpacingAtSection(sectionIndex)
        
        originX += sectionInset.left
        originX += CGFloat(column) * interitemSpacing
        
        return CGRectMake(originX, originY, cellWidth, cellHeight)
    }
    
    func addLayoutAttributesForSupplementaryViewOfKind(kind: String, indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, withIndexPath: indexPath)
        
        let inset = self.insetsForSectionAtIndex(indexPath.section)
        let originX: CGFloat = inset.left
        var originY: CGFloat = self.verticalOffsetForSection(indexPath.section)
        let width: CGFloat = self.collectionViewContentSize().width - inset.left - inset.right
        var height: CGFloat = 0.0
        
        let tallestColumnIndex = self.indexOfTallestColumnInSection(indexPath.section)
        let sectionColumnHeight = self.columnHeightsPerSection![indexPath.section][tallestColumnIndex]
        
        if kind == UICollectionElementKindSectionHeader
        {
            height = self.heightForHeaderAtSection(indexPath.section)
        }
        else if kind == UICollectionElementKindSectionFooter
        {
            height = self.heightForFooterAtSection(indexPath.section)
            if self.footerShouldOverlayContent()
            {
                originY -= height
            }
        }
        
        layoutAttributes.frame = CGRectMake(originX, sectionColumnHeight + originY, width, height)
        layoutAttributes.zIndex = 1
        
        self.supplementaryLayoutAttributes![indexPath] = layoutAttributes
        
        return layoutAttributes
    }
    
    // Sizing Helpers
    
    func cellHeightForMosaicSize(mosaicCellSize: PPMosaicCellSize, section: Int) -> CGFloat
    {
        let smallCellHeight = self.columnWidthInSection(section)
        let interitemSpacing = self.interitenSpacingAtSection(section)
        
        return mosaicCellSize == .Big ? (smallCellHeight * 2.0) + interitemSpacing : smallCellHeight
    }
    
    func columnWidthInSection(section: Int) -> CGFloat
    {
        let inset = self.insetsForSectionAtIndex(section)
        let totalInteritemSpacing:CGFloat = CGFloat(self.numberOfColumnsInSection(section) - 1) * self.interitenSpacingAtSection(section)
        let totalColumnWidth = self.collectionViewContentSize().width - inset.left - inset.right - totalInteritemSpacing
        
        return totalColumnWidth / CGFloat(self.numberOfColumnsInSection(section))
    }
    
    func verticalOffsetForSection(section: Int) -> CGFloat
    {
        var verticalOffset: CGFloat = 0.0
        
        for index in 0..<section
        {
            let indexOfTallestColumn = self.indexOfShortestColumnInSection(index)
            let sectionHeight = self.columnHeightsPerSection![index][indexOfTallestColumn]
            verticalOffset += sectionHeight
        }
        
        return verticalOffset
    }
    
    func growColumnHeightsBy(increase: CGFloat, section: Int)
    {
        for index in 0..<self.columnHeightsPerSection![section].count
        {
            self.columnHeightsPerSection![section][index] += increase
        }
    }
    

    
    // Index Helpers
    func indexOfShortestColumnInSectionForBigCell(section: Int) -> Int{
        let columnHeights: Array<CGFloat> = self.columnHeightsPerSection![section]
        var twoFlatIndicesWithHeight: [Int : CGFloat] = [:]

        for index in 0..<columnHeights.count - 1
        {
            if columnHeights[index] == columnHeights[index + 1]
            {
                twoFlatIndicesWithHeight[index] = columnHeights[index]
            }
        }
        
        var smallestKey = twoFlatIndicesWithHeight.keys.first!
        
        for key in twoFlatIndicesWithHeight.keys
        {
            if key < smallestKey
            {
                smallestKey = key
            }
        }
        
        var indexOfShortestColumns = smallestKey
        
        for (key, height) in twoFlatIndicesWithHeight
        {
            if height < twoFlatIndicesWithHeight[indexOfShortestColumns]
            {
                indexOfShortestColumns = key
            }
        }

        
        return indexOfShortestColumns
    }
    
    func indexOfShortestColumnInSection(section: Int) -> Int{
        let columnHeights: Array<CGFloat> = self.columnHeightsPerSection![section]
        
        var indexOfShortestColumn = 0
        
        for index in 1..<columnHeights.count
        {
            if columnHeights[index]  < columnHeights[indexOfShortestColumn]
            {
                indexOfShortestColumn = index
            }
        }
        
        return indexOfShortestColumn
    }
    
    func indexOfTallestColumnInSection(section: Int) -> Int{
        let columnHeights: Array<CGFloat> = self.columnHeightsPerSection![section]
        
        var indexOfTallestColumn = 0
        
        for index in 1..<columnHeights.count
        {
            if columnHeights[index] > columnHeights[indexOfTallestColumn]
            {
                indexOfTallestColumn = index
            }
        }
        
        return indexOfTallestColumn
    }
    
    // Delegate Wrappers
    func numberOfColumnsInSection(section: Int) -> Int
    {
        var columnCount = kPPDefaultNumberOfColumnsInSection
        guard let newColumnCount = self.delegate?.collectionView(self.collectionView!, layout: self, numberOfColumnsInSection: section) else{
            return columnCount
        }
        columnCount = newColumnCount
        
        return columnCount
    }
    
    func mosaicCellSizeForItemAtIndexPath(indexPath: NSIndexPath) -> PPMosaicCellSize
    {
        var cellSize = kPPDefaultCellSize
        guard let newCellSize = self.delegate?.collectionView(self.collectionView!, layout: self, mosaicCellSizeForItemAtIndexPath: indexPath) else{
            return cellSize
        }
        cellSize = newCellSize
        
        return cellSize
    }
    
    func insetsForSectionAtIndex(section: Int) -> UIEdgeInsets
    {
        var inset = UIEdgeInsetsZero
        guard let newInset = self.delegate?.collectionView(self.collectionView!, layout: self, insetForSectionAtIndex: section) else{
            return inset
        }
        inset = newInset
        
        return inset
    }
    
    func interitenSpacingAtSection(section: Int) -> CGFloat
    {
        var interitemSpacing: CGFloat = 0.0
        guard let newinteritemSpacing = self.delegate?.collectionView(self.collectionView!, layout: self, interitemSpacingForSectionAtIndex: section) else{
            return interitemSpacing
        }
        interitemSpacing = newinteritemSpacing
        
        return interitemSpacing
    }
    
    func heightForHeaderAtSection(section: Int) -> CGFloat
    {
        var height = kPPDefaultHeaderFooterHeight
        guard let newHeight = self.delegate?.collectionView(self.collectionView!, layout: self, heightForHeaderInSection: section) else{
            return height
        }
        height = newHeight
        
        return height
    }
    
    func heightForFooterAtSection(section: Int) -> CGFloat
    {
        var height = kPPDefaultHeaderFooterHeight
        guard let newHeight = self.delegate?.collectionView(self.collectionView!, layout: self, heightForFooterInSection: section) else{
            return height
        }
        height = newHeight
        
        return height
    }
    
    func headerShouldOverlayContent() -> Bool
    {
        var shouldOverlay = kPPDefaultHeaderShouldOverlayContent
        guard let newBool = self.delegate?.headerShouldOverlayContentInCollectionView(self.collectionView!, layout: self) else{
            return shouldOverlay
        }
        shouldOverlay = newBool
        
        return shouldOverlay
    }
    
    func footerShouldOverlayContent() -> Bool
    {
        var shouldOverlay = kPPDefaultFooterShouldOverlayContent
        guard let newBool = self.delegate?.footerShouldOverlayContentInCollectionView(self.collectionView!, layout: self) else{
            return shouldOverlay
        }
        shouldOverlay = newBool
        
        return shouldOverlay
    }
}

protocol PPMosaicLayoutDelegate: UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, numberOfColumnsInSection section: Int) -> Int
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    //Header, Footer
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForHeaderInSection section: Int) -> CGFloat
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForFooterInSection section: Int) -> CGFloat
    
    func headerShouldOverlayContentInCollectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout) -> Bool
    
    func footerShouldOverlayContentInCollectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout) -> Bool
}

extension PPMosaicLayoutDelegate // alternative way to express optional func
{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath) -> PPMosaicCellSize{
        return .Small
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets    {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout, heightForFooterInSection section: Int) -> CGFloat{
        return 0.0
    }
    
    func headerShouldOverlayContentInCollectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout) -> Bool{
        return false
    }
    
    func footerShouldOverlayContentInCollectionView(collectionView: UICollectionView, layout collectionViewLayout: PPMosaicLayout) -> Bool{
        return false
    }
}

