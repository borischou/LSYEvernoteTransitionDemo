//
//  EvernoteTransition.swift
//  evernote
//
//  Created by 梁树元 on 10/31/15.
//  Copyright © 2015 com. All rights reserved.
//

import UIKit

class EvernoteTransition: NSObject,UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate,NoteViewControllerDelegate {
    internal var isPresent = true
    var selectCell:CollectionViewCell = CollectionViewCell()
    var visibleCells = [CollectionViewCell]()
    var originFrame:CGRect = CGRectZero
    var finalFrame:CGRect = CGRectZero
    var panViewController = UIViewController()
    var listViewController = UIViewController()
    var interactionController = UIPercentDrivenInteractiveTransition()

    func EvernoteTransitionWith(selectCell selectCell:CollectionViewCell, visibleCells:[CollectionViewCell], originFrame:CGRect, finalFrame:CGRect, panViewController:UIViewController, listViewController:UIViewController) {
        self.selectCell = selectCell
        self.visibleCells = visibleCells
        self.originFrame = originFrame
        self.finalFrame = finalFrame
        self.panViewController = panViewController
        self.listViewController = listViewController
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePanGesture:")
        pan.edges = UIRectEdge.Left
        self.panViewController.view.addGestureRecognizer(pan)
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.45
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //获取转场完成后要呈现的VC
        let nextVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        //设置转场背景色
        transitionContext.containerView()?.backgroundColor = BGColor
        
        //根据标志位设置点击的cell的frame
        selectCell.frame = isPresent ? originFrame : finalFrame
        
        //获取转场完成后VC的view
        let addView = nextVC?.view
        
        //根据标志位设置view是否隐藏
        addView!.hidden = isPresent ? true : false
        
        //把转场后的view添加为容器view的子view
        transitionContext.containerView()?.addSubview(addView!)
        
        //根据标志为设置依赖
        let removeCons = isPresent ? selectCell.labelLeadCons : selectCell.horizonallyCons
        let addCons = isPresent ? selectCell.horizonallyCons : selectCell.labelLeadCons
        selectCell.removeConstraint(removeCons)
        selectCell.addConstraint(addCons)
        
        //设置转场动画
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            //处理屏幕显示的所有cell
            for visibleCell:CollectionViewCell in self.visibleCells
            {
                //处理除了点击的cell之外的cell
                if visibleCell != self.selectCell
                {
                    var frame = visibleCell.frame
                    
                    //令点击的cell以上的cell向上移动
                    if visibleCell.tag < self.selectCell.tag
                    {
                        //
                        let yDistance = self.originFrame.origin.y - self.finalFrame.origin.y + 30
                        
                        //
                        let yUpdate = self.isPresent ? yDistance : -yDistance
                        frame.origin.y -= yUpdate
                    }
                    //令点击的cell以下的cell向下移动
                    else if visibleCell.tag > self.selectCell.tag
                    {
                        let yDistance = CGRectGetMaxY(self.finalFrame) - CGRectGetMaxY(self.originFrame) + 30
                        let yUpdate = self.isPresent ? yDistance : -yDistance
                        frame.origin.y += yUpdate
                    }
                    visibleCell.frame = frame
                    visibleCell.transform = self.isPresent ? CGAffineTransformMakeScale(0.8, 1.0):CGAffineTransformIdentity
                }
            }
            self.selectCell.backButton.alpha = self.isPresent ? 1.0 : 0.0
            self.selectCell.titleLine.alpha = self.isPresent ? 1.0 : 0.0
            self.selectCell.textView.contentOffset = CGPointMake(0, 0)
            self.selectCell.textView.alpha = self.isPresent ? 1.0 : 0.0
            self.selectCell.frame = self.isPresent ? self.finalFrame : self.originFrame
            self.selectCell.layoutIfNeeded()
            }) { (stop) -> Void in
                addView!.hidden = false
                transitionContext.completeTransition(true)
        }

    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.isPresent = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.isPresent = false
        return self
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        self.isPresent = false
        return interactionController
    }
    
    func handlePanGesture(recognizer:UIScreenEdgePanGestureRecognizer)
    {
        //获取转场后view
        let view = panViewController.view
        
        //手势开始（手指触摸）
        if recognizer.state == UIGestureRecognizerState.Began
        {
            panViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
            
        //手势改变（手指正在滑动）
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            //translationInView()返回的是手指在传入的view的bounds里的坐标（尽管view可能是在不断变换大小）
            let translation = recognizer.translationInView(view)
            
            //由于是右滑返回，因此不考虑y方向，只考虑x方向滑动的量与view变化的宽度的比例值
            let d = fabs(translation.x / CGRectGetWidth(view.bounds))
            
            //根据比例值更新转场的进度
            interactionController.updateInteractiveTransition(d)
        }
        
        //手势完成（手指离开）
        else if recognizer.state == UIGestureRecognizerState.Ended
        {
            //若速度是正值则直接完成转场返回
            if recognizer.velocityInView(view).x > 0
            {
                interactionController.finishInteractiveTransition()
            }
            //否则取消转场返回重新转场到当前view
            else
            {
                interactionController.cancelInteractiveTransition()
                listViewController.presentViewController(panViewController, animated: false, completion: { () -> Void in
                    
                })
            }
            interactionController = UIPercentDrivenInteractiveTransition()
        }
    }
    
    // MARK: NoteViewControllerDelegate
    func didClickGoBack()
    {
        panViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        interactionController.finishInteractiveTransition()
    }
    
}
