//
//  ArchiveViewController.swift
//  testing
//
//  Created by Vadim on 17/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase

class ArchiveViewController: UIViewController{
    

    var frame: CGRect? = nil
    var bottom_bar_btns: [UIView] = []
    
    var current_tab = 0
    var views: [UIView] = [UIView(), UIView()]
    
    var bottom_bar = UIView()
    
    init(frame: CGRect)   {
        print("init nibName style")
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
    }

    // note slightly new syntax for 2017
    required init?(coder aDecoder: NSCoder) {
        print("init coder style")
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        let pd = 0.02*view.bounds.width
        bottom_bar = UIView(frame: CGRect(x: 0, y: 0.9*view.bounds.height, width: view.bounds.width, height: 0.1*view.bounds.height))
        for i in 0..<2{
            let width = view.bounds.width / 3
            let btn = Button(frame: CGRect(x: CGFloat(i+1)*pd + CGFloat(i)*width, y: pd, width: width, height: bottom_bar.bounds.height - 2*pd))
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.white.cgColor
            btn.layer.cornerRadius = btn.bounds.height / 2
            btn.setTitle((i == 0) ? categories_title : archive_title, for: .normal)
            let f_sz = FontHelper().getFontSize(strings: [categories_title, archive_title], font: "Helvetica", maxFontSize: 120, width: 0.8*btn.bounds.width, height: 0.9*btn.bounds.height)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.titleLabel?.font = UIFont(name: "Helvetica", size: CGFloat(f_sz))
            btn.tag = i
            if(i == 0){
                btn.backgroundColor = UIColor.init(white: 1, alpha: 0.4)
            }
            btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchView(gesture:))))
            bottom_bar.addSubview(btn)
            bottom_bar_btns.append(btn)
        }
        view.addSubview(bottom_bar)
        
        self.view.addSubview(views[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let subview = view.viewWithTag(10){
            subview.removeFromSuperview()
        }
        if let subview = view.viewWithTag(20){
            subview.removeFromSuperview()
        }

        let wasDescriptionOpened =
                (views[0] as? CategoryView) != nil &&
                ((views[0] as! CategoryView).descriptionView != nil) &&
                categories.firstIndex(where: { $0.title == (views[0] as! CategoryView).descriptionView!.title }) != nil &&
                categories.firstIndex(where: { $0.title == (views[0] as! CategoryView).descriptionView!.title })!.words.count > 0
        var titleOfOpenedDescription = ""
        if(wasDescriptionOpened){
            titleOfOpenedDescription = (views[0] as! CategoryView).descriptionView!.title
        }

        var titleOfOpenedCell: String? = nil
        if (views[0] as? CategoryView) != nil{
            for cell in (views[0] as! CategoryView).cells{
                if(cell.opened){
                    titleOfOpenedCell = cell.title
                    break
                }
            }
        }

        let v = CategoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - bottom_bar.bounds.height), content: categories)

        var cellToOpen: CategoryViewCell? = nil
        for cell in v.cells{
            cell.deleteButton.addTarget(self, action: #selector(deleteCategory(sender:)), for: .touchUpInside)
            cell.learnButton.addTarget(self, action: #selector(learnCategory(sender:)), for: .touchUpInside)
            cell.shareButton.addTarget(self, action: #selector(shareCategory(sender:)), for: .touchUpInside)
            cell.infoButton.addTarget(self, action: #selector(inspectCategory(sender:)), for: .touchUpInside)
            if(cell.title == titleOfOpenedCell){
                cellToOpen = cell
            }
        }

        if let cellToOpen = cellToOpen{
            v.openCell(cellToOpen: cellToOpen)
        }

        if(wasDescriptionOpened){
            v.mainView.removeFromSuperview()
            v.descriptionView = CategoryDescriptionView(
                    frame: v.mainView.frame,//CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height),
                    name: titleOfOpenedDescription,
                    words: categories.first(where: { $0.title == titleOfOpenedDescription })!.words,
                    canLearn: true,
                    hasBackButton: true)
            v.descriptionView!.backButton.addTarget(
                    self,
                    action: #selector(categoryViewReturnToCategories),
                    for: .touchUpInside)
            v.addSubview(v.descriptionView!)
        }
 
        v.tag = 10
        views[0] = v
        
        let tableView = CategoryDescriptionView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - bottom_bar.bounds.height),
            name: archive_title, words: archive, canLearn: false, hasBackButton: false)
        tableView.tag = 20
        for cell in tableView.cells{
            cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(deleteWord(gesture:))))
        }
        views[1] = tableView
        if(current_tab == 0){
            view.addSubview(views[0])
        }else{
            view.addSubview(views[1])
        }
    }
    
    @objc func deleteCategory(sender: Button){
        let alert = UIAlertController(title: delete_category_title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alert_cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: delete_category_without_words_text, style: .default, handler: { (action) in
            let cell = sender.superview as! CategoryViewCell
            deleteCategoryFromDatabase(name: cell.title, deleteWords: false)
            self.viewWillAppear(false)
        }))
        alert.addAction(UIAlertAction(title: delete_category_with_words_text, style: .default, handler: { (action) in
            let cell = sender.superview as! CategoryViewCell
            deleteCategoryFromDatabase(name: cell.title, deleteWords: true)
            self.viewWillAppear(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func shareCategory(sender: Button){
        let cell = sender.superview as! CategoryViewCell
        let category_text = cell.title
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.athene.xenous.ru"
        components.path = "/category"
        
        let userIdQueryItem = URLQueryItem(name: "user", value: Auth.auth().currentUser!.uid)
        let categoryQueryItem = URLQueryItem(name: "category", value: category_text)
        
        components.queryItems = [userIdQueryItem, categoryQueryItem]
        
        guard let linkParameter = components.url else {return}
        print("Sharing \(linkParameter.absoluteString)")
        
        //Actual link
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://athene.page.link") else {
            print("Couldn't create FDL components")
            return
        }
        
        if let bundleID = Bundle.main.bundleIdentifier{
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
        }
        shareLink.iOSParameters?.appStoreID = "1487762033"
        
        shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.xenous.athenekotlin")
        
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = "Кажется кто-то хочет поделиться с вами списком слов в приложении Athene!"
        shareLink.socialMetaTagParameters?.descriptionText = "Скачайте Athene, чтобы получить доступ к списку слов."
        
        guard let longURL = shareLink.url else {return}
        print("Long url: \(longURL)")
        
        shareLink.shorten { [weak self] (url, warnings, error) in
            if let error = error {
                print("Error while shortening url: \(error.localizedDescription)")
                return
            }
            if let warnings = warnings {
                for warning in warnings {
                    print("Warning: \(warning)")
                }
            }
            guard let url = url else {
                return
            }
            print("Shortened url: \(url.absoluteString)")
            self?.showShareSheet(url: url)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        main_vc.pager_view.setPosition(position: 0)
        main_vc.currentPageIndex = 0
        main_vc.lastPendingViewControllerIndex = 1
        print("LALALALALALALALA")
    }

    func showShareSheet(url: URL){
        let promoText = promo_text
        let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc func learnCategory(sender: Button){
        let cell = sender.superview as! CategoryViewCell
        var k = 0
        var n = 0
        for word in categories.first(where: { $0.title == cell.title })!.words{
            n += 1
            if(word.level == -2){
                k += 1
            }
        }
        let alert = UIAlertController(
            title: add_alert_title[0] + String(k) + add_alert_title[1] + String(n) + add_alert_title[2],
            message: add_alert_describtion,
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: alert_yes, style: UIAlertAction.Style.default, handler: {(action) in
            for word in categories.first(where: { $0.title == cell.title })!.words{
                if(word.level == -2){
                    ref.child("words").child(word.db_index).child("level").setValue(0)
                    ref.child("words").child(word.db_index).child("date").setValue(next_date.toDatabaseFormat())
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: alert_cancel, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func learnWord(sender: Button){
        let cell = sender.superview as! CategoryDescriptionViewCell
        if(cell.word.level == -2){
            let alert = UIAlertController(title: add_alert_title_single, message: add_alert_describtion_single, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: alert_yes, style: UIAlertAction.Style.default, handler: {(action) in
                ref.child("words").child(cell.word.db_index).child("level").setValue(0)
                ref.child("words").child(cell.word.db_index).child("date").setValue(next_date.toDatabaseFormat())
            }))
            
            alert.addAction(UIAlertAction(title: alert_cancel, style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(
                title: already_learning_word_message,
                message: already_learning_word_description,
                preferredStyle: .actionSheet)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func switchView(gesture: UITapGestureRecognizer){
        let new_ind = gesture.view!.tag
        print(current_tab, new_ind)
        if(new_ind == current_tab){
            return
        }
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.views[self.current_tab].alpha = 0
            for i in self.bottom_bar_btns{i.backgroundColor = UIColor.init(white: 1, alpha: 0.2)}
        }, completion: {(finished: Bool) in
            self.views[new_ind].alpha = 0
            self.view.addSubview(self.views[new_ind])
            self.views[self.current_tab].removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.views[new_ind].alpha = 1
                self.bottom_bar_btns[self.current_tab].backgroundColor = UIColor.clear
                self.bottom_bar_btns[new_ind].backgroundColor = UIColor.init(white: 1, alpha: 0.4)
            }, completion: {(finished: Bool) in
                self.current_tab = new_ind
                self.view.isUserInteractionEnabled = true
            })
        })
    }
    
    @objc func inspectCategory(sender: Button){
        let cell = sender.superview as! CategoryViewCell
        let descriptionView = (views[0] as! CategoryView).viewCategoryInfo(cell: cell)
        for wordCell in descriptionView.cells{
            wordCell.learnButton!.addTarget(self, action: #selector(learnWord(sender:)), for: .touchUpInside)
            wordCell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(deleteWord(gesture:))))
        }
        descriptionView.backButton.addTarget(
                self,
                action: #selector(categoryViewReturnToCategories),
                for: .touchUpInside)
    }
    
    @objc func deleteWord(gesture: UILongPressGestureRecognizer){
        if(gesture.state == .began){
            print("deleting word")
            let alert = UIAlertController(title: delete_alert_question, message: delete_alert_warning, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: delete_alert_delete, style: UIAlertAction.Style.default, handler: {(action) in
                let cell = gesture.view as! CategoryDescriptionViewCell
                deleteWordFromDatabase(word: cell.word)
                (self.views[0] as! CategoryView).descriptionView?.deleteWord(word: cell.word)
                (self.views[1] as! CategoryDescriptionView).deleteWord(word: cell.word)
            }))
            
            alert.addAction(UIAlertAction(title: alert_cancel, style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func categoryViewReturnToCategories(){
        (views[0] as! CategoryView).returnToMainView() {
            self.viewWillAppear(false)
        }
    }
}
