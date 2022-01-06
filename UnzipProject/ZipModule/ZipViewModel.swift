//
//  ZipViewModel.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 04/01/22.
//

import Zip
import Combine

enum Result {    
    case success
    case failure(Error)
}

class ZipViewModel: ObservableObject {
    //MARK: - Properties
    @Published var fileCompressingProgress: Float = 0.0
    @Published private(set) var isOperating: Bool = false
    @Published var zipFormatExtension: ZipFormatExtensions
    @Published var zipOperation: ZipOperation
    @Published var showErrorAlert: Bool = false
    @Published var result: Result? = nil
    var errorMessage: String = ""
    
    //MARK: - Initializers
    init(zipFormatExtension: ZipFormatExtensions, zipOperation: ZipOperation) {
        self.zipFormatExtension = zipFormatExtension
        self.zipOperation = zipOperation
        
        ZipFormatExtensions.allCases.forEach({Zip.addCustomFileExtension($0.rawValue)})
    }
    
    //MARK: - Business Logic
    
    /// Convert NSItemProvider in URL
    /// - Parameters:
    ///   - items: Files dropped in the dropable area
    ///   - completion: Completion that can return URL or some Error
    private func convertNSItemProviderInUrl(items: [NSItemProvider], completion: @escaping (URL?, Error?) -> ()) {
        if let item = items.first,
           let identifier = item.registeredTypeIdentifiers.first,
           identifier == "public.url" || identifier == "public.file-url" {
            item.loadItem(forTypeIdentifier: identifier, options: nil) { urlData, error in
                if let urlData = urlData as? Data {
                    completion((NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL), nil)
                    return
                }
                completion(nil, error)
            }
        }
    }

    /// Make the operation of zip or unzip
    /// - Parameter items: NSItemProvider, when user drop a file.
    func makeOperation(with items: [NSItemProvider]) {
        convertNSItemProviderInUrl(items: items) {[weak self] url, error in
            guard let self = self else {return}
            self.makeOperation(with: url)
        }
    }
    
    /// Make the operation of zip or unzip
    /// - Parameter url: URL
    func makeOperation(with url: URL?) {
        switch self.zipOperation {
        case .zip:
            self.zipFile(url: url) { result in
                self.handleResultOperation(result: result)
            }
        case .unzip:
            self.unzipFile(url: url) { result in
                self.handleResultOperation(result: result)
            }
        }
    }
    
    /// This Function is to zip file and save in the same path
    /// - Parameters:
    ///   - url: URL of file
    ///   - completion: Completion that return if it's success or not
    private func zipFile(url: URL?, completion: @escaping (Result) -> ()) {
        guard let url = url else {completion(.failure(CustomError.urlNotFoundError)); return}
        DispatchQueue(label: "com.app.queue").async { [weak self] in
            guard let self = self else {completion(.failure(CustomError.genericError)); return}
            let filePath = url.appendingPathExtension(self.zipFormatExtension.rawValue)
            do {
                DispatchQueue.main.async {
                    self.isOperating = true
                }
                try Zip.zipFiles(paths: [url], zipFilePath: filePath, password: nil, progress: {[weak self] progress in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        self.fileCompressingProgress = Float(progress)
                        
                        if (self.fileCompressingProgress == 1.0) {
                            self.isOperating = false
                            self.fileCompressingProgress = 0.0
                            completion(.success)
                        }
                    }
                })
            } catch {
                DispatchQueue.main.async {
                    self.isOperating = false
                }
                completion(.failure(error))
            }
        }
    }
    
    /// This Function is to unzip file and save in the same path
    /// - Parameters:
    ///   - url: URL of file
    ///   - completion: Completion that return if it's success or not
    private func unzipFile(url: URL?, completion: @escaping (Result) -> ()) {
        guard let url = url else { completion(.failure(CustomError.urlNotFoundError)); return}
        
        DispatchQueue(label: "com.app.queue").async {[weak self] in
            guard let self = self else {completion(.failure(CustomError.genericError)); return}
            let filePath = url.deletingLastPathComponent()
                
            do {
                DispatchQueue.main.async {
                    self.isOperating = true
                }
                try Zip.unzipFile(url, destination: filePath, overwrite: true, password: nil, progress: {[weak self] progress in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        self.fileCompressingProgress = Float(progress)
                        
                        if (self.fileCompressingProgress == 1.0) {
                            self.isOperating = false
                            self.fileCompressingProgress = 0.0
                        }
                    }
                })
                completion(.success)
            } catch {
                DispatchQueue.main.async {
                    self.isOperating = false
                }
                completion(.failure(error))
            }
        }
    }
    
    /// This function is handle result when returns from operation
    /// - Parameter result: Result
    private func handleResultOperation(result: Result) {
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.result = result
            }
        case .failure(let error):
            self.handleError(error: error)
        }
    }
    
    /// This function is to handle error in this ViewModel
    /// - Parameter error: Error
    private func handleError(error: Error) {
        DispatchQueue.main.async {
            if let error = error as? UnzipProjectError {
                self.errorMessage = error.errorMessage
            } else {
                self.errorMessage = error.localizedDescription
            }
            self.showErrorAlert = true
        }
    }
}

