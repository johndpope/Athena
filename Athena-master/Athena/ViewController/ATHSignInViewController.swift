//
//  ATHMainViewController.swift
//  AthenaUI
//
//  Created by Fangzhou Liu on 17/4/13.
//  Copyright © 2017年 Fangzhou Liu. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class ATHSignInViewController: ATHBaseViewController, ATHSignInViewDelegate, ATHFootViewDelegate {
    internal func keyboardDisappear(_ text: String, _ tag: ATHInputStyle) {
        //
    }

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var didSignInObserver: AnyObject!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add two input text field
        let username = ATHSignInView(frame: CGRect(x: 0, y: 400, width: SCREEN_WIDTH, height: 60), type: ATHInputStyle.ATHNormal)
        let password = ATHSignInView(frame: CGRect(x: 0, y: username.y+username.height, width: SCREEN_WIDTH, height: 60), type: ATHInputStyle.ATHPassword)
//        VIEWBORDER(view: username, color: UIColor.white, width: 2.0)
//        VIEWBORDER(view: password, color: UIColor.white, width: 2.0)
        username.delegate = self
        password.delegate = self
        self.scrollView.addSubview(username)
        self.scrollView.addSubview(password)
        
        // Add the sign in button
        let signin_btn = ATHLogButton(frame: CGRect(x: 25, y: password.y+password.height+50, width: SCREEN_WIDTH-50, height: 40), title: "Sign In", bgcolor: BTN_BACKGROUND_COLOR)
        signin_btn.addTarget(self, action: #selector(self.log_in(_:)), for: .touchUpInside)
        self.scrollView.addSubview(signin_btn)
        
        // Do any additional setup after loading the view, typically from a nib.
        let footer = ATHFootView(frame: CGRect(x: 0, y: SCREEN_HEIGHT-44, width: SCREEN_WIDTH, height: 44), label: "Don't have an account?", btntitle: "Sign Up")
        footer.delegate = self
        self.scrollView.addSubview(footer)
        
        didSignInObserver =  NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: {(note: Notification) -> Void in
            // perform successful login actions here
        })


    }
    
    func log_in(_ sender: UIButton)  {
        print("\(sender.titleLabel?.text)")
    }
    
    // MARK: ATHSignInViewDelegate
    
    func keyboardAppear(_ offset: Double) {
        print("Offset up \(offset)")
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: offset)
    }
    
    func keyboardDisappear() {
        print("Offset down")
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    // MARK: ATHFooterViewDelegate
    
    func sign_up(_ sender: UIButton) {
        print("\(sender.titleLabel?.text)")
    }
    
    deinit {
        if (didSignInObserver != nil) {
            NotificationCenter.default.removeObserver(didSignInObserver)
        }
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Utility Methods
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSIdentityManager.default().login(signInProvider: signInProvider, completionHandler:
            {(result: Any?, error: Error?) in
                if error == nil {
                    print("\n\ngoing to main screen\n")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                    self.present(viewController, animated:true, completion: nil)
                    print("should have switched views")
                }
                print("Login with signin provider result = \(result), error = \(error)")
        })
    }
    
    func showErrorDialog(_ loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Sign-in Provider Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Label to cancel sign-in failure."), style: .cancel, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
        print("SHOWING ERROR\n")
    }

    
}
