//
//  AllCountersList.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

struct BarCountersList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Domain.position, ascending: false)
    ], animation: .default)
    private var domains: FetchedResults<Domain>

    var body: some View {
        List {
            ForEach(domains) { domain in
                Section(header: AllCountersHeader(domain)) {
                    ForEach(domain.allCounters.sorted().reversed()) { counter in
                        BarCounterView(counter)
                    }
                }
            }
        }
    }
}

struct AllCountersHeader: View {
    @ObservedObject var domain: Domain
    
    init(_ domain: Domain) {
        self.domain = domain
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(domain.namespace ?? "new.namespace")
                .font(domain.namespace != nil && domain.titleOrBlank.isEmpty ? .title.weight(.bold) : .subheadline)
                .foregroundColor(.accentColor)
            if let title = domain.title {
                Text(title)
                    .font(.title.weight(.bold))
            }
        }
    }
}
