//
//  StateView.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//


// The main screen's view. Logic pertaining the view's appearance is contained here
import UIKit
import Foundation

protocol StateViewModelDelegate: class {
    func stateViewModel(_ stateViewModel: StateViewModel, didChangeStateTo state: State)
}

class StateViewModel: NSObject {
    let model: StateModel
    var stateValue: State
    var observer: NSObjectProtocol?
    weak var delegate: StateViewModelDelegate?
    
    init(model: StateModel) {
        self.model = model
        stateValue = model.value
        super.init()
        NotificationCenter.default.addObserver(forName: StateModel.stateDidChange, object: nil, queue: nil) {[weak self] (notification) in
             self?.stateValue = notification.userInfo?[StateModel.stateKey] as? State ?? .stopped
        }
    }
    
    func commit(value: State) {
        model.value = value
        delegate?.stateViewModel(self, didChangeStateTo: value)
    }
}

class StateView: UIView {
    var model: StateViewModel?
    
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
    
}

fileprivate extension StateView {
    
    func setupStructure() {
        let viewFromNib = viewFromOwnedNib()
        addSubviewAndFill(viewFromNib)
//        setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        guard let modelObject = model else {
            return
        }
        var newState: State = .stopped
        switch modelObject.model.value {
        case .stopped:
            newState = .started
        case .started:
            newState = .responseNeeded
        case .responseNeeded:
            newState = .stopped
        }
        model?.commit(value: newState)
    }
}
