//
//  Image.swift
//  BeSimple
//
//  Created by 김종원 on 2021/06/16.
//

import Foundation
import SwiftUI

struct DownloadedImage: Identifiable {
    let id = UUID()
    let url: String
    let loacalURL: URL
    let image: UIImage
}
