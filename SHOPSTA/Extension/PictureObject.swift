//
//  PictureObject.swift
//  SHOPSTA
//
//  Created by admin on 05/12/2017.
//  Copyright © 2017 test. All rights reserved.
//

import Foundation
import ObjectMapper


class pictureObject: Mappable {
    
    var UserName: String?
    var ImageURL: String?
    var senderUID:String?
    var timeStamp:String?
    var id:String?
    static var pictureDetail = [pictureObject]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        UserName        <- map["UserName"]
        ImageURL        <- map["ImageURL"]
        senderUID        <- map["senderUID"]
        timeStamp        <- map["timeStamp"]
    }
}
