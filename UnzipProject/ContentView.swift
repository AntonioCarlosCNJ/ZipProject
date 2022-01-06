//
//  ContentView.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 02/01/22.
//

import SwiftUI
import Zip

struct ContentView: View {
    var body: some View {
        ZipView(viewModel: ZipViewModel(zipFormatExtension: .gzip, zipOperation: .zip))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
