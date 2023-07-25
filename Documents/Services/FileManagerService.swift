

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    
    func contentsOfDirectory(at: URL) -> [URL]
    
    func createDirectory(withName: String, at: URL)
    
    func createFileJPEG(from image: UIImage, withName: String, at url: URL)
    
    func removeContent(at url: URL)
     
}



final class FileManagerService: FileManagerServiceProtocol {
 
    func contentsOfDirectory(at url: URL) -> [URL] {
        do {
            return (try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil))
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func createDirectory(withName: String, at url: URL) {
        let nameToURLEncoded = withName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        do {
            try FileManager.default.createDirectory(at: URL(string: "\(url)\(nameToURLEncoded!)")!, withIntermediateDirectories: false)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func createFileJPEG(from image: UIImage, withName: String, at url: URL) {
        if let jpegData = image.jpegData(compressionQuality: 0.5) {
            let path = url.appendingPathComponent(withName)
            do {
                try jpegData.write(to: path)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func removeContent(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    
    
    
    
}
