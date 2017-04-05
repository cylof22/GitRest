//
//  LoginViewController.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/4/4.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import UIKit

protocol LoginViewDelegate : class {
    func didTapLoginButton()
}

class LoginViewController : UIViewController
{
    weak var m_delegate : LoginViewDelegate?
    
    @IBAction func tappedLoginButton() {
        if m_delegate != nil {
            m_delegate!.didTapLoginButton()
        }
    }
}
