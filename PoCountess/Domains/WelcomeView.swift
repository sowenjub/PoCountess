//
//  WelcomeView.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 24/05/2022.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStateRegistry: AppStateRegistry

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                VStack {
                    Text("🧝‍♀️")
                    Text("welcome.title")
                        .foregroundColor(.accentColor)
                }
                .font(.title.bold())
                Text("welcome.body")
                    .multilineTextAlignment(.center)
                Button("domain.add", action: addDomain)
                    .buttonStyle(.plain)
                    .padding(8)
                    .font(.body.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor)
                            .shadow(color: .accentColor, radius: 1, x: 0, y: 0)
                    )
                Spacer()
            }
            HStack {
                Text("welcome.demo")
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .foregroundColor(.gray)
                Spacer()
                Button("welcome.loadDemo", action: addDemoDomain)
                    .buttonStyle(.plain)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                    )
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 400)
    }
    
    private func addDomain() {
        withAnimation {
            let newDomain = Domain(context: viewContext)
            newDomain.position = 1
            do {
                try viewContext.save()
                appStateRegistry.domainCoordinator.selected = newDomain
                appStateRegistry.domainCoordinator.justAdded = newDomain
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addDemoDomain() {
        withAnimation {
            do {
                let demoDomain = try PersistenceController.loadDemo(context: viewContext)
                appStateRegistry.domainCoordinator.selected = demoDomain
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
