//
//  JLButton.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 18/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import UIKit

struct JLButtonModel {
    var buttonText: String
    var onTap: (String?) -> ()
}

@IBDesignable
class JLButton: UIView {
    private let CORNER_RADIUS: CGFloat = 5.0
    private let BORDER_WIDTH: CGFloat = 1.0
    
    @IBOutlet weak private var buttonText: UILabel!
    
    var model: JLButtonModel? {
        didSet {
            buttonText.text = model?.buttonText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStructure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStructure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupStructure()
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        model?.onTap(model?.buttonText)
    }
    
}

fileprivate extension JLButton {
    
    func setupStructure() {
        let viewFromNib = viewFromOwnedNib()
        addSubviewAndFill(viewFromNib)
        layer.cornerRadius = CORNER_RADIUS
        layer.borderWidth = BORDER_WIDTH
        layer.borderColor = UIColor.gray.cgColor
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3.0
    }
    
}
