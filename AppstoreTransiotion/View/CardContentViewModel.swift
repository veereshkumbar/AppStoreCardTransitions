//
//  CardContentViewModel.swift
//  AppstoreTransiotion
//
//  Created by GLB-254 on 9/3/19.
//  Copyright © 2019 GLB-254. All rights reserved.
//

import Foundation
import UIKit

struct CardContentViewModel{
    let primary:String
    let secondary:String
    let description:String
    let image:UIImage
    
    func highlightedImage() -> CardContentViewModel{
        let scaledImage = image.resize(toWidth: image.size.width * GlobalConstants.cardHighlightedFactor)
        return CardContentViewModel(primary: primary, secondary: secondary, description: description, image: scaledImage)
    }
    
}
