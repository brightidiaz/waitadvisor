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
    private let MINIMUM_DISTANCE: CLLocationDistance = 500.0
    private let TIME_THRESHOLD: TimeInterval = 3 //15 * 60
    private let TIMER_INTERVAL: TimeInterval = 5
    
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
            self?.changeStateTo(.locationError)
        }
        resetData()
    }
    
    override func loadView() {
        view = stateView
    }
    
    private func resetData() {
        print("Data Reset")
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
        case .locationError:
            stopTimer()
        }
    }
    
    private func performStartedOperation() {
        locationManager.successCallback = {[weak self] (location) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.resetData()
            weakSelf.runTimer()
        }
        locationManager.startReceivingLocationChanges()
    }
    
    @objc func timerTick(_ timer: Timer) {
        locationManager.successCallback = {[weak self] (location) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.data3 = DataPiece(location: location, time: Date())
            if weakSelf.isDistanceLessThanOrEqualTo(weakSelf.MINIMUM_DISTANCE, location1: weakSelf.data3?.location, location2: weakSelf.data1?.location)
                || weakSelf.isDistanceLessThanOrEqualTo(weakSelf.MINIMUM_DISTANCE, location1: weakSelf.data3?.location, location2: weakSelf.data2?.location) {
                    weakSelf.data2 = weakSelf.data3
                
            } else {
                weakSelf.showLocationView()
                weakSelf.stopTimer()
            }
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func stopTimer() {
        print("Timer stopped!")
        timer.invalidate()
    }
    
    private func runTimer() {
        print("Timer running!")
        timer = Timer.scheduledTimer(timeInterval: TIMER_INTERVAL, target: self, selector: #selector(timerTick(_:)), userInfo: nil, repeats: true)
    }
    
    private func isDistanceLessThanOrEqualTo(_ meters: CLLocationDistance, location1: CLLocation?, location2: CLLocation?) -> Bool {
        guard let loc1 = location1, let loc2 = location2 else {
            return true
        }
        return false
//        return loc1.distance(from: loc2) <= meters
    }
    
    private func performStoppedOperation() {
        stopTimer()
    }
    
    private func changeStateTo(_ state: State) {
        stateView.model?.model.value = state
        performActionFor(state: state)
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
    func locationChangeControllerTimerDidElapse(_ locationChangeController: LocationChangeViewController) {
        changeStateTo(.stopped)
        print("Send DATA2 = \(data2?.location), \(data2?.time), TIME1 = \(data1?.time) and userID to server")
    }
    
    func locationChangeControllerDidTapStillWaiting(_ locationChangeController: LocationChangeViewController) {
        data2 = data3
        runTimer()
    }
    
    func locationChangeControllerDidTapNowMoving(_ locationChangeController: LocationChangeViewController) {
        locationManager.successCallback = {[weak self] (location) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.data3 = DataPiece(location: location, time: Date())
            
            guard let firstData = weakSelf.data1, let secondData = weakSelf.data3 else {
                return
            }
            
            if secondData.time.timeIntervalSince(firstData.time) < weakSelf.TIME_THRESHOLD{
                weakSelf.resetData()
            } else {
                print("Send DATA3 = \(weakSelf.data3?.location), \(weakSelf.data3?.time), TIME1 = \(weakSelf.data1?.time) and userID to server")
            }
            weakSelf.changeStateTo(.stopped)
        }
        locationManager.startReceivingLocationChanges()
    }
    
}
