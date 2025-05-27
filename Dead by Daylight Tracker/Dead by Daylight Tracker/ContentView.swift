//
//  ContentView.swift
//  Dead by Daylight Tracker
//
//  Created by Konstantin Nikolow on 12.04.25.
//

import SwiftUI
import WebKit

struct Perk: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let icon: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case icon
    }
}

func loadPerks() -> [Perk] {
    guard let url = Bundle.main.url(forResource: "perks", withExtension: "json") else {
        print("🚫 JSON file NOT FOUND in bundle")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let perks = try JSONDecoder().decode([Perk].self, from: data)
        print("✅ Loaded \(perks.count) perks")
        return perks
    } catch {
        print("❌ JSON Decode Error: \(error)")
        return []
    }
}

// MARK: - Color Extensions

extension Color {
    static let dbdRed = Color(red: 0.6, green: 0, blue: 0)
    static let dbdBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
}

// MARK: - StoreItem Model

struct StoreItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: String
    let imageName: String
}

let featuredItems = [
    StoreItem(name: "The Trapper", description: "Base Killer", price: "500 Auric Cells", imageName: "trapper"),
    StoreItem(name: "Meg Thomas", description: "Base Survivor", price: "500 Auric Cells", imageName: "meg")
]

let specialItems = [
    StoreItem(name: "Rift Pass", description: "Unlock 20 Tiers", price: "1000 Auric Cells", imageName: "rift_pass"),
    StoreItem(name: "Bloodpoint Bundle", description: "Get 300,000 BP", price: "Free Gift", imageName: "bp_bundle")
]

// MARK: - CurrencyBalanceView

struct CurrencyBalanceView: View {
    let iconName: String
    let amount: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)
            Text(amount)
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}

// MARK: - FeaturedItemView

struct FeaturedItemView: View {
    let item: StoreItem
    
