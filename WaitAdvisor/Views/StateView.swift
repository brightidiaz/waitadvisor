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
    var callback: ((State) -> ())?
    var observer: NSObjectProtocol?
    weak var delegate: StateViewModelDelegate?
    
    init(model: StateModel, callback: ((State) -> ())? = nil) {
        self.model = model
        stateValue = model.value
        super.init()
        NotificationCenter.default.addObserver(forName: StateModel.stateDidChange, object: nil, queue: nil) {[weak self] (notification) in
            self?.stateValue = notification.userInfo?[StateModel.stateKey] as? State ?? .stopped
            self?.callback?(self?.stateValue ?? .stopped)
        }
    }
    
    func commit(value: State) {
        model.value = value
        delegate?.stateViewModel(self, didChangeStateTo: value)
    }
    
}

private struct StateUISettings {
    var switchIsOn: Bool
    var switchText: String
    var messageText: String
    var isSwitchVisible: Bool
}

class StateView: UIView {
    @IBOutlet weak private var waitSwitch: UISwitch!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var switchLabel: UILabel!
    @IBOutlet weak private var switchContainer: UIView!
    @IBOutlet weak private var errorLabel: UILabel!
    
    var errorMessage = "" {
        didSet {
            errorLabel.text = errorMessage
        }
    }
    
    var model: StateViewModel? {
        didSet {
            model?.callback = {[weak self] (state) in
                switch state {
                case .started:
                    self?.applyUI(StateUISettings(switchIsOn: true,
                                                  switchText: "Wait Advisor is ON",
                                                  messageText: "You have activated the Wait Advisor. Please don't forget to turn this OFF as soon as your wait is over.", isSwitchVisible: true))
                case .stopped:
                    self?.applyUI(StateUISettings(switchIsOn: false,
                                                  switchText: "Wait Advisor is OFF",
                                                  messageText: "If you are currently waiting in a queue or are parked waiting for your cargo to be loaded or unloaded, please turn the switch on.", isSwitchVisible: true))
                case .locationError:
                    self?.applyUI(StateUISettings(switchIsOn: false,
                                                  switchText: "Wait Advisor is OFF",
                                                  messageText: "Please enable location services and make sure that Wait Advisor has permission to get your location.", isSwitchVisible: false))
                }
            }
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
    
    @IBAction func didChangeValue(_ sender: UISwitch) {
        guard let modelObject = model else {
            return
        }
        var newState: State = .stopped
        switch modelObject.model.value {
        case .stopped:
            newState = .started
        case .started:
            newState = .stopped
        default:
            fatalError()
        }
        model?.commit(value: newState)
    }
    
}

fileprivate extension StateView {
    
    func setupStructure() {
        let viewFromNib = viewFromOwnedNib()
        addSubviewAndFill(viewFromNib)
        model?.commit(value: .stopped)
    }
    
    func applyUI(_ setting: StateUISettings) {
        waitSwitch.isOn = setting.switchIsOn
        switchLabel.text = setting.switchText
        messageLabel.text = setting.messageText
        switchContainer.isHidden = !setting.isSwitchVisible
    }
}
