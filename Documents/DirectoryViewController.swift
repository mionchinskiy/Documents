

import UIKit

class DirectoryViewController: UIViewController {
    
    let fileManagerService = FileManagerService()
    var currentURL: URL
    
//MARK: UI elements
    
    lazy var tableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    private lazy var alertAddDirectory = {
        let alert = UIAlertController(title: "Create new folder", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Folder name"
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
                self?.fileManagerService.createDirectory(withName: textField.text!, at: self!.currentURL)
                self?.tableView.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    private lazy var imagePicker = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
//MARK: Setup

    init(currentURL: URL) {
        self.currentURL = currentURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupNavigationBar()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),])
    }
    
    private func setupNavigationBar() {
        self.title = currentURL.lastPathComponent
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage)),
                                              UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(addDirectory))]
        navigationController?.navigationBar.prefersLargeTitles = true
    }


//MARK: Actions for buttons
    
    @objc func addDirectory() {
        self.present(alertAddDirectory, animated: true)
    }
    
    @objc func addImage() {
        self.present(imagePicker, animated: true)
    }
}


extension DirectoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fileManagerService.contentsOfDirectory(at: currentURL).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        var config = cell.defaultContentConfiguration()
        
        if !UserDefaults.standard.bool(forKey: "notAlphabeticalOrder") {
            let sortedURLs = fileManagerService.contentsOfDirectory(at: currentURL).sorted { a, b in
                return a.lastPathComponent
                    .localizedStandardCompare(b.lastPathComponent)
                        == ComparisonResult.orderedAscending
            }
            config.text = sortedURLs[indexPath.row].lastPathComponent
            accessoryForRow(URLs: sortedURLs)
        } else {
            config.text = fileManagerService.contentsOfDirectory(at: currentURL)[indexPath.row].lastPathComponent
            accessoryForRow(URLs: fileManagerService.contentsOfDirectory(at: currentURL))
        }
        
        func accessoryForRow(URLs: [URL]) {
            if URLs[indexPath.row].hasDirectoryPath {
                cell.accessoryType = .disclosureIndicator
            } else {
                if !UserDefaults.standard.bool(forKey: "noSizeForPhoto") {
                    config.text! += " (\(fileManagerService.contentsOfDirectory(at: currentURL)[indexPath.row].fileSizeString))"
                }
            }
        }
        
        cell.contentConfiguration = config
        return cell
    }

}


extension DirectoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fileManagerService.contentsOfDirectory(at: currentURL)[indexPath.row].hasDirectoryPath {
            let nextDirectoryVC = DirectoryViewController(currentURL: fileManagerService.contentsOfDirectory(at: currentURL)[indexPath.row])
            self.navigationController?.pushViewController(nextDirectoryVC, animated: true)
        }
    }
    
}


extension DirectoryViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else {
            return
        }
        guard let name = (info[.imageURL] as? URL)?.lastPathComponent else {
            return
        }
        fileManagerService.createFileJPEG(from: img, withName: name, at: currentURL)
        self.tableView.reloadData()
        self.imagePicker.dismiss(animated: true)
    }
    
}

extension DirectoryViewController: UINavigationControllerDelegate {
 
}
