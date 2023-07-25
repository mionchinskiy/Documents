

import UIKit
import KeychainSwift

protocol SettingsDelegate: AnyObject {
    
    func updateDirectoryVCWithSettings()
    
}


class LoginViewController: UIViewController {
    
    let keychain = KeychainService()
    
    let directoryViewController = DirectoryViewController(currentURL: FileManager.default.urls(for: .documentDirectory,
                                                                                               in: .userDomainMask)[0])

//MARK: UI elements
    
    private lazy var passwordField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .bezel
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 12
        return textField
    }()
    
    lazy var loginButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var alertNotConfirmedPassword = {
        let alert = UIAlertController(title: "СТОП", message: "Повторно введенный пароль не совпадает с предыдущим", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Попробовать заново", style: .default))
        return alert
    }()
    
    private lazy var alertNotConfirmedPasswordForLogin = {
        let alert = UIAlertController(title: "СТОП", message: "Неверно указан пароль", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Попробовать заново", style: .default))
        return alert
    }()
    
//MARK: Init and setup
    
    init(passwordNeedSetup: Bool) {
        super.init(nibName: nil, bundle: nil)
        if passwordNeedSetup {
            self.loginButton.setTitle("Создать пароль", for: .normal)
            self.loginButton.addTarget(self, action: #selector(createPasswordWithLoginButton), for: .touchUpInside)
        } else {
            self.loginButton.setTitle("Введите пароль", for: .normal)
            self.loginButton.addTarget(self, action: #selector(loginWithLoginButton), for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(passwordField)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                                     passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     passwordField.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height/3),
                                     
                                     loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                                     loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
                                     loginButton.heightAnchor.constraint(equalTo: passwordField.heightAnchor, multiplier: 2)
                                    ])
    }
    
    private func successLogin() {
        directoryViewController.tabBarItem = UITabBarItem(title: "Documents", image: UIImage(systemName: "folder.fill"), tag: 0)
        
        let settingsViewController = SettingsViewController(delegate: self)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [UINavigationController(rootViewController: directoryViewController),
                                            UINavigationController(rootViewController: settingsViewController)]
        tabBarController.modalPresentationStyle = .fullScreen
        
        self.present(tabBarController, animated: true)
    }
    
//MARK: Actions for buttons
    
    @objc func createPasswordWithLoginButton() {
        guard passwordField.text!.count > 3 else {
            print("Длина пароля - не менее 4 символов")
            return
        }
        
        guard keychain.set(passwordField.text!, forKey: "passwordTemp") else {
            print("Ошибка - пароль не был сохранен в Keychain")
            return
        }

        self.passwordField.text?.removeAll()
        loginButton.setTitle("Повторите пароль", for: .normal)
        loginButton.removeTarget(self, action: #selector(createPasswordWithLoginButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(confirmCreatePasswordWithLoginButton), for: .touchUpInside)
    }
    
    @objc func confirmCreatePasswordWithLoginButton() {
        guard passwordField.text!.count > 3 else {
            print("Длина пароля - не менее 4 символов")
            return
        }
        
        guard keychain.set(passwordField.text!, forKey: "password") else {
            print("Ошибка - повторно введенный пароль не был сохранен в Keychain")
            return
        }
        
        guard keychain.get("passwordTemp") == keychain.get("password") else {
            print("Ошибка - повторно введенный пароль не совпадает с предыдущим")
            self.present(alertNotConfirmedPassword, animated: true)
            self.passwordField.text?.removeAll()
            keychain.delete("passwordTemp")
            keychain.delete("password")
            loginButton.setTitle("Создать пароль", for: .normal)
            loginButton.removeTarget(self, action: #selector(confirmCreatePasswordWithLoginButton), for: .touchUpInside)
            loginButton.addTarget(self, action: #selector(createPasswordWithLoginButton), for: .touchUpInside)
            return
        }
        keychain.delete("passwordTemp")
        successLogin()
    }
    
    @objc func loginWithLoginButton() {
        guard keychain.get("password") == passwordField.text else {
            print("Такого пароля не существует")
            self.present(alertNotConfirmedPasswordForLogin, animated: true)
            self.passwordField.text?.removeAll()
            return
        }
        successLogin()
    }
}

extension LoginViewController: SettingsDelegate {
    
    func updateDirectoryVCWithSettings() {
        directoryViewController.tableView.reloadData()
    }
    
}
