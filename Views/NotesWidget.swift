//
//  NotesWidget.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/15/26.
//

import SwiftUI

struct NotesWidget: View{
    let store: NotesStore
    @State private var draft = ""
    @FocusState private var isTyping: Bool
    
    var body: some View{
        VStack(alignment: .leading, spacing: 8){
            TextField("Write something down!", text: $draft)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .focused($isTyping)
                .onSubmit{
                    store.add(draft)
                    draft = ""
                    isTyping = true
                }
            if (store.items).isEmpty{
                Text("Nothing to show!").font(.system(size:13)).foregroundStyle(.white.opacity(0.55))
            } else {
                ForEach(store.items) { item in
                    Text(item.text)
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            }
            Spacer(minLength:0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
}
