//
//  ViewController.swift
//  Briefing
//
//  Created by Jake Mor on 5/1/15.
//  Copyright (c) 2015 Jake Mor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
	
	
	// ui elements
	@IBOutlet weak var logo: UIImageView!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var refreshView: UIView!
	@IBOutlet weak var refreshViewConstraint: NSLayoutConstraint!
	
	// forward declarations
	var startedLoading = false
	var circleProgress: KYCircularProgress!
	var progress: Double = 0.0
	var progressEnd: Double = 0.0
	var delta: Double = 0
	var mult:Double = 1.08
	var notShown = true
	var on = true
	var timer:NSTimer!
	var startRefreshing = false
	var refreshing = false
	var doneRotating = false
	var reloadProgress: KYCircularProgress!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(true, animated: false)
		let url = NSURL(string: "http://briefi.ng/?mode=ios")
		//let url = NSURL(string: "file:///Users/jake/Desktop/briefing.html")
		let requestObj = NSURLRequest(URL: url!)
		webView.loadRequest(requestObj)
		webView.alpha = 0
		refreshView.alpha = 0
		webView.scrollView.delegate = self
		webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		webView.scrollView.addSubview(refreshView)
		webView.scrollView.sendSubviewToBack(refreshView)
		webView.scrollView.decelerationRate = 0.998
		stylizeNavBar()
		
		configureCircleProgress()
		timer = NSTimer.scheduledTimerWithTimeInterval(0.015, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
		
	}
	
	override func viewWillAppear(animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	// methods
	
	func configureCircleProgress() {
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
		} else {
			
		}
		
	}
	
	func tappedLink(request: NSURLRequest) {
		currentLink = request
		let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("Webview")
		self.showViewController(vc as! UIViewController, sender: vc)
	}
	
	// webview delegate methods

	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		var alert = UIAlertView()
		alert.title = "Uh Oh..."
		alert.message = "Are you connected to the internet? We're having trouble reaching our servers."
		alert.addButtonWithTitle("I'll Check")
		alert.show()
	}

	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		
		switch navigationType {
		case .LinkClicked:
			tappedLink(request)
			return false
		default:
			let x = 0

		}
		
		return true
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
		if (!webView.loading && !refreshing) {
			on = false
			UIView.animateWithDuration(0.25, delay: 0.5, options: .CurveEaseInOut, animations: {
				webView.alpha = 1
				self.view.backgroundColor = UIColor.blackColor()
				}, completion: {finished in
					self.notShown = false
					self.timer.invalidate()
					self.circleProgress.removeFromSuperview()
					self.logo.removeFromSuperview()
					self.doneRotating = true
			})
		}
		
		if (refreshing) {
			webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
			refreshing = false
		}
		
	}
	
	// scrollview delegate methods
	
	func scrollViewDidScrollToTop(scrollView: UIScrollView) {
		println("scrollViewDidScrollToTop")
		refreshView.alpha = 1
	}
	
	
	func refresh() {
		webView.reload()
	}
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (startRefreshing) {
			println("I should refresh")
			startRefreshing = false
			refreshing = true
			refresh()
			webView.scrollView.contentInset.top = 128
		}
	}
	
	func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
		refreshing = false
		webView.scrollView.contentInset.top = 0
	}
	
	
}


