//
//  CustomError.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 06/01/22.
//

import Foundation
import Zip

enum CustomError: UnzipProjectError {
    case genericError
    case urlNotFoundError
    
    var errorMessage: String {
        switch self {
        case .genericError:
            return "Something goes wrong... Please try again"
        case .urlNotFoundError:
            return "File URL not found, try again..."
        }
    }
}

extension ZipError: UnzipProjectError {
    var errorMessage: String {
        self.description
    }
}
