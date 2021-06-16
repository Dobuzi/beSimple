//
//  ContentView.swift
//  BeSimple
//
//  Created by 김종원 on 2021/06/14.
//

import SwiftUI
import FirebaseStorage

struct ContentView: View {
    @State private var showSourceSelector: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var image: UIImage?
    @State private var sourceType: ImagePicker.SourceType = .photoLibrary
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 100), spacing: 20, alignment: .center)]
    
    var body: some View {
        VStack {
            Button(action: { self.showSourceSelector = true }, label: {
                Text("Add")
            })
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(1...47, id: \.self) { image in
                        Image(String(image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 200, alignment: .center)
                            .cornerRadius(5)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
        .actionSheet(isPresented: $showSourceSelector) {
            ActionSheet(title: Text("Select the source of photo"), message: nil, buttons: [
                .default(Text("choose from photo library"), action: choosePhoto),
                .default(Text("take a photo by camera"), action: takePhoto),
                .cancel()
                
            ])
        }
        .sheet(isPresented: $showImagePicker, onDismiss: addPhoto, content: {
            ImagePicker(image: $image, sourceType: sourceType)
        })
    }
    
    func choosePhoto() {
        sourceType = .photoLibrary
        showImagePicker = true
    }
    
    func takePhoto() {
        sourceType = .camera
        showImagePicker = true
    }
    
    func addPhoto() {
        guard let image = self.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        let name: String = UUID().uuidString
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoRef = storageRef.child("photos/\(name).jpg")
        let uploadTask = photoRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            photoRef.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard url != nil else {
                    print("No download url")
                    return
                }
            }
        }
        print(uploadTask.description)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
