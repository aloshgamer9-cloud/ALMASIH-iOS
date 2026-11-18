
import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                Text("SETTINGS")
                    .font(.largeTitle.bold())
                    .tracking(3)
                    .foregroundStyle(.white)

                Text("إعدادات التطبيق")
                    .foregroundStyle(.gray)

                VStack(alignment: .leading, spacing: 14) {
                    Label("اللغة / Language", systemImage: "globe")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Picker("اللغة", selection: $appLanguage) {
                        Text("العربية").tag("ar")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: appLanguage) { newValue in
                        UserDefaults.standard.set(
                            [newValue],
                            forKey: "AppleLanguages"
                        )
                    }
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                HStack {
                    Text("إصدار التطبيق")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.gray)
                }
                .foregroundStyle(.white)
                .padding()

                Spacer()

                Text("ALMASIH ☦︎")
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
