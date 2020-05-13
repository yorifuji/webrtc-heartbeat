//
//  InterfaceController.swift
//  watch-bpm-monitor Extension
//
//  Created by yorifuji on 2020/05/13.
//  Copyright © 2020 yorifuji. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!

    let fontSize = UIFont.systemFont(ofSize: 80)

    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    var heartRateQuery: HKQuery?

    var workoutSession: HKWorkoutSession?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        print(#function)

        guard HKHealthStore.isHealthDataAvailable() else {
            label.setText("HealthKit is not available on this device.")
            print("HealthKit is not available on this device.")
            return
        }

        let dataTypes = Set([heartRateType])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) in
            guard success else {
                self.label.setText("Requests permission is not allowed.")
                print("Requests permission is not allowed.")
                return
            }
        }

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        else {
            print("WCSession not supported")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print(#function)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print(#function)
    }

    @IBAction func btnTapped() {
        print(#function)
        if let workoutSession = workoutSession {
            workoutSession.stopActivity(with: nil)
        }
        else {
            let config = HKWorkoutConfiguration()
            config.activityType = .other
            do {
                workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
                workoutSession?.delegate = self
                workoutSession?.startActivity(with: nil)
            }
            catch let e {
                print(e)
            }
        }
    }
}

extension InterfaceController: HKWorkoutSessionDelegate {

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print(#function)
        switch toState {
        case .running:
            print("Session status to running")
            startQuery()
        case .stopped:
            print("Session status to stopped")
            stopQuery()
            self.workoutSession?.end()
        case .ended:
            print("Session status to ended")
            self.workoutSession = nil
        default:
            print("Other status \(toState.rawValue)")
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workoutSession delegate didFailWithError \(error.localizedDescription)")
    }
}

extension InterfaceController: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
    }

}

extension InterfaceController {

    private func createStreamingQuery() -> HKQuery {
        print(#function)
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) in
            self.addSamples(samples: samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            self.addSamples(samples: samples)
        }
        return query
    }

    private func addSamples(samples: [HKSample]?) {
        print(#function)
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let quantity = samples.last?.quantity else { return }

        let bpm = String(quantity.doubleValue(for: heartRateUnit))
//        print(text)
        let attrStr = NSAttributedString(string: bpm, attributes:[NSAttributedString.Key.font:fontSize])
        DispatchQueue.main.async {
            self.label.setAttributedText(attrStr)
        }

        WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }

    private func startQuery() {
        print(#function)
        heartRateQuery = createStreamingQuery()
        healthStore.execute(heartRateQuery!)
        DispatchQueue.main.async {
            self.button.setTitle("Stop")
        }
    }

    private func stopQuery() {
        print(#function)
        healthStore.stop(heartRateQuery!)
        heartRateQuery = nil
        DispatchQueue.main.async {
            self.button.setTitle("Start")
            self.label.setText("")
        }
    }
}
