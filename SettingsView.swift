
import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("SETTINGS")
                    .font(.largeTitle.bold())
                    .tracking(3)
                    .foregroundStyle(.white)

                Text(isArabic ? "إعدادات التطبيق" : "Application Settings")
                    .foregroundStyle(.gray)

                VStack(alignment: .leading, spacing: 16) {
                    Label(
                        isArabic ? "اللغة" : "Language",
                        systemImage: "globe"
                    )
                    .font(.headline)
                    .foregroundStyle(.white)

                    Picker(
                        isArabic ? "اختر اللغة" : "Choose Language",
                        selection: $appLanguage
                    ) {
                        Text("العربية").tag("ar")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    settingRow(
                        isArabic ? "اسم التطبيق" : "App Name",
                        "ALMASIH"
                    )

                    settingRow(
                        isArabic ? "الإصدار" : "Version",
                        "1.0.0"
                    )

                    settingRow(
                        isArabic ? "النظام المدعوم" : "Supported iOS",
                        "iOS 16+"
                    )
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Spacer()

                Text("ALMASIH ☦︎")
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
    }

    private func settingRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .foregroundStyle(.white)
        }
    }
}
