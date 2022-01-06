//
//  ZipView.swift
//  UnzipProject
//
//  Created by Antonio Carlos on 04/01/22.
//

import SwiftUI
import Combine

struct ZipView: View {
    //MARK: - Properties
    @StateObject var viewModel: ZipViewModel
    
    //MARK: - Initializers
    init(viewModel: ZipViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            createDroppableArea()
            createButtonToMakeZipOperation()
            HStack(alignment: .top) {
                createPickerZipOperation()
                    .frame(width: 200)
                if (viewModel.zipOperation == .zip) {
                    createPickerZipFormat()
                        .frame(width: 200)
                }
            }
            if viewModel.isOperating {
                VStack{
                    ProgressBar(value: $viewModel.fileCompressingProgress).frame(width: 250, height: 15)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                }
            }
            if let operationResult = viewModel.result {
                if case Result.success = operationResult {
                    SuccessAnimationView(delegate: self)
                        .frame(width: 50, height: 50)
                        .transition(.opacity)
                }
            }
        }
        .frame(width: 500, height: 500)
        .alert(viewModel.errorMessage, isPresented: $viewModel.showErrorAlert) {
                Button("Dismiss") {
                    viewModel.showErrorAlert = false
                    viewModel.result = nil
                }
        }
    }
    
    func showPanel() -> URL? {
        let panel = NSOpenPanel()
        panel.prompt = "Select File or Group"
        panel.worksWhenModal = true
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.resolvesAliases = true
        
        let response = panel.runModal()
        return response == .OK ? panel.url : nil
    }
    
    func createButtonToMakeZipOperation() -> some View {
        Button(viewModel.zipOperation == .zip ? "Compress File Here..." : "Unzip File Here...") {
            let url = showPanel()
            viewModel.makeOperation(with: url)
        }.disabled(viewModel.isOperating)
    }
    
    func createPickerZipOperation() -> some View {
        VStack {
            Text("Select Zip Operation: ")
            Picker("", selection: $viewModel.zipOperation.animation()) {
                ForEach(ZipOperation.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.isOperating)
        }
    }
    
    func createPickerZipFormat() -> some View {
        VStack {
            Text("Select compression format: ")
            Picker("", selection: $viewModel.zipFormatExtension) {
                ForEach(ZipFormatExtensions.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.menu)
            .disabled(viewModel.isOperating)
        }.transition(.opacity)
    }
    
    func createDroppableArea() -> some View {
        VStack {
            Text(viewModel.zipOperation.rawValue)
                .font(.title)
            Text("Drop Here...")
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.gray)
                        .frame(width: 200, height: 200, alignment: .center)
                )
                .frame(width: 200, height: 200, alignment: .center)
                .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { items in
                    if viewModel.isOperating {return false}
                    
                    viewModel.makeOperation(with: items)
                    return true
                }
        }
    }
}

extension ZipView: LottieViewDelegate {
    func animationEnded() {
        viewModel.result = nil
    }
}
