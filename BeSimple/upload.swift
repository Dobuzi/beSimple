//
//  upload.swift
//  BeSimple
//
//  Created by 김종원 on 2021/06/15.
//

import Foundation
import Firebase
import SwiftUI

func addOnFirestore(collection: String = "users", data: [String: Any] = [
    "first": "Jong Won",
    "last": "Kim",
    "born": 1990
]) -> Void {
    let db: Firestore! = Firestore.firestore()

    var ref: DocumentReference? = nil
    ref = db.collection(collection).addDocument(data: data) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }

}

func getFromFirestore(collection: String = "users") {
    let db: Firestore! = Firestore.firestore()
    
    db.collection(collection).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
            }
        }
    }
}

