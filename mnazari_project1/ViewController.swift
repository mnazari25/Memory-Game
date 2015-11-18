//
//  ViewController.swift
//  mnazari_project1
//
//  Created by Mirabutaleb Nazari on 2/5/15.
//  Copyright (c) 2015 Bug Catcher Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	
	@IBOutlet var tileButtons: [UIButton]! // tiles if iPad
	
	@IBOutlet var iPhoneTiles: [UIButton]! // tiles if iPhone
	var currentTiles = [UIButton]() // used to store current Device tile selection
	
	var cardIcons : [(name: String, beenUsed: Bool)] = [] // holds image string identifiers and used boolean
	var catchUsed = [(String,Bool)]() // catches used to tiles for filtering process when creating board
	var tileCards : [GameTile] = [] // stores game tile objects
	
	var wildSelected : [UIButton?] = [] // stores any wilds that have been pressed
	var firstCard : GameTile? // first picked card
	var secondCard : GameTile? // second picked card
	
	var timerCount = 0
	var timerOn = false
	var timer : NSTimer = NSTimer()

	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var timerLabel: UILabel!
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		
		/* Checks current device and assigns appropiate tile values */
		/* Currently only set up for simulator use */
		if UIDevice.currentDevice().name == "iPhone Simulator" {
			
			currentTiles = iPhoneTiles
			
			cardIcons = [("WizardHat", false), ("Bone", false), ("Cauldron", false), ("Eyeball", false), ("Grave", false), ("Flask", false), ("TriangleFlask", false), ("Vial", false),("Meat", false),("Wild", false)]
			
			playButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 15.0)
			
			titleLabel.font = UIFont(name: "Marker Felt", size: 30.0)
			
		} else if UIDevice.currentDevice().name == "iPad Simulator" {
			
			currentTiles = tileButtons
			
			cardIcons = [("WizardHat", false), ("Bone", false), ("Cauldron", false), ("Eyeball", false), ("Grave", false), ("Flask", false), ("TriangleFlask", false), ("Vial", false),("Meat", false),("Wild", false), ("Gold", false), ("Brain", false), ("Garlic",false), ("Torch", false), ("Mushroom", false)]
			
		}
		
		// disables all items on board
		for item in currentTiles {
			
			item.enabled = false
			item.setBackgroundImage(UIImage(named: "TChest_Closed"), forState: .Disabled)
			
		}
		
	}
	
	func updateTimer() {
		
		timerCount += 1
		timerLabel.text = "Time: \(timerCount)"
		
	}
	
	
	/* Play Button handles all UI building and restarting game */
	@IBAction func PlayButton(sender: AnyObject) {
		
		/* Toggles play button */
		playButton.hidden = !playButton.hidden
		
		timerLabel.hidden = false
		
		if timerOn == false {
			
			timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
			
			timerOn = true
			
		}
		
		var tag = 0 // tag counter
		
		/* loops through current tiles and filters to create board */
		for item in currentTiles {
			
			let randomNum = Int(arc4random_uniform(UInt32(cardIcons.count))) // random num using card icons for range
			let imageName = cardIcons[randomNum] // pulls image name for random index
			
			item.enabled = true // enables item buttons
			item.hidden = false // unhides any buttons that are hidden
			item.setBackgroundImage(UIImage(named: "TChest"), forState: UIControlState.Normal) // sets card image to back of card image
			item.setTitle("", forState: UIControlState.Normal) // clears any wild titles that were set
			
			let newTile : GameTile = GameTile(tileImage: imageName.name, tileButton: item)
			tileCards.append(newTile) // creates new game tile object for current random image
			
			item.tag = tag // sets tag number
			tag += 1 // increments tag number
			
			// checks to see if current random index has been selected previously or not
			if cardIcons[randomNum].beenUsed == true {
				
//				item.setBackgroundImage(UIImage(named: cardIcons[randomNum].name), forState: UIControlState.Normal)
				var oldItem = cardIcons.removeAtIndex(randomNum) // removes current random image from card icons and stores it to variable
				oldItem.beenUsed = false // changes beenUsed boolean back to  false
				catchUsed.append(oldItem) // catches old item into array to be used later
				
			} else {

//				item.setBackgroundImage(UIImage(named: cardIcons[randomNum].name), forState: UIControlState.Normal)
				cardIcons[randomNum].beenUsed = true // toggles beenUsed boolean to true
				
			}
			
		}
		
		
	}

	
	/* Handles game tile taps and initiates matching check */
	@IBAction func TilePressed(sender: UIButton) {
		
		/* Checks if the selected tile is wild and makes sure that two cards have not already been selected */
		if tileCards[sender.tag].tileImage == "Wild" && secondCard == nil {
			
			sender.setTitle("Wild", forState: .Normal) // sets button title to wild
			sender.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
			sender.setTitleColor(UIColor.whiteColor(), forState: .Normal) // Sets title text to black color
			print("You've Selected a WILD!")
			sender.setBackgroundImage(UIImage(named: "Wild"), forState: UIControlState.Normal) // sets background image to wild tile
			wildSelected.append(sender) // appends wildbutton into array for later
			
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				
				[NSThread .sleepForTimeInterval(NSTimeInterval(1))] // pauses app in background
				
				dispatch_async(dispatch_get_main_queue()) {
					
					self.gameOver() // runs gameOver check function after pause (This is to avoid having wild as last card with nothing to match it against)
					
				}
				
			}
			
		} else if firstCard == nil {
			
			firstCard = tileCards[sender.tag] // sets first card to currently selected if no card was selected yet
			firstCard?.tileButton.enabled = false // disables current button to avoid double tap
			firstCard?.tileButton.setBackgroundImage(UIImage(named:firstCard!.tileImage), forState: .Disabled) // sets tile image
			return // returns out of function
			
		} else if secondCard == nil {
			
			secondCard = tileCards[sender.tag] // sets Second card to currently selected if a card was selected already
			secondCard?.tileButton.enabled = false // disables current button to avoid double tap
			secondCard?.tileButton.setBackgroundImage(UIImage(named:secondCard!.tileImage), forState: .Disabled) // sets tile image
			
			checkMatch() // runs check for match function
			return // returns out of function
			
		} else {
			
			print("Didn't do anything") // once two cards are selected does nothing if you tap any other button
			
		}
		
	}
	
    /* Handles match checking for the two selected cards */
	func checkMatch() {
		
		// direct compares first and second card to see if they match
		if firstCard!.tileImage == secondCard!.tileImage {
			
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				
				[NSThread .sleepForTimeInterval(NSTimeInterval(1))] // pauses app in background
				
				dispatch_async(dispatch_get_main_queue()) {
					
					/* Runs after pausing app */
					
					self.firstCard?.tileButton.hidden = true // hides correctly matched card 1
					self.secondCard?.tileButton.hidden = true // hides correctly matched card 2
					
					// if wild array is not empty it hides all wilds and empties array
					if self.wildSelected.count != 0 {
						
						for wild in self.wildSelected {
							
							wild?.hidden = true
							true
						}
						
						self.wildSelected = []
						
					}
					self.firstCard = nil // sets first card back to nil
					self.secondCard = nil // sets second card back to nil
					self.gameOver() // runs game over check
					
				}
				
			}
			
		} else {
			
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
				dispatch_async(dispatch_get_global_queue(priority, 0)) {
					
					[NSThread .sleepForTimeInterval(NSTimeInterval(1))] // pauses app in background
					
				dispatch_async(dispatch_get_main_queue()) {
					
					/* Runs after pausing app */
					
					self.firstCard?.tileButton.setBackgroundImage(UIImage(named:"TChest"), forState: .Normal) // sets back to back of card
					self.secondCard?.tileButton.setBackgroundImage(UIImage(named:"TChest"), forState: .Normal) // sets back to back of card
					
					// if wild array is not empty it hides all wilds and empties array
					for wild in self.wildSelected {
						
						wild?.hidden = true
						
					}
					self.wildSelected = []
					self.firstCard?.tileButton.enabled = true // reenables selected card
					self.secondCard?.tileButton.enabled = true // reenables selected card
					self.firstCard = nil  // sets first card back to nil
					self.secondCard = nil  // sets second card back to nil
					
				}
					
			}

		}

	}
	
	
	func gameOver() {
		
		var allHidden = false
		var savedTiles : [GameTile?] = []
		
		//
		for tile in self.tileCards {
			
			// if any card is not hidden besides wild returns out of function
			if tile.tileButton.hidden == false && tile.tileButton.titleLabel?.text != "Wild" {
				
				allHidden = false
				print("Not over yet")
				print(cardIcons.count)
				return
				
			} else {
				
				allHidden = true
				
				if tile.tileButton.titleLabel?.text == "Wild" {
					
					savedTiles.append(tile) // if last cards are wild stores to array to be hidden
					print("running")
					
				}
				
			}
			
		}
		
		// if all tiles hidden
		if allHidden == true {
			
			timer.invalidate()
			
			// alerts victory to user
			let alert = UIAlertView(title: "You Win!", message: "Congratulations you completed the puzzle in \(timerCount) seconds! Press play to restart", delegate: self, cancelButtonTitle: "OK")
			alert.show()
			
			// clears any wilds that may be present
			for wild in savedTiles {
				
				wild?.tileButton.hidden = true
				
			}
			
			timerLabel.text = "Time: 0"
			timerLabel.hidden = true
			timerCount = 0 // reset timer
			timerOn = false
			
			// empties temporary arrays
			tileCards = []
			wildSelected = []
			playButton.hidden = false // unhides play button
		
			// reassigns cardIcon array to old saved values to be used for board creation
			for tuple in catchUsed {
				
				cardIcons.append((name : tuple.0, beenUsed: tuple.1))
				
			}
			
			catchUsed = [] // clears old values
			
		}
		
	}

}

