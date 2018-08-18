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
    }
    
}
