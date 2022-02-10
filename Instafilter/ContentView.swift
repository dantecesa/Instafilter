//
//  ContentView.swift
//  Instafilter
//
//  Created by Dante Cesa on 2/8/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var incomingImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var showingAddPhotosSheet: Bool = false
    @State private var showingFilterSheet: Bool = false
    
    @State private var filterIntensity: Double = 0.0
    @State private var filterRadius: Double = 3.0
    @State private var filterScale: Double = 5.0
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showSaveError: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if image == nil {
                        Rectangle()
                            .fill(.thinMaterial)
                    } else {
                        Rectangle()
                            .fill(.black)
                    }
                    
                    image?
                        .resizable()
                        .scaledToFit()
                    
                    if image == nil {
                        Text("Tap to select a photo")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
                .onTapGesture {
                    showingAddPhotosSheet = true
                }
                
                VStack {
                    if currentFilter.inputKeys.contains(kCIInputIntensityKey) {
                        HStack {
                            Text("Intensity")
                            Slider(value: $filterIntensity , in: 0...1)
                                .padding(.vertical)
                        }.onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                    }
                    
                    if currentFilter.inputKeys.contains(kCIInputRadiusKey) {
                        HStack {
                            Text("Radius")
                            Slider(value: $filterRadius, in: 0...200)
                                .padding(.vertical)
                        }.onChange(of: filterRadius) { _ in
                            applyProcessing()
                        }
                    }
                    
                    if currentFilter.inputKeys.contains(kCIInputScaleKey) {
                        HStack {
                            Text("Scale")
                            Slider(value: $filterScale, in: 0...10)
                                .padding(.vertical)
                        }.onChange(of: filterScale) { _ in
                            applyProcessing()
                        }
                    }
                    
                    HStack {
                        Button("Change Filter") { showingFilterSheet = true }
                        Spacer()
                        Button(action: { saveImage() },
                               label: { Text("Save") })
                    }
                    .disabled(image == nil)
                }
                .padding([.horizontal, .bottom])
            }
            .onChange(of: incomingImage) { _ in loadImage() }
            .navigationTitle("InstaFilter")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingAddPhotosSheet) { ImagePicker(image: $incomingImage) }
            .confirmationDialog("Choose a Filter", isPresented: $showingFilterSheet) {
                Group {
                    Button("Crystalize") { currentFilter = CIFilter.crystallize(); loadImage() }
                    Button("Edges") { currentFilter = CIFilter.edges(); loadImage() }
                    Button("Gaussian Blur") { currentFilter = CIFilter.gaussianBlur(); loadImage() }
                    Button("Pixellate") { currentFilter = CIFilter.pixellate(); loadImage() }
                    Button("Sepia Tone") { currentFilter = CIFilter.sepiaTone(); loadImage() }
                    Button("Unsharp Mask") { currentFilter = CIFilter.unsharpMask(); loadImage() }
                    Button("Vignette") { currentFilter = CIFilter.vignette(); loadImage() }
                    Button("Pointillize") { currentFilter = CIFilter.pointillize(); loadImage() }
                    Button("Bloom") { currentFilter = CIFilter.bloom(); loadImage() }
                    Button("Noir") { currentFilter = CIFilter.photoEffectNoir(); loadImage() }
                }
                Group {
                    Button("Cancel", role: .cancel) { }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if image != nil { Button(action: { showingAddPhotosSheet = true }, label: { Text("New Image") }) }
                }
            }
            .alert("Oops!", isPresented: $showSaveError) {
                Button("OK") { }
            } message: {
                Text("Sorry, there was an error saving your image – please check that you have allowed permission for this app to save photos.")
            }
        }
    }
    
    func loadImage() {
        guard let incomingImage = incomingImage else { return }
        
        let beginImage = CIImage(image: incomingImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func saveImage() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Image saved successfully")
        }
        
        imageSaver.errorHandler = {
            print("Something went wrong saving the image: \($0.localizedDescription)")
            showSaveError = true
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
