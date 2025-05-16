import SwiftUI

struct StatisticsView: View {
    var data: [StatisticsCellView.ViewModel]
    var body: some View {
        if data.isEmpty {
            VStack {
                Image(uiImage: .noResults)
                Text("Анализировать пока нечего")
            }
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    Spacer().frame(height: 70)
                    ForEach(data) {
                        StatisticsCellView(viewModel: $0)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct StatisticsViewWithNavigation: View {
    class ViewModel: ObservableObject {
        @Published var data: [StatisticsCellView.ViewModel]
        init(data: [StatisticsCellView.ViewModel]) {
            self.data = data
        }
    }
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        NavigationView {
            StatisticsView(data: viewModel.data)
                .navigationTitle("Статистика")
                .navigationBarTitleDisplayMode(.automatic)

        }
    }
}

#Preview("no results") {
    StatisticsViewWithNavigation(
        viewModel: .init(data: [])
    )
}
#Preview {
    StatisticsViewWithNavigation(
        viewModel: .init(
            data: [
                .init(
                    amount: 6,
                    text: "Лучший период"
                ),
                .init(
                    amount: 2,
                    text: "Идеальные дни"
                ),
            ]
        )
    )
}
