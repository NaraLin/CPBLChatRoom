
//  DiaryView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/9/2.
//

import SwiftUI
import CoreData
import PhotosUI

enum addField {
    case title, content
}

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: DiaryViewViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: DiaryViewViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarExpandingButton
                
                VStack(spacing: 0) {
                    if viewModel.isCalendarExpanded {
                        calendarView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    GeometryReader { geometry in
                        ZStack {
                            Color.main
                            DiaryForDateView(date: viewModel.selectedDate, context: context)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .clipped()
            }
            .navigationTitle("Diary")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isShowAddView) {
                DiaryAddView(context: context, date: $viewModel.selectedDate)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddView()
                    } label: {
                        Image(systemName: "plus.app")
                    }
                }
            }
        }
    }
    
}


private struct DiaryAddView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @Binding var date: Date
    @FocusState private var field: addField?
    @State private var selectedItem: [PhotosPickerItem] = []
    @ObservedObject var viewModel: DiaryViewViewModel
    
    init(context: NSManagedObjectContext, date: Binding<Date>){
        let viewModel = DiaryViewViewModel(context: context)
        self.viewModel = viewModel
        _date = date
    }
    
    var body: some View {
        VStack {
            titleField
            
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
            
            contentEditor
            
            PhotosPicker(selection: $viewModel.selectedItems, maxSelectionCount: 10, matching: .images) {
                Label("添加照片", systemImage: "photo")
            }
            
            imageScrollView
            
            Button(action: {
                viewModel.save(image: viewModel.selectedImages, selectedDate: date)
                dismiss()
            }, label: {
                Text("儲存")
            })
            .buttonStyle(BorderedButtonStyle())
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .onChange(of: viewModel.selectedItems) {_, newValue in
            Task {
                await viewModel.loadNewImages()
            }
        }
    }
}


private struct DiaryForDateView: View {
    @FetchRequest private var entries: FetchedResults<DiaryEntry>
    @State private var showingEditView: Bool = false
    @State private var selectedEntry: DiaryEntry?
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var viewModel: DiaryViewViewModel

    init(date: Date, context: NSManagedObjectContext){
        let viewModel = DiaryViewViewModel(context: context)
        self.viewModel = viewModel
        let request: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DiaryEntry.date, ascending: true)]
        request.predicate = viewModel.fetchRequestForEntries(for: date)
        _entries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        Group {
            if entries.isEmpty {
                HStack {
                    Text("這一天沒有日記")
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                List {
                    Section(header: Text("diary").foregroundStyle(Color.white)) {
                            ForEach(entries) { entry in
                                    VStack(alignment: .leading) {
                                        
                                        Text(entry.title ?? "")
                                            .font(.headline)
                                        Text(entry.content ?? "")
                                            .font(.body)
                                        
                                        if let imageData = entry.image,
                                           let images = try? JSONDecoder().decode([ImageData].self, from: imageData) {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    ForEach(images.prefix(5)) { imageData in
                                                        if let uiImage = UIImage(data: imageData.data) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 60, height: 60)
                                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        }
                                                    }
                                                    if images.count > 5 {
                                                        Text("+\(images.count - 5)")
                                                            .frame(width: 60, height: 60)
                                                            .background(Color.gray.opacity(0.3))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    }
                                                }
                                            }
                                            .frame(height: 70)
                                        }
                                            Color.clear.frame(height: 4)
                                            
                                            Text(entry.createdDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray)
                                        
                                    }
                                    .lineLimit(5)
                                    .padding()
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(Color.white)
                                    .onTapGesture {
                                        showingEditView = true
                                        selectedEntry = entry
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                        Button(role: .destructive){
                                           viewModel.delete(entry: entry)
                                        } label: {
                                            Label(
                                                title: { Text("刪除") },
                                                icon: { Image(systemName: "trash.circle") }
                                            )
                                        }
                                        .tint(.red)
                                    })
                            }
                    }
                }
                .scrollContentBackground(.hidden)
                .sheet(item: $selectedEntry, content: { entry in
                    DiaryEditView(entry: entry, context: context)
                })
            }
            
        }
    }
    
    func delete(entry: DiaryEntry){
        context.delete(entry)
        do {
            try context.save()
        }catch{
            print("save error\(error)")
        }
    }
}



private struct DiaryEditView: View {
    
