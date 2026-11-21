
import SwiftUI
import UIKit

struct AssistantView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"

    @State private var message = ""
    @State private var messages: [ChatMessage] = []

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    var body: some View {
        VStack(spacing: 14) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if messages.isEmpty {
                            welcomeView
                        }

                        ForEach(messages) { item in
                            messageBubble(item)
                                .id(item.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: messages.count) { _ in
                    guard let last = messages.last else { return }
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            inputBar
        }
        .padding()
        .background(Color.black)
        .environment(
            \.layoutDirection,
            isArabic ? .rightToLeft : .leftToRight
        )
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("ALMASIH AI")
                    .font(.title2.bold())
                    .tracking(2)
                    .foregroundStyle(.white)

                Text(isArabic ? "المساعد المحلي" : "LOCAL ASSISTANT")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 10)
    }

    private var welcomeView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(
                isArabic
                ? "مرحباً بك في مساعد ALMASIH"
                : "Welcome to ALMASIH Assistant"
            )
            .font(.title3.bold())
            .foregroundStyle(.white)

            Text(
                isArabic
                ? "كيف أستطيع مساعدتك اليوم؟"
                : "How can I help you today?"
            )
            .foregroundStyle(.gray)

            suggestion(
                isArabic ? "معلومات الجهاز" : "Device information"
            )

            suggestion(
                isArabic ? "معلومات البطارية" : "Battery information"
            )

            suggestion(
                isArabic ? "حالة الشبكة" : "Network status"
            )

            suggestion(
                isArabic ? "مساعدة التطبيق" : "App help"
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func suggestion(_ title: String) -> some View {
        Button {
            send(text: title)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.left")
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(12)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func messageBubble(_ item: ChatMessage) -> some View {
        HStack {
            if item.isUser {
                Spacer(minLength: 40)
            }

            Text(item.text)
                .font(.body)
                .foregroundStyle(.white)
                .padding(13)
                .background(
                    item.isUser
                    ? Color.white.opacity(0.18)
                    : Color.white.opacity(0.07)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(maxWidth: 290, alignment: .leading)

            if !item.isUser {
                Spacer(minLength: 40)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(
                isArabic ? "اكتب رسالتك..." : "Write a message...",
                text: $message,
                axis: .vertical
            )
            .lineLimit(1...4)
            .foregroundStyle(.white)
            .padding(12)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .accessibilityIdentifier("assistant_message_input")

            Button {
                send(text: message)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.white)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("assistant_send_button")
        }
    }

    private func send(text: String) {
        let question = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !question.isEmpty else { return }

        messages.append(
            ChatMessage(text: question, isUser: true)
        )

        message = ""

        let answer = localAnswer(for: question)

        messages.append(
            ChatMessage(text: answer, isUser: false)
        )
    }

    private func localAnswer(for question: String) -> String {
        let q = question.lowercased()

        if isArabic {
            if q.contains("مرحبا") ||
                q.contains("هلا") ||
                q.contains("السلام") {
                return "أهلاً بك في ALMASIH. أنا مساعدك المحلي."
            }

            if q.contains("بطارية") {
                return "يمكنك مشاهدة مستوى البطارية وحالة الشحن من تبويب المراقبة."
            }

            if q.contains("جهاز") ||
                q.contains("معلومات") {
                return "يمكنك مشاهدة معلومات الجهاز وإصدار iOS والبطارية من تبويب المراقبة."
            }

            if q.contains("شبكة") ||
                q.contains("انترنت") ||
                q.contains("اتصال") {
                return "يعرض التطبيق حالة اتصال الشبكة. لا يستطيع iOS السماح للتطبيق بزيادة سرعة اتصال النظام مباشرة."
            }

            if q.contains("وظائف") ||
                q.contains("التطبيق") {
                return "يحتوي ALMASIH على الرئيسية والوحدات والمراقبة والأدوات والإعدادات، بالإضافة إلى هذا المساعد المحلي."
            }

            if q.contains("مساعدة") ||
                q.contains("ساعدني") {
                return "يمكنك سؤالي عن البطارية أو الجهاز أو الشبكة أو وظائف التطبيق."
            }

            return "لم أتمكن من فهم طلبك. جرّب كتابة: مساعدة."
        }

        if q.contains("hello") || q.contains("hi") {
            return "Welcome to ALMASIH. I am your local assistant."
        }

        if q.contains("battery") {
            return "Open Monitor to view battery level and charging status."
        }

        if q.contains("device") || q.contains("information") {
            return "Open Monitor to view device information and iOS version."
        }

        if q.contains("network") || q.contains("internet") {
            return "The app can display network connectivity. iOS does not allow direct system-wide speed boosting."
        }

        if q.contains("features") || q.contains("app") {
            return "ALMASIH includes Home, Modules, Monitor, Tools, Settings and Local Assistant."
        }

        if q.contains("help") {
            return "Ask about battery, device information, network status or app features."
        }

        return "I could not understand that request. Type Help to see supported topics."
    }
}

private struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
