
import SwiftUI
import UIKit

struct AssistantView: View {
    @AppStorage("appLanguage") private var appLanguage = "ar"
    @State private var message = ""
    @State private var messages: [(id: UUID, text: String, isUser: Bool)] = []

    private var isArabic: Bool {
        appLanguage == "ar"
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.white)

                VStack(alignment: .leading) {
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

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty {
                        Text(isArabic
                             ? "مرحباً بك في مساعد ALMASIH. كيف أستطيع مساعدتك؟"
                             : "Welcome to ALMASIH Assistant. How can I help?")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        suggestion(
                            isArabic ? "ما وظائف التطبيق؟" : "What can this app do?"
                        )
                        suggestion(
                            isArabic ? "معلومات الجهاز" : "Device information"
                        )
                        suggestion(
                            isArabic ? "المساعدة" : "Help"
                        )
                    }

                    ForEach(messages, id: \.id) { item in
                        HStack {
                            if item.isUser { Spacer() }

                            Text(item.text)
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(
                                    item.isUser
                                    ? Color.white.opacity(0.18)
                                    : Color.white.opacity(0.07)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .frame(maxWidth: 290, alignment: item.isUser ? .trailing : .leading)

                            if !item.isUser { Spacer() }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            HStack(spacing: 10) {
                TextField(
                    isArabic ? "اكتب رسالتك..." : "Type your message...",
                    text: $message
                )
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .padding(13)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .clipShape(Circle())
                }
                .accessibilityIdentifier("assistant_send")
            }
        }
        .padding()
        .background(Color.black)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
    }

    private func suggestion(_ title: String) -> some View {
        Button {
            message = title
            sendMessage()
        } label: {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func sendMessage() {
        let question = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        messages.append((UUID(), question, true))
        message = ""

        let answer = localAnswer(for: question)
        messages.append((UUID(), answer, false))
    }

    private func localAnswer(for question: String) -> String {
        let q = question.lowercased()

        if isArabic {
            if q.contains("مرحبا") || q.contains("هلا") || q.contains("السلام") {
                return "أهلاً بك. أنا مساعد ALMASIH المحلي، جاهز لمساعدتك."
            }

            if q.contains("وظائف") || q.contains("التطبيق") || q.contains("تقدر") {
                return "يوفر ALMASIH الرئيسية، الوحدات، مراقبة معلومات الجهاز، الأدوات والإعدادات."
            }

            if q.contains("جهاز") || q.contains("معلومات") {
                return "يمكنك مشاهدة مستوى البطارية وحالة الشحن وطراز الجهاز وإصدار iOS من تبويب المراقبة."
            }

            if q.contains("شبكة") || q.contains("انترنت") || q.contains("اتصال") {
                return "يمكنك متابعة حالة الاتصال من الرئيسية. التطبيق يستطيع رصد الاتصال، لكنه لا يغيّر إعدادات الشبكة أو يضمن زيادة السرعة."
            }

            if q.contains("بطارية") {
                return "افتح تبويب المراقبة لمشاهدة مستوى البطارية وحالة الشحن."
            }

            if q.contains("مساعدة") || q.contains("ساعدني") {
                return "اسألني عن وظائف ALMASIH أو معلومات الجهاز أو الشبكة أو طريقة استخدام الأدوات."
            }

            return "أفهم سؤالك، لكن معرفتي حالياً محدودة بالأوامر المحلية المبرمجة. جرّب كتابة: المساعدة."
        }

        if q.contains("hello") || q.contains("hi") {
            return "Hello! I am the ALMASIH local assistant."
        }

        if q.contains("features") || q.contains("app") {
            return "ALMASIH includes Home, Modules, Monitor, Tools and Settings."
        }

        if q.contains("device") || q.contains("battery") {
            return "Open Monitor to view battery level, charging state, device model and iOS version."
        }

        if q.contains("network") || q.contains("internet") {
            return "Home displays network connectivity. iOS does not allow this app to directly boost system network speed."
        }

        if q.contains("help") {
            return "Ask about app features, device information, battery, network status or tools."
        }

        return "I can answer a limited set of built-in questions. Type Help to see supported topics."
    }
}
