//
//  UnzipProjectErrorProtocol.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 06/01/22.
//

import Foundation

protocol UnzipProjectError: Error {
    var errorMessage: String {get}
}
