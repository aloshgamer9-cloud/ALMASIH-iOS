import SwiftUI

struct ALMASIHAIView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"
    @State private var message = ""

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                Text("☦︎")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text("ALMASIH AI")
                    .font(.title2.bold())
                    .tracking(3)
                    .foregroundStyle(.white)

                Text(isArabic ? "المساعد الذكي" : "INTELLIGENT ASSISTANT")
                    .font(.caption)
                    .tracking(2)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 25)

            VStack(alignment: .leading, spacing: 12) {
                Label(
                    isArabic ? "المساعد غير متصل بعد" : "ASSISTANT NOT CONNECTED",
                    systemImage: "lock.shield"
                )
                .font(.caption.bold())
                .foregroundStyle(.white)

                Text(
                    isArabic
                    ? "واجهة المساعد جاهزة. نحتاج إعداد اتصال آمن بخدمة الذكاء الاصطناعي حتى يتمكن من الرد على رسائلك."
                    : "The assistant interface is ready. A secure AI service connection is required before it can respond."
                )
                .font(.subheadline)
                .foregroundStyle(.gray)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()

            HStack(spacing: 10) {
                TextField(
                    isArabic ? "اكتب رسالتك..." : "Write a message...",
                    text: $message
                )
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .disabled(true)

                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(
                isArabic
                ? "سيتم تفعيل المحادثة بعد ربط الخدمة الآمنة."
                : "Chat will be enabled after secure service integration."
            )
            .font(.caption2)
            .foregroundStyle(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}