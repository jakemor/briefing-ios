//
//  *Webview.swift
//  Briefing
//
//  Created by Jake Mor on 5/1/15.
//  Copyright (c) 2015 Jake Mor. All rights reserved.
//

import UIKit

class _Webview: UIViewController, UIWebViewDelegate {
	
	// ui elements
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var logo: UIImageView!
	
	
	// forward declarations
	var circleProgress: KYCircularProgress!
	var progress: Double = 0.0
	var progressEnd: Double = 0.0
	var delta: Double = 0
	var mult:Double = 1.08
	var notShown = true
	var on = true
	var timer:NSTimer!
	var doneRotating = false
	
	func configureKYcircleProgress() {
		let circleProgressFrame = CGRectMake(0, 0, 150,150)
		circleProgress = KYCircularProgress(frame: circleProgressFrame)
		circleProgress.colors = [
			UIColor.blackColor(),
			UIColor.blackColor(),
			UIColor.blackColor(),
			UIColor.blackColor()
		]
		circleProgress.lineWidth = 3
		self.loadingView.addSubview(circleProgress)
		rotate()
	}
	
	func rotate() {
		if (doneRotating) {
			return
		}
		
		println("rotate")
		UIView.animateWithDuration(4.0,
			delay: 0.0,
			options: .CurveLinear,
			animations: {self.loadingView.transform = CGAffineTransformRotate(self.loadingView.transform, 3.1415926)},
			completion: {finished in self.rotate()})
	}
	
	func updateProgress() {
		if (on) {
			if (progress < 255*(30/32)) {
				progress = progress + (255*(30/32) - progress)/150
				delta = progress/255 - circleProgress.progress
				circleProgress.progress = progress/255
				progressEnd = progress/255
				mult = pow((1.0-progressEnd)/delta, 1.0/66)
			}
		} else if (notShown) {
			circleProgress.progress += delta
			delta = delta*mult
		}
		
	}
	
	@IBAction func openInSafari(sender: AnyObject) {
		
		let optionMenu = UIAlertController(title: nil, message: "Page Options", preferredStyle: .ActionSheet)
		
		let refreshAction = UIAlertAction(title: "Refresh", style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.webView.reload()
		})
		
		let openSafariAction = UIAlertAction(title: "Open in Safari", style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			 UIApplication.sharedApplication().openURL(currentLink.URL!)
		})
		
		let openChromeAction = UIAlertAction(title: "Open in Chrome", style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in
			
			let scheme = currentLink.URL?.scheme!
			
			var chromeScheme:String! = nil
			
			if (scheme == "http") {
				chromeScheme = "googlechrome"
			} else if (scheme == "https") {
				chromeScheme = "googlechromes"
			}
			
			var link:NSString! = nil
			
			if (chromeScheme != nil) {
				link = currentLink.URL?.absoluteString
				let range = link.rangeOfString(":")
				let linkNoScheme = link.substringFromIndex(range.location)
				let chromeLink = "\(chromeScheme)\(linkNoScheme)"
				let chromeUrl = NSURL(string: chromeLink)
				if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "googlechrome://")!)) {
					UIApplication.sharedApplication().openURL(chromeUrl!)
				} else {
					var alert = UIAlertView()
					alert.title = "Whoops!"
					alert.message = "It seems like you don't have Chrome installed."
					alert.addButtonWithTitle("Okay")
					alert.show()
				}
			} else {
				var alert = UIAlertView()
				alert.title = "Sorry"
				alert.message = "There seems to be something wrong with this website. We cannot open it in Chrome."
				alert.addButtonWithTitle("Okay")
				alert.show()
			}
			
		})
		
		let shareAction = UIAlertAction(title: "Share", style: .Default, handler: {
			(alert: UIAlertAction!) -> Void in

		})
		

		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in

		})
		
		
		optionMenu.addAction(openSafariAction)
		optionMenu.addAction(openChromeAction)
		optionMenu.addAction(refreshAction)
		optionMenu.addAction(shareAction)
		optionMenu.addAction(cancelAction)
		
		self.presentViewController(optionMenu, animated: true, completion: nil)
		
	
	}
	@IBOutlet weak var webView: UIWebView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		println("view did load")
		configureKYcircleProgress()
		
        timer = NSTimer.scheduledTimerWithTimeInterval(0.015, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
		webView.alpha = 0
		webView.loadRequest(currentLink)
		on = true
		self.title = ""
    }
	
	func tappedLink(request: NSURLRequest) {
		currentLink = request
		let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("Webview")
		self.showViewController(vc as! UIViewController, sender: vc)
	}
	
	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		
		switch navigationType {
			case .LinkClicked:
				println("tapped link!!")
				tappedLink(request)
				return false
			default:
				let x = 0
		}
	
		return true
	}
	
	
	// webview delegate
	
	func webViewDidFinishLoad(webView: UIWebView) {
		
		if (on) {
			on = false
			UIView.animateWithDuration(0.25, delay: 0.55, options: .CurveEaseInOut, animations: {
				webView.alpha = 1
				}, completion: {finished in
					self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
					self.notShown = false
					self.timer.invalidate()
					self.circleProgress.removeFromSuperview()
					self.doneRotating = true
			})
			
		
		}
	}
	
}
