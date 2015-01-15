//
//  PhotoAssetsViewController.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/14/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit
import Photos

class PhotoAssetsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var fetchArray : PHFetchResult!
  var assetCollection : PHAssetCollection!
  var imageManager = PHCachingImageManager()
  
  var collectionView : UICollectionView!
  
  var delegate : ImageSelectedDelegate?
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    
    let flowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: flowLayout)
    flowLayout.estimatedItemSize = CGSize(width: 100.0, height: 100.0)
    self.collectionView.backgroundColor = UIColor.darkGrayColor()
    
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(collectionView)
    let views = ["collectionView" : collectionView]
    
    setConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    collectionView.registerClass(GalleryViewCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")
    
    self.fetchArray = PHAsset.fetchAssetsWithOptions(nil)
    
  }
  
//MARK: CollectionViewDataSource
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryViewCell
    let asset = fetchArray[indexPath.row] as PHAsset
    
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      cell.imageView.image = requestedImage
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.fetchArray.count
  }
  
//MARK: CollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = fetchArray[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      self.delegate?.DelegatorDidSelectImage(requestedImage)
      self.navigationController?.popViewControllerAnimated(true)
    }

  }
  
  //MARK: AutoLayout Constraints
  func setConstraintsOnRootView(rootview: UIView, forViews views : [String : AnyObject]){
    // collectionView constraints
    let collectionViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[collectionView]-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewVerticalConstraint)
    let collectionViewHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewHorizontalConstraint)
    
  }
}