import SwiftUI

struct PremiumView: View {
    @State private var selectedPlan: PremiumPlan = .yearly
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.bloomYellow)
                        
                        Text("Bloom Premium")
                            .font(.bloomH1)
                            .foregroundColor(.bloomTextPrimary)
                        
                        Text("Unlock unlimited learning")
                            .font(.bloomBody)
                            .foregroundColor(.bloomTextSecondary)
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", title: "Unlimited lessons", description: "Learn as much as you want, every day")
                        FeatureRow(icon: "bolt.fill", title: "Unlimited energy", description: "No waiting for energy to refill")
                        FeatureRow(icon: "arrow.down.circle.fill", title: "Offline access", description: "Download lessons for offline learning")
                        FeatureRow(icon: "star.fill", title: "Exclusive content", description: "Access premium-only courses")
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Plan selection
                    VStack(spacing: 12) {
                        PlanOption(
                            plan: .yearly,
                            isSelected: selectedPlan == .yearly,
                            onSelect: { selectedPlan = .yearly }
                        )
                        
                        PlanOption(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly,
                            onSelect: { selectedPlan = .monthly }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Subscribe button
                    BloomButton(
                        title: "Start Free Trial",
                        color: .bloomYellow,
                        action: { /* Handle subscription */ }
                    )
                    .padding(.horizontal, 20)
                    
                    // Terms
                    Text("7-day free trial, then \(selectedPlan.priceText). Cancel anytime.")
                        .font(.bloomCaption)
                        .foregroundColor(.bloomTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.bloomBackground)
            .navigationTitle("")
        }
    }
}

enum PremiumPlan {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var price: Double {
        switch self {
        case .monthly: return 24.99
        case .yearly: return 149.99
        }
    }
    
    var priceText: String {
        switch self {
        case .monthly: return "$24.99/month"
        case .yearly: return "$149.99/year"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "Save 50%"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.bloomYellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bloomBodyMedium)
                    .foregroundColor(.bloomTextPrimary)
                
                Text(description)
                    .font(.bloomSmall)
                    .foregroundColor(.bloomTextSecondary)
            }
        }
    }
}

struct PlanOption: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.bloomBodyMedium)
                            .foregroundColor(.bloomTextPrimary)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.bloomCaptionMedium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.bloomGreen)
                                )
                        }
                    }
                    
                    Text(plan.priceText)
                        .font(.bloomSmall)
                        .foregroundColor(.bloomTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .bloomYellow : .gray.opacity(0.3))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.bloomYellow : Color.gray.opacity(0.2), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.bloomYellow.opacity(0.05) : Color.white)
                    )
            )
        }
    }
}

#Preview {
    PremiumView()
}
