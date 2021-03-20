//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Henry Lao on 3/19/21.
//
import Parse
import UIKit

class LoginViewController: UIViewController {
    var TAG = "LoginView"
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (user,error) in
            if user != nil{
                print(self.TAG, "Success: Account created!")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print(self.TAG, "Error: \(error?.localizedDescription)")
            }
        }
    }
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
//        user.email = "email@example.com"
        user.signUpInBackground{ (success, error) in
            if success {
                print(self.TAG, "Success: Account created!")
                self.performSegue(withIdentifier: "loginSegue", sender:nil)
            } else {
                print(self.TAG, "Error: \(error?.localizedDescription)")
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
