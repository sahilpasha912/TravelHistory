//
//  LocationTracker.swift
//  LocationTrackerWithCoreData28
//
//  Created by SAHIL PASHA on 07/06/21.
//

import Foundation
import CoreLocation
import UIKit
import CoreData

typealias AuthorizationStatusHandler = ((_ status: CLAuthorizationStatus) -> Void)
typealias LocationTrackerHandler = ((_ location: CLLocation) -> Void)

enum AuthorizationType {
    case whenInUse
    case always
}

class LocationTracker: NSObject {
    
    static let shared = LocationTracker()
    let horizontalAccuracy: Double = 20.0
    var isBackGround = false
    fileprivate var locationManager: CLLocationManager?
    fileprivate var lastLocation: CLLocation?
    fileprivate var persistentStore: PersistentStoreLocation = PersistentStoreLocation()
    
    var isSave = false
    var lastSpeed: Double = 0.0
    var currentLocation: CLLocation? {
        return lastLocation
    }

    init(locationManager: CLLocationManager = CLLocationManager()) {
        super.init()
        self.locationManager = locationManager
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // Get LastLocation
        self.lastLocation = self.persistentStore.getLastLocation()
        
    }
    
    
    func startLocationTracker() {
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.startUpdatingLocation()
    }
    
    func saveInBackGround(){
        
        if let location = currentLocation {
            useAbleLocation(newLocation: location)
        }
    }
    
    
    
    func stopLocationTracker() {
        locationManager?.allowsBackgroundLocationUpdates = false
        locationManager?.stopUpdatingLocation()
    }
    
    
    
    func requestLocationWithAuthorization(type: AuthorizationType, callback: @escaping AuthorizationStatusHandler) {
        let authorizationStatus =  CLLocationManager.authorizationStatus()
        switch type {
        case .always:
            if authorizationStatus == .notDetermined {
                self.locationManager?.requestAlwaysAuthorization()
            } else {
                self.locationManager?.requestAlwaysAuthorization()
            }
        case .whenInUse:
            if authorizationStatus != .authorizedWhenInUse {
                self.locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    func escalateLocationServiceAuthorization() {
        // Escalate only when the authorization is set to when-in-use
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
    
    
    // function to open the Settings in app
    private func openSettings() {
        if #available(iOS 10.0, *) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    //Show alert when case is denied
    fileprivate func showAlertForChangeAuthorization() {
        UIAlertController.showAlert(title: "Change Your AuthorizationStatus",
                                    message: "Location Authorization Denied",
                                    style: .alert).action(title: "Ok",
                                                          style: .default, handler: { (alert: UIAlertAction) in
                                                            self.openSettings()
                                    })
    }
    
}

// MARK: - Store Presistent
extension LocationTracker {
    
    func removeAllLocalLocations(locations: [Location]) {
        self.persistentStore.removeObjects(list: locations)
    }
    
    func removeAllLocalLocations() {
        self.persistentStore.removeAllLocations()
    }
    
    func getSavedLocations(limit: Int = 0, ascending: Bool, callBack: @escaping (_ locations: [Location]) -> Void) {
        let list = self.persistentStore.getSavedLocations(limit: limit, ascending: ascending)
        callBack(list)
    }
    
}


// MARK: - CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    
    // TODO: didFailWithError
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Not Accessed \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        switch status {
        case .notDetermined:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            self.startLocationTracker()
            break
        case .restricted, .denied:
            self.stopLocationTracker()
            showAlertForChangeAuthorization()
            break
        @unknown default:
            break
        }
    }
    
    public func useAbleLocation(newLocation: CLLocation) {
        if self.isSave == true {
            self.persistentStore.save(location: newLocation)
        }
    }
    
    private func validLocation(location: CLLocation) -> Bool {
        let howRecent = location.timestamp.timeIntervalSinceNow
        guard CLLocationCoordinate2DIsValid(location.coordinate),
            location.horizontalAccuracy > 0,
            location.horizontalAccuracy < horizontalAccuracy,
            abs(howRecent) < 10 else { return false }
        return true
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for newLocation in locations {
            
            guard let lastLocationIs =  self.lastLocation else {
                
                //First time get location
                if validLocation(location: newLocation) {
                    self.lastLocation = newLocation
                }
                return
            }
            
            let distance = (newLocation.distance(from: lastLocationIs))
            if distance <= 0 {
                return
            }
            
            if validLocation(location: newLocation) {
                self.lastLocation = newLocation
                
                if isBackGround {
                    useAbleLocation(newLocation: LocationTracker.shared.currentLocation!)
                }
            }
        }
    }
}

////////////////////////////////////////////////////cccccccccccccnnf,asmnf,asndf,nas,dfnasdf,a.nd,fadsf
////////////////////////////////////////////////////cccccccccccccnnf,asmnf,asndf,nas,dfnasdf,a.nd,fadsf
////////////////////////////////////////////////////cccccccccccccnnf,asmnf,asndf,nas,dfnasdf,a.nd,fadsf

// MARK: - Alert Controller
extension UIAlertController {
    
    fileprivate func presentAlertController() {
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }

    @discardableResult
    fileprivate class func showAlert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
        let alertController = UIAlertController.alert(title: title, message: message, style: style)
        alertController.presentAlertController()
        return alertController
    }
    
}

extension UIAlertController {
  
  func present(viewController: UIViewController) {
      viewController.present(self, animated: true, completion: nil)
  }
  
  func present() {
    if let viewController = UIApplication.shared.keyWindow?.rootViewController {
      self.present(viewController: viewController)
    }
  }
  
  @discardableResult
    func action(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
    let action: UIAlertAction = UIAlertAction(title: title, style: style, handler: handler)
    self.addAction(action)
    return self
  }
  
  @discardableResult
    class func alert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
    let alertController: UIAlertController  = UIAlertController(title: title, message: message, preferredStyle: style)
    return alertController
  }
  
  @discardableResult
    class func presentAlert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
    let alertController = UIAlertController.alert(title: title, message: message, style: style)
    alertController.present()
    return alertController
  }
  
}


