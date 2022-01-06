//
//  SuccessAnimationView.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 06/01/22.
//

import SwiftUI

struct SuccessAnimationView: View {
    var delegate: LottieViewDelegate?
    
    var body: some View {
        LottieView(filename: "success", delegate: delegate)
    }
}

struct SuccessAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessAnimationView()
    }
}
