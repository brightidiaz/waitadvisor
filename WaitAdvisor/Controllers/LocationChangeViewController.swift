//
//  LocationChangeViewController.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 18/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import UIKit

protocol LocationChangeViewControllerDelegate: class {
    func locationChangeControllerDidTapStillWaiting(_ locationChangeController: LocationChangeViewController)
    func locationChangeControllerDidTapNowMoving(_ locationChangeController: LocationChangeViewController)
    func locationChangeControllerTimerDidElapse(_ locationChangeController: LocationChangeViewController)
}

class LocationChangeViewController: UIViewController {
    private let TIMER_INTERVAL: TimeInterval = 5 * 60
    @IBOutlet weak private var locationChangeView: LocationChangeDetectedView!
    weak var delegate: LocationChangeViewControllerDelegate?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationChangeView.alpha = 0.0
        locationChangeView.delegate = self
        timer = Timer.scheduledTimer(withTimeInterval: TIMER_INTERVAL, repeats: false, block: {[weak self] (timer) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.timer.invalidate()
            weakSelf.animateViewOut(completion: {
                weakSelf.delegate?.locationChangeControllerTimerDidElapse(weakSelf)
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViewIn()
    }

    private func animateViewIn() {
        locationChangeView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.locationChangeView.transform = CGAffineTransform.identity
            self?.locationChangeView.alpha = 1.0
        }
    }
    
    private func animateViewOut(completion: (() -> ())?) {
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.locationChangeView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self?.view.alpha = 0.0
        }) {[weak self] (completed) in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}

extension LocationChangeViewController: LocationChangeDetectedViewDelegate {
    func locationChangeDetectedViewDidTapStillWaiting(_ locationChangeDetectedView: LocationChangeDetectedView) {
        animateViewOut() {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.locationChangeControllerDidTapStillWaiting(weakSelf)
        }
    }
    
    func locationChangeDetectedViewDidTapNowMoving(_ locationChangeDetectedView: LocationChangeDetectedView) {
        animateViewOut() {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.locationChangeControllerDidTapNowMoving(weakSelf)
        }
    }
    
}
