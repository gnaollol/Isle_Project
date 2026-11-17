//
//  NotesStore.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/15/26.
//

import Foundation
import Observation

struct ChecklistItem: Identifiable, Codable{
    var id = UUID()
    var text: String
    var isDone = false
}

@Observable
final class NotesStore{
    
    private(set) var items: [ChecklistItem] = []
    
    private let fileURL: URL = {
        let folder = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("isle", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("notes.json")
    }()
    init(){
        load()
    }
    
    
    private func save(){
        guard let data = try? JSONEncoder().encode(items) else {return}
        try? data.write(to: fileURL, options: .atomic)
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: fileURL), let saved = try? JSONDecoder().decode([ChecklistItem].self, from: data)
        else { return }
        items = saved
    }
    
    func add(_ text: String){
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(ChecklistItem(text: trimmed))
        save()
    }
    
    func toggle(_ item: ChecklistItem){
        guard let index = items.firstIndex(where: { $0.id == item.id}) else {return}
        items[index].isDone.toggle()
        save()
    }
    
    func delete(_ item: ChecklistItem){
        items.removeAll(where: {$0.id == item.id})
        save()
    }
    
    
}
