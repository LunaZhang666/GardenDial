import SwiftUI
import StoreKit

extension View {
    func hideKeyboard() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.endEditing(true) }
        }
    }
}

struct ContentView: View {
    @AppStorage("hasAcceptedDisclaimer") var hasAcceptedDisclaimer: Bool = false
    @State private var showDisclaimer: Bool = false
    
    @State private var showInfoSheet = false
    @State private var showTipReviewActionSheet: Bool = false
    @State private var showTipSheet: Bool = false
    
    @State private var showAdvancedSettings = false
    @State private var showVolumeInfo: Bool = false
    
    let settingFinder = SprayerSettingFinder()
    @State private var productName: String = ""
    @State private var showingAlert = false
    
    @FocusState private var isConcentrationFocused: Bool
    
    let sprayerModels = ["Ortho Dial N Spray"]
    @State private var selectedSprayerModel: String = "Ortho Dial N Spray"
    
    @State private var recommendedConcentration: String = "1"
    let concentrationUnits = ["Teaspoon", "Tablespoon", "OZ"]
    @State private var recommendedUnit: String = "Tablespoon"
    
    @State private var selectedStrengthPercentage: Double = 100
    
    @State private var concentrationRatio: Double = 500
    @State private var isRatioActive: Bool = false
    
    @State private var volumeGallon: Double = 10
    
    @State private var message = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
//                    // Model picker - Future Version
//                    Menu {
//                        ForEach(sprayerModels, id: \.self) { model in
//                            Button(action: {
//                                selectedSprayerModel = model
//                            }) {
//                                Text(model)
//                                    .font(.title) // affects dropdown
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedSprayerModel)
//                                .font(.title) // This WILL show large in the main UI
//                            Image(systemName: "chevron.down")
//                                .imageScale(.large)
//                        }
//                        .padding(.bottom, 15)
//                    }
                    Text(selectedSprayerModel)
                        .font(.largeTitle)
                        .padding(.bottom, 15)

                    // Imperial unit entry
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            TextField("1", text: $recommendedConcentration)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title3)
                                .frame(width: 70)
                                .keyboardType(.decimalPad)
                                .focused($isConcentrationFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button(action: {
                                            isConcentrationFocused = false
                                        }) {
                                            Text("ENTER")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                                .onChange(of: recommendedConcentration) { newValue in
                                   if newValue.count > 4 {
                                       recommendedConcentration = String(newValue.prefix(4))
                                   }
                                    message = ""
                               }

                            Picker("Unit", selection: $recommendedUnit) {
                                ForEach(concentrationUnits, id: \.self) { unit in
                                    Text(unit)
                                        .font(.title3)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: recommendedUnit) { _ in message = "" }
                            
                            Text("per Gallon")
                                .font(.title3)
                        }
                        VStack {
                            Text("Adjust Strength: \(Int(selectedStrengthPercentage))%")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Slider(value: $selectedStrengthPercentage, in: 5...200, step: 5)
                                .onChange(of: selectedStrengthPercentage) { _ in message = "" }

                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .opacity(isRatioActive ? 0.4 : 1)
                    .grayscale(isRatioActive ? 1.0 : 0.0)
                    .disabled(isRatioActive)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isRatioActive = false
                            message = ""
                        }
                    }
                    
                    Text("Or")
                        .padding(.top, -5)
                        .padding(.bottom, -5)
                        .font(.title3)
                    // Ratio entry
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Use 1:\(Int(concentrationRatio))")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Slider(value: $concentrationRatio, in: 100...2000, step: 50)
                            .onChange(of: concentrationRatio) { _ in
                                isRatioActive = true
                                message = ""
                            }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .opacity(!isRatioActive ? 0.4 : 1)
                    .grayscale(!isRatioActive ? 1.0 : 0.0)
                    .disabled(!isRatioActive)
                    .onTapGesture {
                        withAnimation {
                            isRatioActive = true
                            message = ""
                        }
                    }
                    
                    // Advanced Toggle
                    VStack(spacing: -5) {
                        Button(action: {
                            withAnimation {
                                showAdvancedSettings.toggle()
                            }
                        }) {
                            HStack {
                                Text("Advanced Setting")
                                Spacer()
                                Image(systemName: showAdvancedSettings ? "chevron.up" : "chevron.down")
                            }
                            .font(.title3)
                            .padding()

                        }
                        // Volume Entry
                        if showAdvancedSettings {
                            VStack{
                                VStack {
                                    HStack{
                                        Text("Total water volume: \(Int(volumeGallon)) gallon\(volumeGallon == 1 ? "" : "s")")
                                            .font(.title3)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Button(action: {
                                            withAnimation {
                                                showVolumeInfo.toggle()
                                            }
                                        }) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Slider(value: $volumeGallon, in: 1...50, step: 1)
                                        .onChange(of: volumeGallon) { _ in message = "" }
                                }
                                .padding()

                                if showVolumeInfo {
                                    Text("Total amount of water to apply is required to calculate the correct amount of product. If unsure, use default 10 gal.")
                                        .font(.body)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .transition(.opacity.combined(with: .slide))
                                }
                            }
                            .transition(.slide)
                        }
                        
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.top, 10)
                    
                    Button(action: {
                        hideKeyboard()
                        showVolumeInfo = false
                        message = settingFinder.getInstruction(
                            sprayerModel: selectedSprayerModel,
                            totalVolumeGallon: volumeGallon,
                            concentrationPerGallcon: recommendedConcentration,
                            selectedStrengthPercentage: selectedStrengthPercentage,
                            unitPerGallon: recommendedUnit,
                            concentrationRatio: concentrationRatio,
                            isRatioActive: isRatioActive
                        )
                        showingAlert = message.contains("Unable") || message.contains("valid")
                    }) {
                        Text("Calculate")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    // instruction message
                    if !message.isEmpty {
                        Text(message)
                            .font(.title2)
                            .padding()
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .alert("Calculation Error", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(message)
                }
                .onAppear {
                    // Show disclaimer if it hasn't been accepted
                    if !hasAcceptedDisclaimer {
                        showDisclaimer = true
                    }
                }
                .sheet(isPresented: $showDisclaimer) {
                    DisclaimerView(hasAcceptedDisclaimer: $hasAcceptedDisclaimer)
                }
                .sheet(isPresented: $showInfoSheet) {
                    InfoView()
                }
                .sheet(isPresented: $showTipSheet) {
                    TipSheetView(isPresented: $showTipSheet) { productID in
                        purchaseTip(productID: productID)
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Leave a Review") {
                            requestReview()
                        }
                        Button("Tip Developer") {
                            showTipSheet = true
                        }

                    } label: {
                        Image(systemName: "star.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInfoSheet = true
                    }) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                    }
                }
            }.gesture(
                TapGesture().onEnded {
                    hideKeyboard()
                }
                
            )
            
        }
    }

    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func purchaseTip (productID: String) {
        Task {
            do {
                let products = try await Product.products(for: [productID])
                guard let tipProduct = products.first else {
                    print("Tip product not found.")
                    return
                }
                let result = try await tipProduct.purchase()
                switch result {
                case .success(let verification):
                    if case .verified(let transaction) = verification {
                        await transaction.finish()
                        print("Purchase successful!")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                case .pending:
                    print("Purchase is pending.")
                default: break
                }
            } catch {
                print("Failed to purchase product: \(error)")
            }
        }
    }
}

