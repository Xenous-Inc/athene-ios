//
//  CategoryView.swift
//  testing
//
//  Created by Vadim Zaripov on 06.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class CategoryView: UIView {

    var content: [String: [Word]] = [:]
    var cells: [CategoryViewCell] = []
    
    var padding: CGFloat = 0
    var cellHeight: CGFloat = 0
    
    var mainView: UIScrollView!
    var descriptionView: CategoryDescriptionView? = nil
    
    init(frame: CGRect, content: [String: [Word]]){
        super.init(frame: frame)
        clipsToBounds = true
        
        mainView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(mainView)
        
        if(content.count == 0){
            let placeholder: UILabel = {
                let label = UILabel(frame: CGRect(x: 0.05*self.bounds.width, y: 0, width: 0.9*self.bounds.width, height: 0.5*self.bounds.height))
                    label.text = empty_categories_placeholder
                    label.backgroundColor = .clear
                    label.textColor = .white
                    label.font = UIFont(name: "Helvetica", size: 30)
                    label.textAlignment = .left
                    label.numberOfLines = 3
                    label.adjustsFontSizeToFitWidth = true
                    label.sizeToFit()
                    label.alpha = 0.9
                    return label
            }()
            mainView.addSubview(placeholder)
            return
        }
        
        self.content = content
        
        let padding = 0.05*frame.width
        var y = padding
        
        let height = 0.09*frame.height
        
        for category in self.content{
            let cell = CategoryViewCell(frame: CGRect(x: padding, y: y, width: frame.width - 2*padding, height: height), text: category.key)
            mainView.addSubview(cell)
            cells.append(cell)
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCellPressed(gesture:))))
            y += height + padding
        }
        mainView.contentSize.height = y
    }
    
    @objc func onCellPressed(gesture: UITapGestureRecognizer){
        print("new tap")
        let pressedCell = gesture.view as! CategoryViewCell
        UIView.animate(withDuration: 0.4) {
            self.openCell(cellToOpen: pressedCell)
        }
    }

    func openCell(cellToOpen: CategoryViewCell){
        var dy: CGFloat = 0
        for cell in self.cells{
            cell.frame = CGRect(x: cell.frame.minX, y: cell.frame.minY + dy, width: cell.frame.width, height: cell.frame.height)
            if((cell.opened && abs(cell.frame.minY - cellToOpen.frame.minY) > 1) || abs(cell.frame.minY - cellToOpen.frame.minY) < 1){
                dy -= cell.frame.height
                cell.handleTap()
                dy += cell.frame.height
            }
        }
        self.mainView.contentSize.height += dy
    }
    
    func viewCategoryInfo(cell: CategoryViewCell) -> CategoryDescriptionView{
        descriptionView = CategoryDescriptionView(
            frame: frame,//CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height),
            name: cell.title,
            words: content[cell.title]!,
            canLearn: true,
            hasBackButton: true)
        descriptionView?.alpha = 0
        addSubview(descriptionView!)
        
        mainView.isUserInteractionEnabled = false
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.mainView.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5){
                self.descriptionView?.alpha = 1
            }
        }, completion: { finished in
            self.mainView.removeFromSuperview()
            self.mainView.isUserInteractionEnabled = true
        })
        return descriptionView!
    }
    
    @objc func returnToMainView(completion: @escaping () -> Void = { }){
        guard let descriptionView = descriptionView else {return}
        mainView.alpha = 0
        addSubview(mainView)
        descriptionView.isUserInteractionEnabled = false
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                descriptionView.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5){
                self.mainView.alpha = 1
            }
        }, completion: { finished in
            self.descriptionView?.removeFromSuperview()
            self.descriptionView?.isUserInteractionEnabled = true
            self.descriptionView = nil
            completion()
        })
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
