//
//  AddContactVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/12/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class AddContactVC: UIViewController {

    // CONTACT ID
    @IBOutlet weak var ContactID: UITextField!
    
    var contactsInit : [NSDictionary] = []
    
    var myuserReturn = NSDictionary()
    var fuckingUserID: NSString = "";
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    
    // Mark : Text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Mark : Text field END
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendRequestTapped(sender: UIButton) {
        
        // TODO:
        let userEmail = ContactID.text!
        if (userEmail.isEmpty) {
            let myAlert = UIAlertController(title: "Send Request Failed!", message: "Please enter the username!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated:true, completion:nil)
        }
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // MARK : post request to server
            
            params = "email=\(userEmail)"
            jsonData = commonMethods.sendRequest(GetUserIDURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
            
            if (jsonData.objectForKey("message") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
            }
            if (jsonData.objectForKey("user") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                commonMethods.displayAlertMessage("Input Error", userMessage: "No such user!", sender: self)
                return
            }
            
            self.fuckingUserID = (jsonData.valueForKey("user")!.valueForKey("_id") as! NSString)
            print("User ID : ", userInformation!.id)
            
            if ( self.fuckingUserID == userInformation!.id ) {
                commonMethods.displayAlertMessage("Input Error", userMessage: "Don not add yourself!", sender: self)
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
                
            } else if ( self.isFriend(self.fuckingUserID) == true ) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                commonMethods.displayAlertMessage("Input Error", userMessage: "Contact exist already!", sender: self)
                return
                
            } else {
                params = "taker=\(self.fuckingUserID)"
                jsonData = commonMethods.sendRequest(addFriendURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
                
                print("JSON data returned : ", jsonData)
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    return
                }
                
                let myAlert = UIAlertController(title: "Friend Request Sent!", message: "Please wait for the reply! ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                    self.stopActivityIndicator()
                }))
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator()
            })
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ContactID.resignFirstResponder();
    }
    
    func isFriend (currentContactID : NSString) -> Bool {
        
        // MARK : post request to server
        
        params = ""
        jsonData = commonMethods.sendRequest(getContactsURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)

        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            stopActivityIndicator()
            return true
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
