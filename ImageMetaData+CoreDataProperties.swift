//
//  ImageMetaData+CoreDataProperties.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//
//

import Foundation
import CoreData


extension ImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageMetaData> {
        return NSFetchRequest<ImageMetaData>(entityName: "ImageMetaData")
    }

    @NSManaged public var filename: String?
    @NSManaged public var isRecycled: Bool

}

extension ImageMetaData : Identifiable {

}
