import SwiftUI

struct StatisticsCellView: View {
    struct ViewModel: Identifiable {
        var id: String { text }
        var amount: Int
        var text: String
    }
    var viewModel: ViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("\(viewModel.amount)")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
            }
            Text(viewModel.text)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 12)
        .frame(height: 90)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient.statistics,
                    lineWidth: 1
                )
        )
    }
}

extension LinearGradient {
    static let statistics = LinearGradient(
        gradient: Gradient(
            stops: [
                .init(
                    color: .StatisticsGradient.stop1,
                    location: 0
                ),
                .init(
                    color: .StatisticsGradient.stop2,
                    location: 0.53
                ),
                .init(
                    color: .StatisticsGradient.stop3,
                    location: 1
                ),
            ]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
}

#Preview {
        StatisticsCellView(
            viewModel: .init(
                amount: 6,
                text: "Лучший период"
            )
        )
        .padding(.horizontal, 16)
}
