//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Anurag Bhatt on 11/05/24.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit



class LoginViewController: UIViewController {
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
        
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Adress..."
        
        field.leftView = UIView(frame: CGRect(x : 0 , y : 0 , width : 5 , height : 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.isSecureTextEntry = true
        field.leftView = UIView(frame: CGRect(x : 0 , y : 0 , width : 5 , height : 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        
        return field
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20 , weight: .bold)
        
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register" ,
                                                            style : .done ,
                                                            target : self ,
                                                            action : #selector(didTapRegister))
        
        loginButton.addTarget(self,action: #selector(loginButtonTapped),for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        
        // add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x : (scrollView.width - size)/2,
                                 y : 20 ,
                                 width : size,
                                 height : size)
        
        emailField.frame = CGRect(x : 30,
                                  y : imageView.bottom+10 ,
                                  width : scrollView.width-60,
                                  height : 52)
        
        passwordField.frame = CGRect(x : 30,
                                     y : emailField.bottom+10 ,
                                     width : scrollView.width-60,
                                     height : 52)
        
        loginButton.frame = CGRect(x : 30,
                                   y : passwordField.bottom+10 ,
                                   width : scrollView.width-60,
                                   height : 52)
        
        
        facebookLoginButton.frame = CGRect(x : 30,
                                           y : loginButton.bottom+10 ,
                                           width : scrollView.width-60,
                                           height : 52)
        
        facebookLoginButton .frame.origin.y = loginButton.bottom+20
        
    }
    
    @objc private func loginButtonTapped() {
        
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text ,
              let password = passwordField.text ,
              !email.isEmpty , !password.isEmpty ,
              password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        
        // implementing the login using google firebase
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult , error in
            
            guard let strongSelf = self else
            {
                return
            }
            guard let result = authResult , error == nil else{
                
                print("Failed to login user with email : \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user : \(user)")
            
            strongSelf.navigationController?.dismiss(animated: true , completion: nil)
            
        })
        
    }
    
    func alertUserLoginError()
    {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to login",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel ,
                                      handler: nil))
        
        present(alert , animated: true)
    }
    
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        vc.title = "Create New Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


extension LoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            loginButtonTapped()
        }
        
        return true
    }
}


extension LoginViewController : LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //        no operations
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: (any Error)?) {
        
        guard let token = result?.token?.tokenString else {
            
            print("User failed to login with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me" ,
                                                         parameters: ["fields" : "email,name"],
                                                         tokenString: token ,
                                                         version: nil ,
                                                         httpMethod: .get)
        
        facebookRequest.start(completion: { _, result , error in
            
            guard let result = result as? [String : Any], error == nil else
            {
                print("Failed to make Facebook graph request")
                return
            }
            
            
            guard let userName = result["name"] as? String ,
                  let email = result["email"] as? String else
            {
                print("Failed to get email and name from fb results ")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email , completion: {exists in
                
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            })
            
            
            let credential = OAuthProvider.credential(withProviderID: "facebook.com", accessToken: "EAAXNgdImDSABO0EQzfrrzZCNIzE5rhNcenyYOZAc31AZCGADApd7N5DzzS7XXFDKVFSgyTtJIeMFbKmhZAu3Wa2GkZBd27aMrWrMtd6Qw1IEh9WgibYZAfwPhoPEFJ7SaOKMoptCVO9LxAZAgwHMh1vqIirN42Drs1d3aEZAGhOtM5t1mF9so313RpoP7SZBNyt5K1bvz4N2yPhMs4cISBZA4FhXDaf6PdZBtLZCSrc02vrQlTZC71HZCasmgjahRKcCABnwLBfQ5pM6y85FAZD")
            
            FirebaseAuth.Auth.auth().signIn(with: credential , completion: {[weak self] authResult , error in
                
                guard let strongSelf = self else{
                    return
                }
                guard authResult != nil , error == nil else{
                    
                    if let error = error{
                        print("Facebook credentials login failed MFA may be needed - \(error) ")
                    }
                    return
                    
                }
                
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true , completion: nil)
            })
        })
        
        
    }
}
