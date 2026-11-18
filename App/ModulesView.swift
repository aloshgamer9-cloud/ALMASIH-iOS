
import SwiftUI

struct ModulesView: View {
    private let modules = [
        ("مراقبة النظام", "cpu", "متابعة معلومات الجهاز"),
        ("مراقبة الشبكة", "wifi", "عرض حالة الاتصال"),
        ("تحليل التطبيقات", "app.badge", "معلومات التطبيقات"),
        ("أدوات النظام", "gearshape.2", "أدوات مساعدة"),
        ("مركز الأمان", "shield.lefthalf.filled", "إعدادات الحماية")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("MODULES")
                            .font(.largeTitle.bold())
                            .tracking(3)
                            .foregroundStyle(.white)

                        Text("وحدات منصة المسيح")
                            .foregroundStyle(.gray)

                        ForEach(modules, id: \.0) { item in
                            HStack(spacing: 16) {
                                Image(systemName: item.1)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.0)
                                        .foregroundStyle(.white)
                                        .font(.headline)

                                    Text(item.2)
                                        .foregroundStyle(.gray)
                                        .font(.caption)
                                }

                                Spacer()

                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
