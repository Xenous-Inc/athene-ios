//
//  TutorialViewController.swift
//  testing
//
//  Created by Vadim on 14/04/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

var tutorial_vc = TutorialViewController()

class TutorialViewController: UIViewController, UIPageViewControllerDataSource, UINavigationControllerDelegate, UIPageViewControllerDelegate {
    
    @IBOutlet weak var container: UIView!
    
    var currentPageIndex:Int = 0
    var pageviewcontroller:UIPageViewController!
    var ViewControllers: [UIViewController] = [UIViewController]()
    
    var lastPendingViewControllerIndex = 0
    
    @IBOutlet weak var pager_view: CustomPageControl!
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = ViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard ViewControllers.count > previousIndex else {
            return nil
        }
        return ViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = ViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex + 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard ViewControllers.count > previousIndex else {
            return nil
        }
        return ViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        if pendingViewControllers.count > 0 {
            lastPendingViewControllerIndex = ViewControllers.index(of: pendingViewControllers.first!)!
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            currentPageIndex = lastPendingViewControllerIndex
            pager_view.moveTo(tab: currentPageIndex)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tutorial_vc = self
        print("Reached tutorial")
        
        pager_view.set(width: container.frame.width, height: 0.05*container.frame.height, tabs: tutorial_images.count, start: 0, color: UIColor.init(rgb: colors[2]))
        
        self.pageviewcontroller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageviewcontroller.dataSource = self
        self.pageviewcontroller.delegate = self
        self.pageviewcontroller.view.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        print(container.bounds.height, view.bounds.height)
        
        for i in 0..<tutorial_images.count{
            let vc = TutorialSegmentViewController(frame: pageviewcontroller.view.frame, image: tutorial_images[i], is_last: (i == tutorial_images.count - 1))
            ViewControllers.append(vc)
        }
        self.pageviewcontroller.setViewControllers([ViewControllers[0]], direction: .forward, animated: true, completion: nil)
        self.addChild(self.pageviewcontroller)
        container.addSubview(self.pageviewcontroller.view)
        self.pageviewcontroller.didMove(toParent: self)
    }

}
