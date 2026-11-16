//
//  NotesWidget.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/15/26.
//

import SwiftUI

struct NotesWidget: View{
    let store: NotesStore
    
    var body: some View{
        VStack(alignment: .leading, spacing: 8){
            ForEach(store.items) { item in
                Text(item.text)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            Spacer(minLength:0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
}
