//
//  NotificationDetailVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/13/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class NotificationDetailVC: UIViewController {
    
    @IBOutlet weak var senderTextView: UITextView!
    @IBOutlet weak var senderEmailTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var contactsInit : [NSDictionary] = []
    var senderDetail : NotificationModel!
    var contactVC : ContactVC!
    
    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    func activityIndicator() {
        
        blur.frame = CGRectMake(30, 30, 60, 60)
        blur.layer.cornerRadius = 10
        blur.center = self.view.center
        blur.clipsToBounds = true
        
        spinner.frame = CGRectMake(0, 0, 50, 50)
        spinner.hidden = false
        spinner.center = self.view.center
        spinner.startAnimating()
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
    }
    
    func stopActivityIndicator() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        stopActivityIndicator()
    }
    
    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSLog("firstname in detail = %@", senderDetail.firstName)
        
        senderTextView.userInteractionEnabled = false
        senderEmailTextView.userInteractionEnabled = false
        let fullname = (senderDetail.firstName as String) + " " + (senderDetail.lastName as String)
        senderEmailTextView.text = senderDetail.email as String
        senderTextView.text = fullname
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptButtonTapped(sender: UIButton) {
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if ( self.isFriend(self.senderDetail.requestOwnerID) == true ) {
                
                self.stopActivityIndicator()
                
                let myAlert = UIAlertController(title: "Action Failed!", message: "Is Your Firend Already!", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated:true, completion:nil)
                self.acceptButton.userInteractionEnabled = false
                self.rejectButton.userInteractionEnabled = false
                self.rejectCancel()
                return
            }
            
            let relationshipID = self.senderDetail!.relationshipID
            
            params = "mailid=\(relationshipID)"
            jsonData = commonMethods.sendRequest(AcceptFriendIDURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
            }

            dispatch_async(dispatch_get_main_queue(), {
                
                let myAlert = UIAlertController(title: "Accept Request", message: "Successful!", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    self.navigationController!.popViewControllerAnimated(true)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated:true, completion:nil)
                
                self.stopActivityIndicator()
            })
        })
    }
    
    @IBAction func rejectButtonTapped(sender: UIButton) {
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.rejectCancel()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController!.popViewControllerAnimated(true)
                self.stopActivityIndicator()
            })
        })
    }
    
    // prevent duplication
    func rejectCancel () {

        // MARK : post request to server
        
        let relationshipID = senderDetail!.relationshipID
        
        params = "mailid=\(relationshipID)"
        jsonData = commonMethods.sendRequest(RejectFriendIDURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator()
            })
            return
        }
    }
    
    func isFriend (currentContactID : NSString) -> Bool {
        
        // MARK : post request to server
        
        params = ""
        jsonData = commonMethods.sendRequest(getContactsURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            
            stopActivityIndicator()
            
            // If Data from server is empty: no friend in the list
            return false
        }
        
        contactsInit = jsonData.valueForKey("relationships") as! [NSDictionary]
        
        for contact in contactsInit {
            let contactID = contact.valueForKey("userid2") as! NSString
            if (currentContactID == contactID) {
                return true
            }
        }
        return false
    }

}
