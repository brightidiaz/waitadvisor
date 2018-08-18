//
//  MainViewController.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

// The main screen. The app's main logic is handled here
import UIKit
import CoreLocation

/*
 TODO
 AppID and UserID
 API Manager
 */

/* Location and time encapsulated */
struct DataPiece {
    var location: CLLocation
    var time: Date
}

extension DataPiece {
    init() {
        location = CLLocation(latitude: 0, longitude: 0)
        time = Date()
    }
}

class MainViewController: UIViewController {
    private let model = StateModel(value: .stopped)
    private let stateView = StateView(frame: .zero)
    private var locationManager: LocationManager
    private var viewModel: StateViewModel?
    private var data1, data2, data3: DataPiece?
    private var timer = Timer()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        locationManager = LocationManager(successCallback: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        locationManager = LocationManager(successCallback: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = StateViewModel(model: model)
        stateView.model = viewModel
        viewModel?.delegate = self
        locationManager.errorCallback = {[weak self] (errorString) in
            self?.stateView.model?.model.value = .locationError
        }
//        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {[weak self] (timer) in
//            let newState: State = .stopped
//            self?.stateView.model?.model.value = newState
//            self?.performActionFor(state: newState)
//        }
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
        switch state {
        case .started:
            performStartedOperation()
        case .stopped:
            performStoppedOperation()
        case .responseNeeded:
            performResponseNeededOperation()
        case .locationError:
            timer.invalidate()
            print("Error")
        }
    }
    
    /* On Timer Tick */
    /*
     get current time and location
     
     */
    
    private func performStartedOperation() {
        //        get initial time and location
        //        schedule timer
        locationManager.successCallback = { (location) in
            print("Location: \(location)")
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func performStoppedOperation() {
        //         invalidate timer

    }
    
    private func performResponseNeededOperation() {
        
    }

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
