//
//  Globals.swift
//  Briefing
//
//  Created by Jake Mor on 5/1/15.
//  Copyright (c) 2015 Jake Mor. All rights reserved.
//

import Foundation
import UIKit

var currentLink:NSURLRequest!


extension UIViewController {
	
	func goToScene(name: String) {
		let nav = self.navigationController?.navigationBar
		let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier(name)
		self.showViewController(vc as! UIViewController, sender: vc)
	}
	
	func stylizeNavBar() {
		let nav = self.navigationController?.navigationBar
		nav?.barTintColor = UIColor.blackColor()
		nav?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
	}
	
}