    @Environment(\.managedObjectContext) private var context
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedImages: [ImageWithID] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DiaryViewViewModel
    let entry: DiaryEntry
    
    
    init(entry: DiaryEntry, context: NSManagedObjectContext){
        self.entry = entry
        let viewModel = DiaryViewViewModel(context: context)
        viewModel.title = entry.title ?? ""
        viewModel.content = entry.content ?? ""

        if let imageData = entry.image,
           let decodeImageData = try? JSONDecoder().decode([ImageData].self, from: imageData) {
            viewModel.selectedImages = decodeImageData.compactMap { imageData in
                UIImage(data: imageData.data).map { ImageWithID(id: imageData.id, image: $0) }
            }
        }
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        
        VStack (content: {
            TextField("標題", text: $viewModel.title)
                .font(.largeTitle)
                .padding()
                .onChange(of: viewModel.title) { oldValue, newValue in
                    if newValue.count > 20 {
                        viewModel.title = String(newValue.prefix(20))
                    }
                }
            
            //分隔線
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
            
            GeometryReader(content: { geometry in
                ZStack(alignment: .topLeading, content: {
                    TextEditor(text: $viewModel.content)
                        .padding()
                        .scrollDismissesKeyboard(.interactively)
                    if viewModel.content.isEmpty {
                        Text("請輸入內容")
                        .padding()
                        .foregroundStyle(Color.gray)
                    }
                })
            })
            
            PhotosPicker(selection: $viewModel.selectedItems) {
                Label(viewModel.selectedImages.isEmpty ? "選擇照片" : "重選照片", systemImage: "photo")
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.selectedImages) { imageWithId in
                        Image(uiImage: imageWithId.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation(.easeInOut) {
//
                                        if let index = viewModel.selectedImages.firstIndex(where: { $0.id == imageWithId.id }) {
                                            viewModel.selectedImages.remove(at: index)
                                            if index < viewModel.selectedItems.count {
                                                viewModel.selectedItems.remove(at: index)
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundStyle(Color.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .padding(5)
                            }
                            .transition(.opacity)
                    }
                }
            }
            .frame(height: viewModel.selectedImages.isEmpty ? 0 : 250)
            
            
            HStack {
                Button(action: {
                    updateEntry()
                }, label: {
                    Text("儲存")
                })
                .buttonStyle(BorderedButtonStyle())
            }
            .frame(maxWidth: .infinity)
           
        })
        .onChange(of: viewModel.selectedItems) { _, _ in
            Task {
                await viewModel.loadNewImages()
            }
        }
    }
    
    private func updateEntry() {
        entry.title = viewModel.title
        entry.content = viewModel.content
        let imageData = viewModel.selectedImages.compactMap { ImageData(id: $0.id, data: $0.image.jpegData(compressionQuality: 0.8) ?? Data())}
        entry.image = try? JSONEncoder().encode(imageData)
        
        
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
        
        dismiss()
    }
}


//MARK: subviews
private extension DiaryView {
    var calendarExpandingButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.toggleCalendarExpanding()
            }
        }) {
            HStack {
                Text(viewModel.isCalendarExpanded ? "收起日曆" : "展開日曆")
                Image(systemName: viewModel.isCalendarExpanded ? "chevron.up" : "chevron.down")
            }
        }
        .padding()
    }
    
    var calendarView: some View {
        ZStack {
            Color.main
            List {
                Section(header: Text("日曆").foregroundStyle(Color.white)) {
                    DatePicker("選擇日期", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .scrollContentBackground(.hidden)
        }
        .frame(minHeight: 420)
    }
}

private extension DiaryAddView {
    var titleField: some View {
        TextField("標題", text: $viewModel.title)
            .padding(16)
            .font(.largeTitle)
            .submitLabel(.next)
            .focused($field, equals: .title)
            .onSubmit {
                field = .content
            }
            .onChange(of: viewModel.title) { oldValue, newValue in
                if newValue.count > 20 {
                    viewModel.title = String(newValue.prefix(20))
                }
            }
    }
    
    var contentEditor: some View {
        GeometryReader { _ in
            TextEditor(text: $viewModel.content)
                .padding(16)
                .frame(height: 200)
                .submitLabel(.continue)
                .focused($field, equals: .content)
            if viewModel.content.isEmpty {
                Text("請輸入內容")
                    .padding()
                    .foregroundStyle(Color.gray)
            }
        }
    }
    
    var imageScrollView: some View {
           ScrollView(.horizontal) {
               HStack {
                   ForEach(viewModel.selectedImages) { imageWithId in
                       ImageView(imageWithId: imageWithId) {
                           withAnimation {
                               if let index = viewModel.selectedImages.firstIndex(of: imageWithId) {
                                   viewModel.selectedImages.remove(at: index)
                                   viewModel.selectedItems.remove(at: index)
                               }
                               
                           }
                       }
                   }
               }
           }
           .frame(height: viewModel.selectedImages.isEmpty ? 0 : 250)
           .scrollIndicators(.visible)
       }
}

private struct ImageView: View {
        let imageWithId: ImageWithID
        let onDelete: () -> Void
        
        var body: some View {
            Image(uiImage: imageWithId.image)
                .resizable()
                .scaledToFill()
                .frame(width:200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .topTrailing) {
                    Button(action: onDelete) {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color.red)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(5)
                }
                .transition(.opacity)
        }
    }
    
    
//#Preview {
//    DiaryView()
//}

//struct DiaryView_Preview: PreviewProvider {
//    static var previews: some View {
//        DiaryView()
//    }
//}

