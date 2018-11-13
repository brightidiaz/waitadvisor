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

enum CheckMode {
    case distance
    case distanceAndSpeed
}

/* Handles main logic */
class MainViewController: UIViewController {
    private let MINIMUM_DISTANCE: CLLocationDistance = 500.0
    private let MINIMUM_SPEED: CLLocationSpeed = 4.2 //meters per second
    private let TIME_THRESHOLD: TimeInterval = 15 * 60
    
    private let model = StateModel(value: .stopped)
    private let stateView = StateView(frame: .zero)
    private var locationManager: LocationManager
    private var viewModel: StateViewModel?
    private var data1, data2, data3: DataPiece?
    
    private let mode: CheckMode = .distanceAndSpeed
    private var referenceTime = Date()
    
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
        locationManager.successCallback = {[weak self] _ in
            self?.changeUIStateTo(.stopped)
            self?.performActionFor(state: .stopped)
        }
        locationManager.errorCallback = {[weak self] (errorString) in
            self?.changeUIStateTo(.locationError)
            self?.stateView.errorMessage = errorString
            self?.performActionFor(state: .locationError)
        }
    }
    
    override func loadView() {
        view = stateView
    }
    
    private func resetData(completion: (()->())? = nil) {
        var tick = 0
        locationManager.successCallback = {[weak self] location in
            //Discard the first location, it's usually stale
            if tick < 1 {
                tick += 1
                return
            }
            self?.data1 = DataPiece(location: location, time: Date())
            self?.data2 = DataPiece(location: location, time: Date())
            self?.data3 = DataPiece(location: location, time: Date())
            self?.resetReferenceTime()
            completion?()
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func resetReferenceTime() {
        referenceTime = Date()
    }
    
    private func performActionFor(state: State) {
        switch state {
        case .started:
            performStartedOperation()
        case .stopped:
            stopLocationMonitoring()
            performStoppedOperation()
        case .locationError:
            stopLocationMonitoring()
        }
    }
    
    private func manuallyStopped() {
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
                guard let weakSelf = self, let userData3 = weakSelf.data3, let userData1 = weakSelf.data1 else {
                    return
                }
                let apiObject = APIObject(latitude: userData3.location.coordinate.latitude,
                                          longitude: userData3.location.coordinate.longitude,
                                          time_start: userData3.time.timeIntervalSince1970,
                                          time_end: userData1.time.timeIntervalSince1970,
                                          userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")

                
                weakSelf.sendData(apiObject)
            }
            weakSelf.stopLocationMonitoring()
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func performStartedOperation() {
        resetData {[weak self] in
            guard let weakSelf = self else {
                return
            }
            var tickCount = 0
            weakSelf.locationManager.successCallback = { (location) in
                if tickCount < 1 {
                    tickCount += 1
                    return
                }
                if (weakSelf.mode == .distanceAndSpeed) {
                    weakSelf.distanceAndSpeedCheck(currentLocation: location)
                } else {
                    weakSelf.pureDistanceCheck(currentLocation: location)
                }
            }
            weakSelf.locationManager.startReceivingLocationChanges()
        }
    }
    
    private func distanceAndSpeedCheck(currentLocation: CLLocation) {
        stateView.errorMessage = "Current Speed = \(currentLocation.speed)"
        stateView.diagnosticMessage = "Data 3 = \(data3!.location.coordinate.latitude), \(data3!.location.coordinate.longitude) \n Data 1 = \(data1!.location.coordinate.latitude), \(data1!.location.coordinate.longitude)"
        data3 = DataPiece(location: currentLocation, time: Date())
        if data3!.time.timeIntervalSince(referenceTime) < 10 {
            return
        }
        if isDistanceLessThanOrEqualTo(MINIMUM_DISTANCE, location1: data3?.location, location2: data1?.location) &&
            data3!.location.speed < MINIMUM_SPEED {
        } else {
            showLocationView()
        }
    }
    
    private func pureDistanceCheck(currentLocation: CLLocation) {
        data3 = DataPiece(location: currentLocation, time: Date())
        if isDistanceLessThanOrEqualTo(MINIMUM_DISTANCE, location1: data3?.location, location2: data1?.location)
            || isDistanceLessThanOrEqualTo(MINIMUM_DISTANCE, location1: data3?.location, location2: data2?.location) {
            data2 = data3
        } else {
            showLocationView()
            stopLocationMonitoring()
        }
    }
    
    private func stopLocationMonitoring() {
        locationManager.stopReceivingLocationChanges()
    }
    
    private func startLocationMonitoring() {
        locationManager.startReceivingLocationChanges()
    }
    
    private func sendData(_ apiObject: APIObject) {
        APIManager.shared.post(apiObject: apiObject)
    }
    
    private func isDistanceLessThanOrEqualTo(_ meters: CLLocationDistance, location1: CLLocation?, location2: CLLocation?) -> Bool {
        guard let loc1 = location1, let loc2 = location2 else {
            return true
        }
        let distance = loc1.distance(from: loc2)
        stateView.diagnosticMessage += "\nDistance = \(distance)"
        return distance <= meters
    }
    
    private func performStoppedOperation() {
        manuallyStopped()
    }
    
    private func changeUIStateTo(_ state: State) {
        stateView.model?.model.value = state
    }
    
    private func showLocationView() {
        if UIApplication.shared.applicationState == .active {
            stopLocationMonitoring()
            DispatchQueue.main.async {[weak self] in
                let locationChangeVC = LocationChangeViewController(nibName: String(describing: LocationChangeViewController.self), bundle: .main)
                locationChangeVC.modalPresentationStyle = .overCurrentContext
                locationChangeVC.delegate = self
                self?.present(locationChangeVC, animated: false, completion: nil)
            }
        } else {
            if mode == .distanceAndSpeed {
                guard let userData1 = data1, let userData3 = data3 else {
                    return
                }

                let apiObject = APIObject(latitude: userData3.location.coordinate.latitude,
                                          longitude: userData3.location.coordinate.longitude,
                                          time_start: userData1.time.timeIntervalSince1970,
                                          time_end: userData3.time.timeIntervalSince1970,
                                          userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
                
                sendData(apiObject)
                changeUIStateTo(.stopped)
                stopLocationMonitoring()
            } else {
                guard let userData2 = data2, let userData1 = data1 else {
                    return
                }
                let apiObject = APIObject(latitude: userData2.location.coordinate.latitude,
                                          longitude: userData2.location.coordinate.longitude,
                                          time_start: userData2.time.timeIntervalSince1970,
                                          time_end: userData1.time.timeIntervalSince1970,
                                          userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
                
                sendData(apiObject)
                changeUIStateTo(.stopped)
                stopLocationMonitoring()
            }
        }
        
        
    }
}

extension MainViewController: StateViewModelDelegate {
    func stateViewModel(_ stateViewModel: StateViewModel, didChangeStateTo state: State) {
        performActionFor(state: state)
    }
}

extension MainViewController: LocationChangeViewControllerDelegate {
    /* Handles action if the user didn't respond to the location change prompt */
    func locationChangeControllerTimerDidElapse(_ locationChangeController: LocationChangeViewController) {
        if mode == .distanceAndSpeed {
            guard let userData1 = data1, let userData3 = data3 else {
                return
            }
            let apiObject = APIObject(latitude: userData3.location.coordinate.latitude,
                                      longitude: userData3.location.coordinate.longitude,
                                      time_start: userData1.time.timeIntervalSince1970,
                                      time_end: userData3.time.timeIntervalSince1970,
                                      userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
            
            sendData(apiObject)
            changeUIStateTo(.stopped)
            stopLocationMonitoring()
        } else {
            guard let userData2 = data2, let userData1 = data1 else {
                return
            }
            let apiObject = APIObject(latitude: userData2.location.coordinate.latitude,
                                      longitude: userData2.location.coordinate.longitude,
                                      time_start: userData2.time.timeIntervalSince1970,
                                      time_end: userData1.time.timeIntervalSince1970,
                                      userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")

            sendData(apiObject)
            changeUIStateTo(.stopped)
            stopLocationMonitoring()
        }
    }
    
    /* Handles action when the user tapped Still Waiting */
    func locationChangeControllerDidTapStillWaiting(_ locationChangeController: LocationChangeViewController) {
        resetReferenceTime()
        if mode == .distanceAndSpeed {
            startLocationMonitoring()
        } else {
            data2 = data3
            startLocationMonitoring()
        }
    }
    
    /* Handles action when the user tapped Now Moving */
    func locationChangeControllerDidTapNowMoving(_ locationChangeController: LocationChangeViewController) {
        if mode == .distanceAndSpeed {
            guard let userData1 = data1, let userData3 = data3 else {
                return
            }
            let apiObject = APIObject(latitude: userData3.location.coordinate.latitude,
                                      longitude: userData3.location.coordinate.longitude,
                                      time_start: userData1.time.timeIntervalSince1970,
                                      time_end: userData3.time.timeIntervalSince1970,
                                      userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
            
            sendData(apiObject)
            changeUIStateTo(.stopped)
            stopLocationMonitoring()
        } else {
            guard let userData2 = data2, let userData1 = data1 else {
                return
            }
            let apiObject = APIObject(latitude: userData2.location.coordinate.latitude,
                                      longitude: userData2.location.coordinate.longitude,
                                      time_start: userData2.time.timeIntervalSince1970,
                                      time_end: userData1.time.timeIntervalSince1970,
                                      userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")


            sendData(apiObject)
            changeUIStateTo(.stopped)
        }
        
    }
    
}
