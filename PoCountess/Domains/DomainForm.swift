//
//  DomainForm.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

struct DomainForm: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var domainCoordinator: DomainCoordinator

    @ObservedObject var domain: Domain

    @State private var isShowingTitle = false
    @FocusState private var isFormFocused: Bool
    @FocusState private var isNameFocused: Bool
    
    internal init(_ domain: Domain) {
        self.domain = domain
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $domain.namespaceOrBlank, prompt: Text("new.namespace"))
                .accessibilityLabel("domain.namespace.label")
                .font(!isNameFocused && domain.namespace != nil && domain.titleOrBlank.isEmpty ? .title.weight(.bold) : .subheadline)
                .foregroundColor(.secondary)
                .focused($isNameFocused)
                .onSubmit {
                    do {
                        try viewContext.saveIfChanges()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            if isShowingTitle || !domain.titleOrBlank.isEmpty {
                TextField("Title", text: $domain.titleOrBlank, prompt: Text("Human name"))
                    .accessibilityLabel("domain.title.label")
                    .font(.title.weight(.bold))
            }
        }
        .textFieldStyle(.plain)
        .labelsHidden()
        .focused($isFormFocused)
        .padding()
        .onChange(of: isFormFocused) { isFocused in
            isShowingTitle = isFocused
            saveChanges()
        }
        .onSubmit {
            isFormFocused = false
            saveChanges()
        }
        .onAppear {
            // Only focus on name if we just created that domain
            if domainCoordinator.justAdded == domain && domain.namespaceOrBlank.isEmpty {
                isNameFocused = true
            }
        }
        .onDisappear {
            domainCoordinator.justAdded = nil
        }
    }
    
    func saveChanges() {
        do {
            try viewContext.saveIfChanges()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

struct DomainForm_Previews: PreviewProvider {
    static var previewDomain: Domain {
        let domain = Domain(context: PersistenceController.preview.container.viewContext)
        domain.namespace = "app.countess.preview"
        return domain
    }
    
    static var previews: some View {
        DomainForm(previewDomain)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
