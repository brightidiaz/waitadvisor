//
//  LocationChangeDetectedView.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 18/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import UIKit

protocol LocationChangeDetectedViewDelegate: class {
    func locationChangeDetectedViewDidTapStillWaiting(_ locationChangeDetectedView: LocationChangeDetectedView)
    func locationChangeDetectedViewDidTapNowMoving(_ locationChangeDetectedView: LocationChangeDetectedView)
}

class LocationChangeDetectedView: UIView {
    private let CORNER_RADIUS: CGFloat = 5.0
    
    @IBOutlet weak private var stillWaitingButton: JLButton!
    @IBOutlet weak private var nowMovingButton: JLButton!
    
    weak var delegate: LocationChangeDetectedViewDelegate?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = CORNER_RADIUS
        layer.masksToBounds = true
    }
}

fileprivate extension LocationChangeDetectedView {
    
    func setupStructure() {
        let viewFromNib = viewFromOwnedNib()
        addSubviewAndFill(viewFromNib)
        setupButtons()
    }
    
    func setupButtons() {
        stillWaitingButton.model = JLButtonModel(buttonText: "Still Waiting", onTap: {[weak self] (text) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.locationChangeDetectedViewDidTapStillWaiting(weakSelf)
        })
        
        nowMovingButton.model = JLButtonModel(buttonText: "Now Moving", onTap: {[weak self] (text) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.locationChangeDetectedViewDidTapNowMoving(weakSelf)
        })
    }
    
}
