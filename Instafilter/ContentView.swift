//
//  ContentView.swift
//  Instafilter
//
//  Created by Dante Cesa on 2/8/22.
//

import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker: Bool = false
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
            
            Button("Select Image…") {
                showingImagePicker = true
            }
            
            Button("Save Image") {
                guard let inputImage = inputImage else { return }
                
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: inputImage)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in
            guard let inputImage = inputImage else { return }
            image = Image(uiImage: inputImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
