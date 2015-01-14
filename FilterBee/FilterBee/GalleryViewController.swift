//
//  GalleryViewController.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/12/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  var items = [UIImage]()
  var delegate : ImageSelectedDelegate?
  var collectionView : UICollectionView!
  //MARK: ViewControl LifeCycle
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    // setting up the collection view
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    var views = ["collectionView" : collectionView]
    rootView.addSubview(self.collectionView)
    self.setConstraintsOnRootView(rootView, forViews: views)
    // customizing the flow layout
    collectionViewFlowLayout.itemSize = CGSize(width: 260, height: 260)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    collectionViewFlowLayout.minimumInteritemSpacing = 8.0
    collectionViewFlowLayout.minimumLineSpacing = 8.0
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.backgroundColor = UIColor.lightGrayColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(GalleryViewCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
    if let image1 = UIImage(named: "image1.jpeg"){
      items.append(image1)
    }
    if let image2 = UIImage(named: "image2.jpeg"){
      items.append(image2)
    }
    if let image3 = UIImage(named: "image3.jpeg"){
      items.append(image3)
    }
    if let image4 = UIImage(named: "image4.jpeg"){
      items.append(image4)
    }
    if let image5 = UIImage(named: "image5.jpeg"){
      items.append(image5)
    }
    if let image6 = UIImage(named: "image6.jpeg"){
      items.append(image6)
    }
    
  }

  //MARK: CollectionViewDataSource
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryViewCell
    let image = items[indexPath.row]
    cell.imageView.image = image
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.items.count
  }
  //MARK: CollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // select the image
    let selectedImage = items[indexPath.row]
    delegate!.DelegatorDidSelectImage(selectedImage)
    // go back to main view
    self.navigationController?.popViewControllerAnimated(true)
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
