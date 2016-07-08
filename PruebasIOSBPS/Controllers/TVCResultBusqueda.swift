//
//  TVCResultBusqueda.swift
//  MobileDeveloperTest
//
//  Created by Desarrollo 4 on 22/06/16.
//  Copyright © 2016 Rokk3rLabs. All rights reserved.
//

import UIKit

class TVCResultBusqueda: UITableViewCell {

    @IBOutlet weak var _LabelTitulo: UILabel!
    @IBOutlet weak var _LabelPrecio: UILabel!
    @IBOutlet weak var _LabelUbicacion: UILabel!
    @IBOutlet weak var _ImgProducto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
