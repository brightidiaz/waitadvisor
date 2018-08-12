//
//  MainViewController.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

// The main screen. The app's main logic is handled here
import UIKit

class MainViewController: UIViewController {
    let model = StateModel(value: .stopped)
    let stateView = StateView(frame: .zero)
    var viewModel: StateViewModel?
    var observer: NSObjectProtocol?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = StateViewModel(model: model)
        stateView.model = viewModel
        viewModel?.delegate = self
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {[weak self] (timer) in
            let newState: State = .stopped
            self?.stateView.model?.model.value = newState
            self?.performActionFor(state: newState)
        }
    }
    
    override func loadView() {
        view = stateView
    }
    
    private func performActionFor(state: State) {
        print("Changed state to \(state)")
    }
}

extension MainViewController: StateViewModelDelegate {
    func stateViewModel(_ stateViewModel: StateViewModel, didChangeStateTo state: State) {
        performActionFor(state: state)
    }
}
