//
//  UIViewExtension.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//


// This is an extension that loads the xib file and allows us to place it within a superview
import UIKit

extension UIView {
    class func fromNib() -> UIView? {
        guard let selfView = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)![0] as? UIView else {
            return nil
        }
        return selfView
    }
    
    func viewFromOwnedNib(named nibName: String? = nil) -> UIView {
        let bundle = Bundle(for: self.classForCoder)
        return {
            if let nibName = nibName {
                return bundle.loadNibNamed(nibName, owner: self, options: nil)!.last as! UIView
            }
            return bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)!.last as! UIView
            }()
    }
    
    func addSubviewAndFill(_ subview: UIView) {
        addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            subview.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]
        constraints.forEach {
            $0.priority = UILayoutPriority(999)
            $0.isActive = true
        }
    }
    
}
