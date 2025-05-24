//
//  ContentView.swift
//  Dead by Daylight Tracker
//
//  Created by Konstantin Nikolow on 12.04.25.
//

import SwiftUI

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

struct ShopView: View {
    @State private var selectedTab = "FEATURED"
    let tabs = ["FEATURED", "COLLECTIONS", "BUNDLES", "KILLERS", "SURVIVORS"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Skin carousel
                            TabView {
                                ForEach(skins) { skin in
                                    ZStack(alignment: .bottom) {
                                        Image(skin.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 300)
                                            .clipped()
                                            .cornerRadius(15)
                                            .shadow(radius: 6)
                                        
                                        Text(skin.name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.bottom, 10)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(5)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 300)
                            
                            // Featured Characters
                            VStack(alignment: .leading) {
                                Text("FEATURED CHARACTERS")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(0..<3) { i in
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.4))
                                                .frame(width: 100, height: 120)
                                                .overlay(Text("Char \(i + 1)").foregroundColor(.white))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Featured Content
                            VStack(alignment: .leading) {
                                Text("FEATURED CONTENT")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 80)
                                    .padding(.horizontal)
                                    .overlay(
                                        Text("Dead by Daylight Official Shop")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    )
                            }
                            
                            // Free Gift
                            VStack(alignment: .leading) {
                                Text("FREE GIFT")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.5))
                                    .frame(width: 120, height: 140)
                                    .padding(.horizontal)
                            }
                            
                            Spacer().frame(height: 30)
                        }
                    }
                    
                    HStack(spacing: 30) {
                        Button("GET AURIC CELLS") {}
                    }
                    .font(.caption)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
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
    }
}

// MARK: - PerksView

struct PerksView: View {
    @State private var perks: [Perk] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dbdBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Perks")
                            .font(.largeTitle)
                            .foregroundColor(.dbdRed)
                            .padding(.horizontal)
                        
                        if perks.isEmpty {
                            Text("Loading perks...")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                        } else {
                            ForEach(perks) { perk in
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
            .navigationTitle("Perks")
            .onAppear {
                perks = loadPerks()
            }
            .navigationBarTitle("Perks", displayMode: .inline)
            .toolbarBackground(Color.dbdBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

// MARK: - LoreView

struct LoreView: View {
    @State private var loreText: String = """
    Everyone in the game is trapped there by an eldritch being known as The Entity. The Entity feeds off suffering—particularly the loss of hope. The trials we play are a kind of ritual designed to extract that emotion from the survivors and offer it up to the Entity. It gives them a false sense of hope by allowing them to escape, then feasts on them as that hope is stripped away and they are sacrificed. Whether the survivor lives or dies, they always end up back at the campfire. But for survivors who are sacrificed, they lose a tiny piece of themselves. Eventually, when they lose their last glimmer of hope, they become empty husks. The Entity casts these husks into the Void—especially relevant right now because of the current Void event.

    Killers are beings it has picked up—ones that cause suffering and pain. Some do so willingly, others through manipulation. The Entity can torture them into complying, amplify existing feelings of hatred and violence, or trick them into perceiving survivors as their enemies—whatever it takes to make them participate. They’re just as trapped as the survivors, and for a few, just as tormented.

    That’s the basics of it. If you want to know more, I’d suggest reading up on some of the concepts on the Wiki. The Entity and The Trials are good places to start. They regularly expand the lore through The Archives, which are released every few months with a new Tome. These Tomes include stories about specific characters but also contain entries about events happening outside the trials. There are other beings in the Fog that don’t participate in the trials, and some locations that you never actually see in-game.
    """

    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dbdBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if loreText.isEmpty {
                            Text("Loading lore...")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                        } else {
                            Text(loreText)
                                .foregroundColor(.white)
                                .font(.body)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Lore")
            .toolbarBackground(Color.dbdBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
// MARK: - Preview

#Preview {
    ContentView()
}
