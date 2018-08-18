//
//  MainViewController.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

// The main screen. The app's main logic is handled here
import UIKit

/*
 TODO
 AppID and UserID
 API Manager
 */

/* Location and time encapsulated */
struct DataPiece {
    var location: String //Change to CLLocation
    var time: Date
}

extension DataPiece {
    init() {
        location = "Test"
        time = Date()
    }
}

class MainViewController: UIViewController {
    private let model = StateModel(value: .stopped)
    private let stateView = StateView(frame: .zero)
    private var viewModel: StateViewModel?
    private var data1, data2, data3: DataPiece?
    private var timer = Timer()
    
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
    
    private func resetData() {
        data1 = DataPiece()
        data2 = nil
        data3 = nil
    }
    
    private func performActionFor(state: State) {
        
        /*
         if state = started
            get initial time and location
            schedule timer
         if state = stopped
            invalidate timer
         if responseNeeded
            pause timer?
         */
    }
    
    /* On Timer Tick */
    /*
     get current time and location
     
     */
    
    private func showLocationView() {
        let locationChangeVC = LocationChangeViewController(nibName: String(describing: LocationChangeViewController.self), bundle: .main)
        locationChangeVC.modalPresentationStyle = .overCurrentContext
        locationChangeVC.delegate = self
        present(locationChangeVC, animated: false, completion: nil)
    }
}

extension MainViewController: StateViewModelDelegate {
    func stateViewModel(_ stateViewModel: StateViewModel, didChangeStateTo state: State) {
        performActionFor(state: state)
    }
}

extension MainViewController: LocationChangeViewControllerDelegate {
    func locationChangeControllerDidTapStillWaiting(_ locationChangeController: LocationChangeViewController) {
        print("Tapped Still Waiting")
    }
    
    func locationChangeControllerDidTapNowMoving(_ locationChangeController: LocationChangeViewController) {
        print("Tapped Now Working")
    }
    
    
}
