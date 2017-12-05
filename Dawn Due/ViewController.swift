//
//  ViewController.swift
//  Dawn Due
//
//  Created by Ryan Hart on 12/11/15.
//  Copyright © 2015 Ryan Hart. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var newItemField: UITextField!
	@IBOutlet weak var toDoListTable: UITableView!
	@IBOutlet weak var dockViewHeightContraint: NSLayoutConstraint!
	
	var kbHeight: CGFloat!
	
	var toDoList = [String]()
	
	override func viewDidLoad() {
		
		self.toDoListTable.delegate = self
		self.toDoListTable.dataSource = self
		
		self.newItemField.delegate = self
		
		// super.viewDidLoad()
		
		//
		let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tapGesture)
		
		// Retrieve toDoList from memory and store it in the array
		if NSUserDefaults.standardUserDefaults().objectForKey("toDoList") != nil {
			toDoList = NSUserDefaults.standardUserDefaults().objectForKey("toDoList") as! [String]
		}
		
	}
	
	// In the case where the toDoList array was changed while inactive and toDoListTable was not reloaded, reload it.
	// Might not be necessary
	override func viewDidAppear(animated: Bool) {
		toDoListTable.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func addItemBtn(sender: AnyObject) {
		
		// Add string from newItemField to the end of the toDoList array
		toDoList.append(newItemField.text!)
		
		// Empty the text field to be ready for the user to add another item
		newItemField.text = ""
		
		commitNewToDoListItem()
	}
	
	func commitNewToDoListItem() {
		
		// Immediately reload the table view after the array has been updated
		toDoListTable.reloadData()
		
		// Then store the contents of that array into persistent storage
		NSUserDefaults.standardUserDefaults().setObject(toDoList, forKey: "toDoList")
	}
	
	// Make the tableview only as large as the length of the toDoList array
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return toDoList.count
	}
	
	// MARK: TextField Delegate Methods
	
/* Commented out for now, because I found a potentially better way.
	
	func textFieldDidBeginEditing(textField: UITextField) {
		
		view.layoutIfNeeded()
		UIView.animateWithDuration(0.5, animations: {
			
			self.dockViewHeightContraint.constant = 350 // self.kbHeight
			self.view.layoutIfNeeded()
			
			}, completion: nil)
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		
		view.layoutIfNeeded()
		UIView.animateWithDuration(0.5, animations: {
			
			self.dockViewHeightContraint.constant = 44
			self.view.layoutIfNeeded()
			
			}, completion: nil)
	}
*/
	// MARK: TableView Delegate Methods
	
	// Fill each tableview cell with each value of the toDoList array
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// Create a table cell
		let cell = self.toDoListTable.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
		
		// Customize the cell
		cell.textLabel?.text = toDoList[indexPath.row]
		
		// Return the cell
		return cell
	}
	
	// Adding delete support
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			toDoList.removeAtIndex(indexPath.row)
			commitNewToDoListItem()
		}
	}
	
	// MARK: Dismissing the keyboard
	
	// This function is called in order to dismiss the keyboard
	func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
	
	// Tapping return on keyboard dismisses keyboard
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: Methods to move UI above the keyboard
	
	override func viewWillAppear(animated:Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
				kbHeight = keyboardSize.height
				self.animateTextField(true)
				print("Keyboard is now showing")
			}
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		self.animateTextField(false)
		print("Keyboard is now hiding")
	}
	
	func animateTextField(up: Bool) {
		let movement = (up ? -kbHeight : kbHeight)
		print("Keyboard height is currently \(movement)")
		
		UIView.animateWithDuration(0.3, animations: {
			self.view.frame = CGRectOffset(self.view.frame, 0, movement)
		})
	}
	
	static func displayStatusChanged() {
		
		// the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
		
		var lockState = String name
		print("Darwin notification NAME = \(name)")
		
		if([lockState isEqualToString:@"com.apple.springboard.lockcomplete"])
		{
			print("DEVICE LOCKED")
		}
		else
		{
			print("LOCK STATUS CHANGED")
		}
		
	}
	
	func registerForDeviceLockNotif() {
		
		//Screen lock notifications
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
			NULL, // observer
			displayStatusChanged, // callback
			CFSTR("com.apple.springboard.lockcomplete"), // event name
			NULL, // object
			CFNotificationSuspensionBehaviorDeliverImmediately);
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
			NULL, // observer
			displayStatusChanged, // callback
			CFSTR("com.apple.springboard.lockstate"), // event name
			NULL, // object
			CFNotificationSuspensionBehaviorDeliverImmediately);
		
	}
}

