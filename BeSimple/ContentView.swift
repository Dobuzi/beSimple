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
    @State private var selectedImage: UIImage?
    @State private var sourceType: ImagePicker.SourceType = .photoLibrary
    
    @State private var loadedImages: [DownloadedImage] = []
    
    @State private var isPulledDown: Bool = false
    @State private var startRefresh: Bool = false
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 100), spacing: 20, alignment: .center)]
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        if startRefresh {
                            getPhotos()
                            isPulledDown = false
                            startRefresh = false
                        } else if proxy.frame(in: .global).minY > 100 {
                            isPulledDown = true
                        } else if isPulledDown && proxy.frame(in: .global).minY < 50 {
                            startRefresh = true
                        }
                    }
                    return AnyView(Color.black.frame(width:0, height: 0))
                }
                VStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .offset(y: -80)
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(loadedImages.sorted(by: {$0.url > $1.url })) { image in
                            Image(uiImage: image.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 200, alignment: .center)
                                .cornerRadius(5)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                                .onLongPressGesture {
                                    deletePhoto(image: image)
                                }
                        }
                    }
                }
                .padding()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { self.showSourceSelector = true }, label: {
                        Image(systemName: "plus")
                    })
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color.orange)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    .clipShape(Circle())
                    .foregroundColor(.white)
                    .font(.headline)
                    .shadow(radius: 5)
                }
            }
            .padding()
            
        }
        .onAppear(perform: getPhotos)
        .actionSheet(isPresented: $showSourceSelector) {
            ActionSheet(title: Text("사진을 어디서 가져올까요?"), message: nil, buttons: [
                .default(Text("사진첩"), action: choosePhoto),
                .default(Text("카메라 촬영"), action: takePhoto),
                .cancel()
                
            ])
        }
        .sheet(isPresented: $showImagePicker, onDismiss: addPhoto, content: {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
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
        guard let image = self.selectedImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let name: String = String(Date().timeIntervalSince1970) + UUID().uuidString
        print(name)
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let folderRef = storageRef.child("photos")
        let photoRef = folderRef.child("\(name).jpg")
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
                guard let url = url else {
                    print("No download url")
                    return
                }
                print(url)
                getPhotos()
            }
            
        }
        print(uploadTask.description)
    }

    func getPhotos() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let folderRef = storageRef.child("photos")
        let fileManager = FileManager.default
        let cachedFolder: String = "Cached/Images"
        let documentURL: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(cachedFolder)
        var fileName: String = ""
        var fileURL: URL?
        var savedData: Data?
        var status = ""
        loadedImages = []
        
        DispatchQueue.main.async {
            folderRef.listAll() { (photos, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                for photo in photos.items {
                    fileName = photo.description.components(separatedBy: "/").last ?? ""
                    fileURL = documentURL.appendingPathComponent(fileName)
                    guard let fileURL = fileURL else { return }
                    if fileManager.fileExists(atPath: fileURL.path) {
                        do {
                            savedData = try Data(contentsOf: fileURL)
                            guard let data = savedData else { return }
                            guard let image = UIImage(data: data) else { return }
                            loadedImages.append(DownloadedImage(url: photo.description, loacalURL: fileURL, image: image))
                            status = "Success"
                        } catch {
                            print(error.localizedDescription)
                            status = "Fail"
                        }
                        print("\(Date().description) request: GET photo, url: \(fileURL.path), status: \(status)")
                    } else {
                        photo.write(toFile: fileURL) { (url, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            guard let url = url else { return }
                            do {
                                savedData = try Data(contentsOf: url)
                                guard let data = savedData else { return }
                                guard let image = UIImage(data: data) else { return }
                                loadedImages.append(DownloadedImage(url: photo.description, loacalURL: url, image: image))
                                status = "Success"
                            } catch {
                                print(error.localizedDescription)
                                status = "Fail"
                            }
                            print("\(Date().description) request: GET photo, url: \(url.path), status: \(status)")
                        }
                    }
                }
            }
        }
        do {
            try print(fileManager.contentsOfDirectory(atPath: documentURL.path))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deletePhoto(image: DownloadedImage) {
        let storage = Storage.storage()
        let photoRef = storage.reference(forURL: image.url)
        var status = ""
        photoRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("\(image.url) is deleted.")
            }
        }
        do {
            try FileManager.default.removeItem(at: image.loacalURL)
            status = "Success"
        } catch {
            print(error.localizedDescription)
            status = "Fail"
        }
        print("\(Date().description) request: DELETE photo, url: \(image.loacalURL.path), status: \(status)")
        getPhotos()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
