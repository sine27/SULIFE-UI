//
//  ForgetPasswordVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/10/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class ForgetPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
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
    
    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Mark : Text field >>>>>
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // // Tab The blank place, close keyboard
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // <<<<<
    
    @IBAction func forgetPasswordTapped(sender: UIButton) {

        // TODO send password to user email
        let username = usernameTextField.text!
        if (username.isEmpty) {
            commonMethods.displayAlertMessage("Input Error", userMessage: "Please enter the Username!", sender: self)
            return
        }
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            params = "username=\(username)"
            jsonData = commonMethods.sendRequest(forgetPasswordURL, postString: params, postMethod: "POST", postHeader: "", accessString: "", sender: self)
            
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let myAlert = UIAlertController(title: "Forget Password!", message: "Password has been sent to \nyour E-mail!", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    self.performSegueWithIdentifier("forgetPasswordToLogin", sender: self)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated:true, completion:nil)
                
                self.stopActivityIndicator()
            })
        })
    }
}
