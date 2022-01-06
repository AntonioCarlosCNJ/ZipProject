//
//  ProgressBar.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 04/01/22.
//

import SwiftUI
import Combine

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(NSColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(NSColor.systemBlue))
            }.cornerRadius(45.0)
        }
    }
}
