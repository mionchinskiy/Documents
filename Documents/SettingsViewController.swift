

import UIKit

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsDelegate?
    
//MARK: UI elements
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    private lazy var switchAlphabetical = {
        let switchItem = UISwitch()
        switchItem.isOn = !UserDefaults.standard.bool(forKey: "notAlphabeticalOrder")
        switchItem.addTarget(self, action: #selector(changedSwitchAlphabetical), for: .valueChanged)
        return switchItem
    }()
    
    private lazy var switchSizeForPhoto = {
        let switchItem = UISwitch()
        switchItem.isOn = !UserDefaults.standard.bool(forKey: "noSizeForPhoto")
        switchItem.addTarget(self, action: #selector(changedSwitchSizeOfPhoto), for: .valueChanged)
        return switchItem
    }()
    
//MARK: Init and setup
    
    init(delegate: SettingsDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),])
    }
    
    private func setupNavigationBar() {
        self.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func changedSwitchAlphabetical() {
        if switchAlphabetical.isOn {
            UserDefaults.standard.set(false, forKey: "notAlphabeticalOrder")
            delegate?.updateDirectoryVCWithSettings()
        } else {
            UserDefaults.standard.set(true, forKey: "notAlphabeticalOrder")
            delegate?.updateDirectoryVCWithSettings()
        }
    }
    
    @objc func changedSwitchSizeOfPhoto() {
        if switchSizeForPhoto.isOn {
            UserDefaults.standard.set(false, forKey: "noSizeForPhoto")
            delegate?.updateDirectoryVCWithSettings()
        } else {
            UserDefaults.standard.set(true, forKey: "noSizeForPhoto")
            delegate?.updateDirectoryVCWithSettings()
        }
    }

}



extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: "UITableViewCell")
        var config = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            config.text = "Сортировка файлов по алфавиту"
            cell.accessoryView = switchAlphabetical
        case 1:
            config.text = "Показывать размер фотографии"
            cell.accessoryView = switchSizeForPhoto
        case 2:
            config.text = "Поменять пароль"
            cell.accessoryView = UIImageView(image: UIImage(systemName: "keyboard.badge.ellipsis"))
            cell.accessoryView?.tintColor = .systemGray2
        default: break
        }
        
        cell.contentConfiguration = config
        return cell
    }

}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let loginVC = LoginViewController(passwordNeedSetup: true)
            loginVC.keychain.delete("password")
            loginVC.loginButton.setTitle("Изменить пароль", for: .normal)
            self.present(loginVC, animated: true)
        }
    }
    
}
