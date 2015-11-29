//
//  ChangePasswordVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/20/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    
    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
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
    
    @IBOutlet weak var scrollView: UIScrollView!
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
        if textField == self.oldPasswordTextField {
            self.newPasswordTextField.becomeFirstResponder()
        } else if textField == self.newPasswordTextField {
            self.repeatNewPasswordTextField.becomeFirstResponder()
        } else if textField == self.repeatNewPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == repeatNewPasswordTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 20), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetPasswordTapped(sender: AnyObject) {
        saveAction()
    }
    
    func saveAction() {
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let repeatNewPassword = repeatNewPasswordTextField.text!
        
        if (newPassword != repeatNewPassword) {
            commonMethods.displayAlertMessage("New Password Does Not Match!", userMessage: "Please Enter the New Password Again!", sender: self)
        }
        
        activityIndicator()
        
        // MARK : post request to server
        
        params = "oldpassword=\(oldPassword)&newpassword=\(newPassword)"
        jsonData = commonMethods.sendRequest(changePasswordURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            stopActivityIndicator()
            return
        }
        
        let myAlert = UIAlertController(title: "Change Password Successful!", message: "Please Log In Again!", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
            NSUserDefaults.standardUserDefaults().synchronize()
            userInformation = nil
            self.performSegueWithIdentifier("changePasswordToLogin", sender: self)
        }))
        presentViewController(myAlert, animated: true, completion: nil)
    }
}
