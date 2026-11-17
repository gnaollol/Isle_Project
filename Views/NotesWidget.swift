//
//  NotesWidget.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/15/26.
//

import SwiftUI

struct NotesWidget: View {
    let store: NotesStore
    let state: IslandState

    @State private var draft = ""
    @State private var editingID: UUID?
    @State private var editDraft = ""
    @FocusState private var isTyping: Bool
    @FocusState private var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Write something down!", text: $draft)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .focused($isTyping)
                .onSubmit {
                    store.add(draft)
                    draft = ""
                    isTyping = true
                }

            if store.items.isEmpty {
                Text("Nothing to show!")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(store.sortedItems) { item in
                            row(item)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 4)
        .onChange(of: state.isExpanded) { _, isOpen in
            if !isOpen {
                isTyping = false
            }
        }
        .onChange(of: state.page) { _, newPage in
            if newPage != .notepad {
                isTyping = false
            }
        }
    }

    private func row(_ item: ChecklistItem) -> some View {
        HStack(spacing: 8) {
            Button {
                withAnimation{
                    store.toggle(item)
                }
            } label: {
                Image(systemName: item.isDone ? "checkmark" : "circle")
            }
            .buttonStyle(.plain)
            
            if(editingID == item.id){
                TextField("", text: $editDraft)
                    .textFieldStyle(.plain)
                    .focused($isEditing)
                    .onAppear { isEditing = true }
                    .onSubmit{
                        store.rename(item, to: editDraft)
                        editingID = nil
                    }
            } else {
                Text(item.text)
                    .strikethrough(item.isDone, pattern: .dash, color: .white)
                    .foregroundStyle(.white.opacity(item.isDone ? 0.5 : 1))
                    .lineLimit(1)
                    .onTapGesture(count: 2){
                        editDraft = item.text
                        editingID = item.id
                    }
            }

            Spacer(minLength: 0)

            Button {
                withAnimation{
                    store.delete(item)
                }
            } label: {
                Image(systemName: "bin.xmark")
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 13))
        .foregroundStyle(.white)
    }
}
