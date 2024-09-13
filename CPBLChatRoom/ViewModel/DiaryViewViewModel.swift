//
//  DiaryViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/9/6.
//

import Foundation
import CoreData
import SwiftUI
import PhotosUI

class DiaryViewViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var isShowAddView: Bool = false
    @Published var isCalendarExpanded: Bool = true
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedImages: [ImageWithID] = []
    @Published var selectedItems: [PhotosPickerItem] = []
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func toggleCalendarExpanding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isCalendarExpanded.toggle()
        }
    }
    
    func showAddView() {
        isShowAddView = true
    }
    
    func fetchRequestForEntries(for date: Date) -> NSPredicate {
        let startOfDate = Calendar.current.startOfDay(for: date)
        let endOfDate = Calendar.current.date(byAdding: .day, value: 1, to: startOfDate)!
        return NSPredicate(format: "date >= %@ && date < %@", startOfDate as NSDate, endOfDate as NSDate)
    }
    
    func delete(entry: DiaryEntry){
        context.delete(entry)
        do {
            try context.save()
        }catch{
            print("save error\(error)")
        }
    }
    
    func save(image: [ImageWithID], selectedDate: Date) {
        let entry: DiaryEntry = DiaryEntry(context: context)
        entry.id = UUID()
        entry.title = title
        entry.content = content
        entry.createdDate = Date()
        
        let calendar = Calendar.current
        let timeComponent = calendar.dateComponents([.hour, .minute, .second], from: Date())
        var dateComponent = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        dateComponent.hour = timeComponent.hour
        dateComponent.minute = timeComponent.minute
        dateComponent.second = timeComponent.second
        
        if let combinedDate = calendar.date(from: dateComponent) {
            entry.date = combinedDate
        } else {
            entry.date = selectedDate // 如果合併失敗，使用原始日期
        }

        let imageData = selectedImages.compactMap { ImageData(id: $0.id, data: $0.image.jpegData(compressionQuality: 0.8) ?? Data())}
        entry.image = try? JSONEncoder().encode(imageData)

        
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }

    }
    
    func loadNewImages() async {
        let loadedImages = await withTaskGroup(of: (Int, ImageWithID?).self) { group in
            for (index, item) in selectedItems.enumerated() {
                group.addTask {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        let imageWithId = ImageWithID(id: item.itemIdentifier ?? UUID().uuidString, image: uiImage)
                        return (index, imageWithId)
                    }
                    return (index, nil)
                }
            }
            
            var loadedImages: [(Int, ImageWithID?)] = []
            for await result in group {
                loadedImages.append(result)
            }
            return loadedImages.sorted(by: { $0.0 < $1.0 })
        }
        
        let newImages = loadedImages.compactMap { $0.1 }
        let failedIndices = loadedImages.enumerated().filter { $0.element.1 == nil }.map { $0.offset } //篩出圖片是nil的index
        
        await MainActor.run {
            self.selectedImages = newImages
            // 從後往前移除失敗的項目，以避免index變化的問題
            for index in failedIndices.reversed() {
                self.selectedItems.remove(at: index)
            }
        }
    }
    
    
    
    func removeImage(withId id: String) {
        selectedImages.removeAll { $0.id == id }
        selectedItems.removeAll { $0.itemIdentifier == id }
    }
    
    
}
