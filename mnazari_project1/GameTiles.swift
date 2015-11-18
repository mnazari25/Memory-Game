//
//  GameTiles.swift
//  mnazari_project1
//
//  Created by Mirabutaleb Nazari on 2/10/15.
//  Copyright (c) 2015 Bug Catcher Studios. All rights reserved.
//

import Foundation
import UIKit


class GameTile {
	
	var tileImage : String
	var tileButton : UIButton
	var beenSelected : Bool
	
	
	init(tileImage : String, tileButton : UIButton) {
		
		self.tileImage = tileImage
		self.tileButton = tileButton
		beenSelected = false
		
	}
	
}