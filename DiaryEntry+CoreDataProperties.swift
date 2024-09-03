//
//  DiaryEntry+CoreDataProperties.swift
//  
//
//  Created by 林靖芳 on 2024/9/4.
//
//

import Foundation
import CoreData


extension DiaryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntry> {
        return NSFetchRequest<DiaryEntry>(entityName: "DiaryEntry")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var created: Date?
}
