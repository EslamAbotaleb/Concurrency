//
//  ImageDownloadOperation.swift
//  ConcurrencyApp
//
//  Created by Eslam on 12/10/2025.
//

import UIKit

class ImageDownloadOperation: Operation, @unchecked Sendable {
    private let url: URL
    private var task: URLSessionDataTask?
    
    // 👇 Add this property to store the downloaded image
    private(set) var image: UIImage?
    
    init(url: URL) {
        self.url = url
    }
    
    override func main() {
        if isCancelled { return }
        
        print("📥 Download started from \(url)")
        let semaphore = DispatchSemaphore(value: 0)
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            defer { semaphore.signal() }
            
            if let error = error {
                print("❌ Download failed: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                self.image = downloadedImage
                print("✅ Download completed (\(data.count) bytes)")
            }
        }
        
        task?.resume()
        semaphore.wait()
        
        if isCancelled {
            print("🛑 Download cancelled")
        }
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