    var body: some View {
        VStack(spacing: 10) {
            Image(item.imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            Text(item.name)
                .foregroundColor(.white)
                .font(.caption)
            Text(item.price)
                .foregroundColor(.dbdRed)
                .font(.caption2)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

// MARK: - SpecialItemView

struct SpecialItemView: View {
    let item: StoreItem
    
    var body: some View {
        HStack(spacing: 15) {
            Image(item.imageName)
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(item.description)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Text(item.price)
                    .foregroundColor(.dbdRed)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        TabView {
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart.fill")
                }
            
            PerksView()
                .tabItem {
                    Label("Perks", systemImage: "star.fill")
                }
            
            ItemsView()
                .tabItem {
                    Label("Items", systemImage: "bag.fill")
                }
            
            LoreView()
                .tabItem {
                    Label("Lore", systemImage: "book.fill")
                }
        }
        .accentColor(.dbdRed)
    }
}

struct Skin: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

let skins: [Skin] = [
    // Taurie skin removed to prevent crash
    // Skin(name: "Taurie Cain", imageName: "taurie_skin"),
    // Skin(name: "Maiden Guard", imageName: "plague_maiden_guard"),
    // Skin(name: "Blood Queen", imageName: "blight_human_form"),
    // Skin(name: "Ancient Wrath", imageName: "nurse_sally_render")
]

struct Power: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let icon: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case icon
    }
}

// MARK: - Loaders

func loadPowers() -> [Power] {
    guard let url = Bundle.main.url(forResource: "powers", withExtension: "json") else {
        print("🚫 powers.json NOT FOUND")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let powers = try JSONDecoder().decode([Power].self, from: data)
        print("✅ Loaded \(powers.count) powers")
        return powers
    } catch {
        print("❌ Error loading powers: \(error)")
        return []
    }
}

// MARK: - Views

struct PowersGridView: View {
    let powers: [Power]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(powers) { power in
                VStack {
                    Image(power.icon.replacingOccurrences(of: ".png", with: ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    Text(power.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 100)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
        }
    }
}

struct ShopView: View {
    @State private var selectedTab = "FEATURED"
    private let tabs = ["FEATURED", "COLLECTIONS", "BUNDLES", "KILLERS"]
    
    @State private var powers: [Power] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top tab selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(tabs, id: \.self) { tab in
                                Text(tab)
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
                                    .fontWeight(selectedTab == tab ? .bold : .regular)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(selectedTab == tab ? Color.white.opacity(0.15) : Color.clear)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedTab = tab
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main content
                    ScrollView {
                        VStack(spacing: 30) {
                            switch selectedTab {
                                case "FEATURED":
                                    featuredSection
                                case "COLLECTIONS":
                                    collectionsSection
                                case "BUNDLES":
                                    bundlesSection
                                case "KILLERS":
                                    PowersGridView(powers: powers).padding(.horizontal)
                                default:
                                    placeholderSection(title: selectedTab)
                            }
                        }
                        .padding(.top, 20)
                    }
                    
                    // Bottom Bar
                    HStack {
                        Spacer()
                        Button("GET AURIC CELLS") {}
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .background(Color.black.opacity(0.8))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Shop of the Day")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            powers = loadPowers()
        }
    }
    
    // MARK: - Sections
    
    var featuredSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🔥 HOT PICKS")
                .font(.title2)
                .foregroundColor(.dbdRed)
                .padding(.horizontal)
            
            ForEach(featuredItems, id: \.name) { item in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(item.price)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: symbolForItem(item))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.dbdRed)
                        }
                            .padding()
                    )
                    .padding(.horizontal)
            }
        }
    }
    
    var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🛍️ COLLECTIONS")
                .font(.title2)
                .foregroundColor(.green)
                .padding(.horizontal)
            
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 110)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Collection #\(i + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("A curated set of items including skins, perks, and charms.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "star.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                        }
                            .padding()
                    )
                    .padding(.horizontal)
            }
        }
    }
    
    var bundlesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🎁 CRAZY BUNDLES")
                .font(.title2)
                .foregroundColor(.yellow)
                .padding(.horizontal)
            
            ForEach(0..<4) { i in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.2))
                    .frame(height: 100)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Bundle Pack #\(i + 1)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text("Random mix of skins, charms, and premium currency.")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
                            VStack {
                                Text("Only")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(500 + i * 200) AC")
                                    .font(.headline)
                                    .foregroundColor(.dbdRed)
                            }
                        }
                            .padding()
                    )
                    .padding(.horizontal)
            }
        }
    }
    
    func placeholderSection(title: String) -> some View {
        VStack {
            Text("\(title) content goes here")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    // MARK: - Symbol Resolver
    
    func symbolForItem(_ item: StoreItem) -> String {
        switch item.name {
            case "The Trapper": return "flame.fill"
            case "Meg Thomas": return "person.fill"
            case "Voidborn Huntress": return "moon.stars.fill"
            case "Urban Escape Bundle": return "figure.walk"
            case "Cyber Meg": return "cpu.fill"
            case "Trickster Neon Pack": return "sparkles"
            case "The Entity's Gift": return "gift.fill"
            default: return "star"
        }
    }
}

// MARK: - PerksView

struct PerksView: View {
    @State private var perks: [Perk] = []
    @State private var searchText: String = ""
    
    var filteredPerks: [Perk] {
        if searchText.isEmpty {
            return perks
        } else {
            return perks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dbdBlack.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search Perks", text: $searchText)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            if filteredPerks.isEmpty {
                                Text("No perks found.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(filteredPerks) { perk in
                                    HStack(spacing: 15) {
                                        Image(perk.icon.replacingOccurrences(of: ".png", with: ""))
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                            .shadow(radius: 3)
                                        Text(perk.name)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Perks")
            .onAppear {
                perks = loadPerks()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.dbdBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

struct Item: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let icon: String
    
    private enum CodingKeys: String, CodingKey {
        case name, icon
    }
}

func loadItems() -> [Item] {
    guard let url = Bundle.main.url(forResource: "items", withExtension: "json") else {
        print("🚫 items.json NOT FOUND")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let items = try JSONDecoder().decode([Item].self, from: data)
        print("✅ Loaded \(items.count) items")
        return items
    } catch {
        print("❌ Error loading items: \(error)")
        return []
    }
}

struct ItemsView: View {
    @State private var items: [Item] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dbdBlack.ignoresSafeArea()
                
                if items.isEmpty {
                    ProgressView("Loading items...")
                        .foregroundColor(.white)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(items) { item in
                                VStack(spacing: 10) {
                                    Image(item.icon.replacingOccurrences(of: ".png", with: ""))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                    Text(item.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Items")
            .onAppear {
                items = loadItems()
            }
            .toolbarBackground(Color.dbdBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

struct YouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedHTML = """
        <html>
        <body style="margin:0;padding:0;background-color:black;">
        <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoID)?playsinline=1" frameborder="0" allowfullscreen></iframe>
        </body>
        </html>
        """
        uiView.loadHTMLString(embedHTML, baseURL: URL(string: "about:blank"))
    }
}

// MARK: - LoreView

struct LoreView: View {
    let sections: [(title: String, content: String)] = [
        ("The Entity & The Trials", """
        Everyone in the game is trapped there by an eldritch being known as The Entity. The Entity feeds off suffering—particularly the loss of hope. The trials we play are a kind of ritual designed to extract that emotion from the survivors and offer it up to the Entity.
        
        It gives them a false sense of hope by allowing them to escape, then feasts on them as that hope is stripped away and they are sacrificed. Whether the survivor lives or dies, they always end up back at the campfire. But for survivors who are sacrificed, they lose a tiny piece of themselves. Eventually, when they lose their last glimmer of hope, they become empty husks. The Entity casts these husks into the Void—especially relevant right now because of the current Void event.
        """),
        ("The Killers", """
        Killers are beings it has picked up—ones that cause suffering and pain. Some do so willingly, others through manipulation. The Entity can torture them into complying, amplify existing feelings of hatred and violence, or trick them into perceiving survivors as their enemies—whatever it takes to make them participate.
        
        They’re just as trapped as the survivors, and for a few, just as tormented.
        """),
        ("Learn More", """
        That’s the basics of it. If you want to know more, read up on some of the concepts on the Wiki. The Entity and The Trials are good places to start.
        
        They regularly expand the lore through The Archives, released every few months with a new Tome. These Tomes include stories about specific characters and events happening outside the trials. There are other beings in the Fog that don’t participate in the trials, and some locations that you never actually see in-game.
        """)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dbdBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(sections, id: \.title) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                
                                Text(section.content)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal)
                        }
                        
                        YouTubeView(videoID: "_ODIjT5JSbU")
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Lore")
            .toolbarBackground(Color.dbdBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}


// MARK: - Preview

#Preview {
    ContentView()
}
