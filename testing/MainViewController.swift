//
//  MainViewController.swift
//  testing
//
//  Created by Vadim on 28/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit
import os
import Firebase

class MainViewController: UIViewController, UIPageViewControllerDataSource, UINavigationControllerDelegate, UIPageViewControllerDelegate {
    
    var currentPageIndex:Int = 0 // holds the current page index
    var pageviewcontroller:UIPageViewController! // self explanatory
    var ViewControllers: [UIViewController] = [UIViewController]()
    
    var lastPendingViewControllerIndex = 0
    
    let pager_view = CustomPageControl()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.isFirstLaunch()){
            //Run tutorial
            //return
        }
        if(Auth.auth().currentUser == nil){
            os_log("Signing out...")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "signing_out", sender: self)
            }
            return
        }
        
        pager_view.set(width: self.view.frame.width, height: 0.05*self.view.frame.height, tabs: 2)
        pager_view.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - pager_view.frame.height / 2)
        view.addSubview(pager_view)
        
        self.pageviewcontroller = (self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController)
        self.pageviewcontroller.dataSource = self
        self.pageviewcontroller.delegate = self
        ViewControllers.append(ViewController())
        ViewControllers.append(NewWordViewController())
        if let firstViewController = ViewControllers.first {
                self.pageviewcontroller.setViewControllers([firstViewController],
                                direction: .forward,
                                animated: true,
                                completion: nil)
        }
            
        self.pageviewcontroller.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-pager_view.frame.height)
        self.addChild(pageviewcontroller)
        self.view.addSubview(pageviewcontroller.view)
        self.pageviewcontroller.didMove(toParent: self)
        print(ViewControllers.count)
    }
    
}
