//
//  ContentView.swift
//  Dead by Daylight Tracker
//
//  Created by Konstantin Nikolow on 12.04.25.
//

import SwiftUI
import WebKit
import Clerk
import PhotosUI

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
    @Environment(Clerk.self) private var clerk
    
    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var isVerifying = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.dbdBlack.ignoresSafeArea()
            
            if let user = clerk.user {
                TabView(selection: $selectedTab) {
                    ShopView()
                        .tabItem { Label("Shop", systemImage: "cart.fill") }
                        .tag(0)
                    
                    PerksView()
                        .tabItem { Label("Perks", systemImage: "star.fill") }
                        .tag(1)
                    
                    ItemsView()
                        .tabItem { Label("Items", systemImage: "bag.fill") }
                        .tag(2)
                    
                    LoreView()
                        .tabItem { Label("Lore", systemImage: "book.fill") }
                        .tag(3)
                    
                    AccountView(signOutAction: {
                        Task { try? await clerk.signOut() }
                    })
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(4)
                }
                .accentColor(.dbdRed)
                .animation(.easeInOut, value: selectedTab)
                
            } else {
                authView
                    .animation(.easeInOut, value: isVerifying)
                    .animation(.easeInOut, value: isSignUp)
            }
        }
    }
    
    // MARK: - Auth View (Sign In / Sign Up)
    private var authView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(isSignUp ? "Create Your Account" : "Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    if isSignUp && isVerifying {
                        TextField("Verification Code", text: $code)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()
                .background(Color.dbdBlack.opacity(0.85))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                if isSignUp && isVerifying {
                    Button {
                        Task { await verify(code: code) }
                    } label: {
                        Text("Verify Code")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dbdRed)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.7), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                } else {
                    Button {
                        Task {
                            if isSignUp {
                                await signUp(email: email, password: password)
                            } else {
                                await signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dbdRed)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.7), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                Button {
                    withAnimation(.easeInOut) {
                        isSignUp.toggle()
                        isVerifying = false
                        email = ""
                        password = ""
                        code = ""
                    }
                } label: {
                    if isSignUp {
                        Text("Already have an account? ")
                            .foregroundColor(.gray) +
                        Text("Sign In")
                            .foregroundColor(.blue)
                    } else {
                        Text("Don't have an account? ")
                            .foregroundColor(.gray) +
                        Text("Sign Up")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
                .font(.footnote)
            }
        }
    }
    
    // MARK: - Auth Logic
    
    func signUp(email: String, password: String) async {
        do {
            let signUp = try await SignUp.create(
                strategy: .standard(emailAddress: email, password: password)
            )
            
            try await signUp.prepareVerification(strategy: .emailCode)
            
            DispatchQueue.main.async {
                withAnimation {
                    isVerifying = true
                }
            }
        } catch {
            print("❌ Sign-up error: \(error)")
        }
    }
    
    func verify(code: String) async {
        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                isVerifying = false
                return
            }
            
            try await signUp.attemptVerification(strategy: .emailCode(code: code))
            
            // After verification success, hide verification UI
            DispatchQueue.main.async {
                withAnimation {
                    isVerifying = false
                }
            }
        } catch {
            dump(error)
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            try await SignIn.create(strategy: .identifier(email, password: password))
        } catch {
            print("❌ Sign-in error: \(error)")
        }
    }
}

// MARK: - Separate AccountView for cleaner code

struct AccountView: View {
    @Environment(Clerk.self) private var clerk
    let signOutAction: () -> Void
    
    @State private var notificationsEnabled = true
    @State private var profileImage: UIImage? = nil
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            // MARK: User Info with Profile Image Picker
            VStack(spacing: 8) {
                ZStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else {
                        Circle()
                            .fill(Color.dbdRed)
                            .frame(width: 80, height: 80)
                        
                        Text(userInitials)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        .frame(width: 80, height: 80)
                )
                .padding(.bottom, 4)
                
                Text(userName)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal)
            
            // MARK: Settings Section
            VStack(spacing: 20) {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable Notifications")
                        .foregroundColor(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: .dbdRed))
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal)
            
            // MARK: Sign Out Button
            Button(action: signOutAction) {
                Text("Sign Out")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.dbdRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.red.opacity(0.6), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            // MARK: Delete Account Button (Danger)
            Button {
                // TODO: Add Delete Account Logic
            } label: {
                Text("Delete Account")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.red.opacity(0.7), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
        .background(Color.dbdBlack)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
        .onAppear {
            loadProfileImage()
        }
    }
    
    // MARK: - Helpers
    
    private var userName: String {
        if let username = clerk.user?.username {
            return username
        } else if let email = clerk.user?.primaryEmailAddress?.emailAddress {
            return email.components(separatedBy: "@").first ?? "User"
        } else {
            return "User"
        }
    }
    
    private var userInitials: String {
        if let first = clerk.user?.firstName, !first.isEmpty {
            let last = clerk.user?.lastName ?? ""
            let firstInitial = first.first.map { String($0) } ?? ""
            let lastInitial = last.first.map { String($0) } ?? ""
            return (firstInitial + lastInitial).uppercased()
        }
        return "U"
    }
    
    // MARK: - Profile Image Storage
    
    func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: "profileImage"),
           let uiImage = UIImage(data: data) {
            profileImage = uiImage
        }
    }
    
    func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "profileImage")
        }
    }
}

// MARK: - ImagePicker Helper for SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                    if let uiImage = self.parent.image {
                        // Save the image locally
                        UserDefaults.standard.set(uiImage.jpegData(compressionQuality: 0.8), forKey: "profileImage")
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
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
