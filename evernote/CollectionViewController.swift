//
//  CollectionViewController.swift
//  evernote
//
//  Created by 梁树元 on 10/12/15.
//  Copyright © 2015 com. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let topPadding:CGFloat = 20
public let BGColor = UIColor(red: 56.0/255.0, green: 51/255.0, blue: 76/255.0, alpha: 1.0)

class CollectionViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource
{
    private let colorArray = NSMutableArray()
    private let rowNumber = 15
    private let customTransition = EvernoteTransition()
    private let collectionView = UICollectionView(frame: CGRectMake(0, topPadding, screenWidth, screenHeight - topPadding), collectionViewLayout: CollectionViewLayout())
    
    var a = 2, b = 0, c = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = BGColor
        collectionView.backgroundColor = BGColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, verticallyPadding, 0);

        self.view.addSubview(collectionView)
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        let random = arc4random() % 360 // 160 arc4random() % 360
        for index in 0 ..< rowNumber
        {
            let color = UIColor(hue: CGFloat((Int(random) + index * 6)) % 360.0 / 360.0, saturation: 0.8, brightness: 1.0, alpha: 1.0)
            colorArray.addObject(color)
        }
        
        self.f1()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.f2()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSLog("a: \(self.a)")
            })
        }
    }
    
    func f1()
    {
        self.a = self.a * 2
        self.a = self.b
    }
    
    func f2()
    {
        self.c = self.a + 11
        self.a = self.c
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return colorArray.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = colorArray.objectAtIndex(colorArray.count - 1 - indexPath.section) as? UIColor
        cell.titleLabel.text = "Notebook + " + String(indexPath.section + 1)
        cell.titleLine.alpha = 0.0
        cell.textView.alpha = 0.0
        cell.backButton.alpha = 0.0
        cell.tag = indexPath.section
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        let visibleCells = collectionView.visibleCells() as! [CollectionViewCell]
        let storyBoard = UIStoryboard(name: "evernote", bundle: nil)
        let viewController = storyBoard.instantiateViewControllerWithIdentifier("Note") as! NoteViewController
        viewController.titleName = cell.titleLabel.text!
        viewController.domainColor = cell.backgroundColor!

        let finalFrame = CGRectMake(10, collectionView.contentOffset.y + 10, screenWidth - 20, screenHeight - 40)
        self.customTransition.EvernoteTransitionWith(selectCell: cell, visibleCells: visibleCells, originFrame: cell.frame, finalFrame: finalFrame, panViewController:viewController, listViewController: self)
        viewController.transitioningDelegate = self.customTransition
        viewController.delegate = self.customTransition
        self.presentViewController(viewController, animated: true) { () -> Void in
        }
    }

}
