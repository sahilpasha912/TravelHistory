//
//  HomeVC.swift
//  TravelHistory
//
//  Created by SAHIL PASHA on 07/06/21.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var locationListTableView: UITableView!
    
    
    // MARk:- Variables
    
    var locationList =  [Location]()
    
    // MARK:- Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationServicesTask()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationTracker.shared.getSavedLocations(limit: 100, ascending: true) { [self] (totalList) in
            locationList = totalList
            locationListTableView.reloadData()
        }
    }
    
    
    // MARK:- functions
    
    private func locationServicesTask() {
        LocationTracker.shared.requestLocationWithAuthorization(type: .always, callback: { status in
            switch status {
            case .denied, .restricted, .notDetermined:
               break
            case .authorizedAlways, .authorizedWhenInUse:
                LocationTracker.shared.isSave = true
                LocationTracker.shared.startLocationTracker()
            default:
                break
            }
        })
        
//        LocationTracker.shared.didChangeLocation(callback: { location in
//
//
//        })
        
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell",for: indexPath) as? ListTableViewCell
        cell?.listOfPlace = locationList[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