struct TipSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    var purchaseTip: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🎁 Your tip helps support future updates and improvements!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                VStack(spacing: 10) {
                    Button(action: {
                        purchaseTip("com.lunaz.GardenDial.tip199")
                        isPresented = false
                    }) {
                        Text("$1.99 for 🍬")
                            .font(.title3)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        purchaseTip("com.lunaz.GardenDial.tip499")
                        isPresented = false
                    }) {
                        Text("$4.99 for ☕️")
                            .font(.title3)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        purchaseTip("com.lunaz.GardenDial.tip999")
                        isPresented = false
                    }) {
                        Text("$9.99 for 🍔")
                            .font(.title3)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                }

            }
            .padding()
            .navigationBarTitle("Support the Developer", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DisclaimerView: View {
    @Binding var hasAcceptedDisclaimer: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Disclaimer")
                    .font(.title)
                    .padding(.bottom, 8)
                Text("This application is intended for use exclusively with Hose-End Mix Sprayers for applying soluble weed killers, insecticides, fungicides, and fertilizers.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Text("Calculated concentrations provided by this app are approximate. Variations may occur due to measuring, device limitations and simplified instructions. In most cases, the calculated concentraion is whitin 20% of the desired value. If it differs by more than 20%, a note will be provided.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Text("Always ensure that your chosen product is completely dissolved before application to avoid clogging, uneven distribution, or reduced effectiveness.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Text("Carefully read and strictly follow all instructions and safety precautions provided on your chemical product’s label and the sprayer manual.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Text("The developers of this app are not responsible for damage, injury, or product ineffectiveness resulting from improper use or failure to follow product guidelines.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Button(action: {
                    hasAcceptedDisclaimer = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Agree")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10){
                        Text("📘 How to Use GardenDial")
                            .font(.title)
                            .padding(.bottom)
                        Group {
                            // Text("1. Select your sprayer model.").font(.title3) // Future version
                            Text("1. Choose a concentration option").font(.title3)
                            Text("• Option A: Enter the recommended concentration from the product label (e.g., 1 tbs/gal), and adjust strength using the slider if needed.")
                            Text("• Option B: Select a ratio, e.g., 1:500")
                            Text("2. Select how many gallons of water you’ll apply to the garden. If you're unsure, start with a small batch and adjust accordingly.").font(.title3)
                            Text("3. Tap 'Calculate' to get mixing instructions.").font(.title3)
                        }
                    }
                    
                    Divider().padding(.vertical)

                    Text("💡 Note")
                        .font(.title)
                        .padding(.top)

                    Text("""
Always read your product label and sprayer instructions carefully. Ensure products are fully dissolved before spraying.

Final spray concentrations are approximate. Variations may occur due to measuring, device limitations and simplified ratios.
""")
                }
                .padding()
                .font(.body)
            }
            .navigationBarTitle("Instructions", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
