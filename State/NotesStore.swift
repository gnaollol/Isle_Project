//
//  NotesStore.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/15/26.
//

import Foundation
import Observation

struct ChecklistItem: Identifiable{
    var id = UUID()
    var text: String
    var isDone = false
}

@Observable
final class NotesStore{
    private(set) var items: [ChecklistItem] = [
    ]
    
    func add(_ text: String){
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(ChecklistItem(text: trimmed))
    }
    
    func toggle(_ item: ChecklistItem){
        guard let index = items.firstIndex(where: { $0.id == item.id}) else {return}
        items[index].isDone.toggle()
        
    }
    
    func delete(_ item: ChecklistItem){
        items.removeAll(where: {$0.id == item.id})
    }
}
