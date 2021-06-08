//
//  ListTableViewCell.swift
//  TravelHistory
//
//  Created by SAHIL PASHA on 07/06/21.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    // MARK:- Outlets
    @IBOutlet weak var latLbl:UILabel!
    @IBOutlet weak var longLbl:UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    // MARK:- Variables
    var listOfPlace: Location?{
        didSet{
            setViewProperties()
        }
    }
    
    
    func setViewProperties(){
        
        latLbl.text = "\(listOfPlace?.latitude ?? 0)"
        longLbl.text = "\(listOfPlace?.longitude ?? 0)"
        timeLbl.text = "\(listOfPlace?.timestamp ?? Date())"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    

}
