//
//  LoginVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/12/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit


// MARK : global properties

// >>>>> NSURLs for server

let registerURL = "https://damp-retreat-5682.herokuapp.com/register"
let loginURL = "https://damp-retreat-5682.herokuapp.com/local/login"
let GetUserIDURL = "https://damp-retreat-5682.herokuapp.com/findUser"
let profileURL = "https://damp-retreat-5682.herokuapp.com/profile"
let forgetPasswordURL = "https://damp-retreat-5682.herokuapp.com/resetPassword"
let changePasswordURL = "https://damp-retreat-5682.herokuapp.com/changePassword"

let eventURL = "https://damp-retreat-5682.herokuapp.com/event"
let eventByDateURL = "https://damp-retreat-5682.herokuapp.com/eventd"
let taskURL = "https://damp-retreat-5682.herokuapp.com/task"
let taskByDateURL = "https://damp-retreat-5682.herokuapp.com/taskd"

let addFriendURL = "https://damp-retreat-5682.herokuapp.com/friendRequest"
let NotificationURL = "https://damp-retreat-5682.herokuapp.com/getMail"
let AcceptFriendIDURL = "https://damp-retreat-5682.herokuapp.com/acceptFriendRequest"
let RejectFriendIDURL = "https://damp-retreat-5682.herokuapp.com/rejectFriendRequest"
let getContactsURL = "https://damp-retreat-5682.herokuapp.com/getFriends"
let getUserInformation = "https://damp-retreat-5682.herokuapp.com/getUserInformation"
let deleteContactURL = "https://damp-retreat-5682.herokuapp.com/deleteFriend"
let getFriendEvents = "https://damp-retreat-5682.herokuapp.com/eventf"

// <<<<<

var accountToken = ""
var userInformation : UserModel?
var jsonData = NSDictionary()
var params : NSString = ""

// Common Methods Call
let commonMethods = CommonMethodCollection()

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
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
    
    // Mark : View Setup >>>>>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Text field
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.userPasswordTextField.becomeFirstResponder()
        } else if textField == self.userPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == userPasswordTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 20), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    // <<<<<
    
    // Actions >>>>>
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        activityIndicator()
        
        // properties
        let username = usernameTextField.text!
        let userPassword = userPasswordTextField.text!
        
        // fill in required fields
        if ( username.isEmpty ) {
            commonMethods.displayAlertMessage("Login Failed!", userMessage: "Please enter Username", sender: self)
        } else if ( userPassword.isEmpty ) {
            commonMethods.displayAlertMessage("Login Failed!", userMessage: "Please enter Password", sender: self)
        }
            
        else {
            params = "email=\(username)&password=\(userPassword)"
            jsonData = commonMethods.sendRequest(loginURL, postString: params, postMethod: "POST", postHeader: "", accessString: "", sender: self)
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                stopActivityIndicator()
                return
            }
            
            accountToken = jsonData.valueForKey("Access_Token") as! String
            
            print("Login SUCCESS")
            print("accountToken : ", accountToken)
            
            // get user's profile
            jsonData = commonMethods.sendRequest(profileURL, postString: "", postMethod: "get", postHeader: accountToken, accessString: "x-access-token", sender: self)
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                commonMethods.displayAlertMessage("System Error", userMessage: "Post Profile Failed!", sender: self)
                stopActivityIndicator()
                return
            }
            let jsonInform = jsonData.valueForKey("profile") as! NSDictionary
            let firstName = jsonInform.valueForKey("firstname") as! NSString
            let lastName = jsonInform.valueForKey("lastname") as! NSString
            let email = jsonInform.valueForKey("email") as! NSString
            let id = jsonInform.valueForKey("userid") as! NSString
            
            userInformation = UserModel(firstName: firstName, lastName: lastName, email: email, id: id)
            
            // isUserLoggedIn
            let isUserLoggedIn : Bool = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
            if (isUserLoggedIn) {
                stopActivityIndicator()
                commonMethods.displayAlertMessage("Coding Error", userMessage: "isUserLoggedIn in LoginVC", sender: self)
            } else {
                let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                prefs.setObject(username, forKey: "username")
                prefs.setInteger(1, forKey: "isUserLoggedIn")
                prefs.synchronize()
                self.performSegueWithIdentifier("loginToStart", sender: self)
            }
        }
    }
    // Actions <<<<<
}