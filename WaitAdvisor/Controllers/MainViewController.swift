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

class MainViewController: UIViewController {
    private let MINIMUM_DISTANCE: CLLocationDistance = 300.0
    private let MINIMUM_SPEED: CLLocationSpeed = 2.8
    private let TIME_THRESHOLD: TimeInterval = 3//15 * 60
    private let TIMER_INTERVAL: TimeInterval = 5//5 * 60
    
    private let model = StateModel(value: .stopped)
    private let stateView = StateView(frame: .zero)
    private var locationManager: LocationManager
    private var viewModel: StateViewModel?
    private var data1, data2, data3: DataPiece?
    
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
        
//        print("Pending:")
//        UserDefaultsManager.shared.printContents()
//        print()
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
        resetData()
    }
    
    override func loadView() {
        view = stateView
    }
    
    private func resetData() {
        print("Data Reset")
        locationManager.successCallback = {[weak self] location in
            self?.data1 = DataPiece(location: location, time: Date())
        }
        locationManager.startReceivingLocationChanges()
        data2 = nil
        data3 = nil
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
                    print("Data is NIL!")
                    return
                }
                let apiObject = APIObject(location: GeoPoint(latitude: userData3.location.coordinate.latitude,
                                                             longitude: userData3.location.coordinate.longitude),
                                          time1: userData3.time.timeIntervalSince1970,
                                          time2: userData1.time.timeIntervalSince1970,
                                          userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
                weakSelf.sendData(apiObject)
            }
            weakSelf.stopLocationMonitoring()
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func performStartedOperation() {
        resetData()
        var isFirst = true
        
        locationManager.successCallback = {[weak self] (location) in
            if isFirst {
                isFirst = false
                return
            }
            print("Location tick")
            guard let weakSelf = self else {
                return
            }
//            weakSelf.pureDistanceCheck(currentLocation: location)
            weakSelf.distanceAndSpeedCheck(currentLocation: location)
        }
        locationManager.startReceivingLocationChanges()
    }
    
    private func distanceAndSpeedCheck(currentLocation: CLLocation) {
        stateView.errorMessage = "Current Speed = \(currentLocation.speed)"
        data3 = DataPiece(location: currentLocation, time: Date())
        if isDistanceLessThanOrEqualTo(MINIMUM_DISTANCE, location1: data3?.location, location2: data1?.location) &&
            data3!.location.speed < MINIMUM_SPEED {
            data1 = data3
        } else {
            print("Show location view")
            guard let userData1 = data1, let userData3 = data3 else {
                print("Data is NIL!")
                return
            }
            let apiObject = APIObject(location: GeoPoint(latitude: userData1.location.coordinate.latitude,
                                                         longitude: userData1.location.coordinate.longitude),
                                      time1: userData1.time.timeIntervalSince1970,
                                      time2: userData3.time.timeIntervalSince1970,
                                      userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
            
            sendData(apiObject)
            changeUIStateTo(.stopped)
            stopLocationMonitoring()
        }
    }
    
    private func pureDistanceCheck(currentLocation: CLLocation) {
        data3 = DataPiece(location: currentLocation, time: Date())
        print("Data 1 = \(data1?.location.coordinate)")
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
        print("Distance = \(distance)")
        return distance <= meters
    }
    
    private func performStoppedOperation() {
        manuallyStopped()
    }
    
    private func changeUIStateTo(_ state: State) {
        stateView.model?.model.value = state
    }
    
    private func showLocationView() {
        print("Show location view")
        guard let userData2 = data2, let userData1 = data1 else {
            print("Data is NIL!")
            return
        }
        let apiObject = APIObject(location: GeoPoint(latitude: userData2.location.coordinate.latitude,
                                                     longitude: userData2.location.coordinate.longitude),
                                  time1: userData2.time.timeIntervalSince1970,
                                  time2: userData1.time.timeIntervalSince1970,
                                  userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
        
        sendData(apiObject)
        changeUIStateTo(.stopped)
//        DispatchQueue.main.async {[weak self] in
//            let locationChangeVC = LocationChangeViewController(nibName: String(describing: LocationChangeViewController.self), bundle: .main)
//            locationChangeVC.modalPresentationStyle = .overCurrentContext
//            locationChangeVC.delegate = self
//            self?.present(locationChangeVC, animated: false, completion: nil)
//        }
    }
}

extension MainViewController: StateViewModelDelegate {
    func stateViewModel(_ stateViewModel: StateViewModel, didChangeStateTo state: State) {
        performActionFor(state: state)
    }
}

extension MainViewController: LocationChangeViewControllerDelegate {
    func locationChangeControllerTimerDidElapse(_ locationChangeController: LocationChangeViewController) {
        guard let userData2 = data2, let userData1 = data1 else {
            print("Data is NIL!")
            return
        }
        let apiObject = APIObject(location: GeoPoint(latitude: userData2.location.coordinate.latitude,
                                                     longitude: userData2.location.coordinate.longitude),
                                  time1: userData2.time.timeIntervalSince1970,
                                  time2: userData1.time.timeIntervalSince1970,
                                  userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")
        
        sendData(apiObject)
        changeUIStateTo(.stopped)
    }
    
    func locationChangeControllerDidTapStillWaiting(_ locationChangeController: LocationChangeViewController) {
        data2 = data3
        startLocationMonitoring()
    }
    
    func locationChangeControllerDidTapNowMoving(_ locationChangeController: LocationChangeViewController) {
        guard let userData2 = data2, let userData1 = data1 else {
            print("Data is NIL!")
            return
        }
        let apiObject = APIObject(location: GeoPoint(latitude: userData2.location.coordinate.latitude,
                                                     longitude: userData2.location.coordinate.longitude),
                                  time1: userData2.time.timeIntervalSince1970,
                                  time2: userData1.time.timeIntervalSince1970,
                                  userID: UserDefaultsManager.shared.getUserID() ?? "<No User ID>")

        
        sendData(apiObject)
        changeUIStateTo(.stopped)
    }
    
}
