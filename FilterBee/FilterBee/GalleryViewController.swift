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
  
  let collectionViewFlowLayout = UICollectionViewFlowLayout()
  
  var pinchRecognizer : UIPinchGestureRecognizer!
  
  //MARK: ViewControl LifeCycle
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    
    // setting up the collection view
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    var views = ["collectionView" : collectionView]
    rootView.addSubview(self.collectionView)
    self.setConstraintsOnRootView(rootView, forViews: views)
    
    // customizing the flow layout
    collectionViewFlowLayout.itemSize = CGSize(width: 260, height: 260)
    collectionViewFlowLayout.scrollDirection = .Vertical
    collectionViewFlowLayout.minimumInteritemSpacing = 8.0
    collectionViewFlowLayout.minimumLineSpacing = 8.0
    
    // gesture recognizer setup

    
    // final
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //set up pinch gesture
    self.pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
    collectionView.addGestureRecognizer(pinchRecognizer)
    
    self.collectionView.backgroundColor = UIColor.lightGrayColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(GalleryViewCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
    if let image1 = UIImage(named: "boatsbig.jpeg"){
      items.append(image1)
    }
    if let image2 = UIImage(named: "carbig.jpeg"){
      items.append(image2)
    }
    if let image3 = UIImage(named: "bootbig.jpeg"){
      items.append(image3)
    }
    if let image4 = UIImage(named: "oceanbig.jpeg"){
      items.append(image4)
    }
    if let image5 = UIImage(named: "docksbig.jpeg"){
      items.append(image5)
    }
    if let image6 = UIImage(named: "mistsbig.jpeg"){
      items.append(image6)
    }
    
  }
  
  //MARK: Pinch Gesture
  func pinchGesture(sender: UIPinchGestureRecognizer){
    
    switch sender.state{
    case .Began:
      println("began pinch")
    case .Changed:
      println("changing")
    case .Ended:
      println("ended pinch")
      // if we are currently zoomed out, zoom in
      if self.collectionViewFlowLayout.itemSize.height < 400.0 {
        self.collectionView.performBatchUpdates({ () -> Void in
          if sender.velocity > 0 {
            //increase item size
            let bigsize = CGSize(width: self.collectionViewFlowLayout.itemSize.width * 2, height: self.collectionViewFlowLayout.itemSize.height * 2)
            self.collectionViewFlowLayout.itemSize = bigsize
          }
        }, completion: { (finished) -> Void in
          // ??
        })
      }else if collectionViewFlowLayout.itemSize.height > 20.0 {
        self.collectionView.performBatchUpdates({ () -> Void in
            if sender.velocity < 0 {
            let smallsize = CGSize(width: self.collectionViewFlowLayout.itemSize.width / 2, height: self.collectionViewFlowLayout.itemSize.height / 2)
            self.collectionViewFlowLayout.itemSize = smallsize
            //decrease item size
          }
          }, completion: { (finished) -> Void in
            // ??
        })

      }
    default:
      println("default case")
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
