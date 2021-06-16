//
//  ImagePicker.swift
//  BeSimple
//
//  Created by 김종원 on 2021/06/16.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewController = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    let sourceType: SourceType
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}
