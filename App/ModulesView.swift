
import SwiftUI
import UIKit
import Network

private struct ALMASIHModule: Identifiable {
    let title: String
    let icon: String
    let subtitle: String

    var id: String { title }
}

struct ModulesView: View {
    @State private var selectedModule: ALMASIHModule?

    private let modules = [
        ALMASIHModule(
            title: "مراقبة النظام",
            icon: "cpu",
            subtitle: "معلومات الجهاز والبطارية"
        ),
        ALMASIHModule(
            title: "مراقبة الشبكة",
            icon: "wifi",
            subtitle: "حالة اتصال الإنترنت"
        ),
        ALMASIHModule(
            title: "تحليل التطبيقات",
            icon: "app.badge",
            subtitle: "معلومات التطبيقات"
        ),
        ALMASIHModule(
            title: "أدوات النظام",
            icon: "gearshape.2",
            subtitle: "فتح إعدادات التطبيق"
        ),
        ALMASIHModule(
            title: "مركز الأمان",
            icon: "shield.lefthalf.filled",
            subtitle: "إرشادات حماية الجهاز"
        )
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

                        ForEach(modules) { item in
                            Button {
                                selectedModule = item
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: item.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.title)
                                            .foregroundStyle(.white)
                                            .font(.headline)

                                        Text(item.subtitle)
                                            .foregroundStyle(.gray)
                                            .font(.caption)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.left")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.06))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedModule) { module in
                moduleDetails(module)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func moduleDetails(_ module: ALMASIHModule) -> some View {
        NavigationStack {
            VStack(spacing: 18) {
                switch module.title {

                case "مراقبة النظام":
                    info("نوع الجهاز", UIDevice.current.model)
                    info("إصدار iOS", UIDevice.current.systemVersion)
                    info("النظام", UIDevice.current.systemName)

                case "مراقبة الشبكة":
                    NetworkModuleView()

                case "تحليل التطبيقات":
                    Image(systemName: "app.badge")
                        .font(.system(size: 45))

                    Text("معلومات التطبيقات")
                        .font(.title2.bold())

                    Text(
                        "يفرض iOS قيوداً على قراءة بيانات التطبيقات الأخرى وإدارتها."
                    )
                    .foregroundStyle(.gray)

                case "أدوات النظام":
                    Image(systemName: "gearshape.2")
                        .font(.system(size: 45))

                    Text("إعدادات التطبيق")
                        .font(.title2.bold())

                    Button("فتح إعدادات ALMASIH") {
                        if let url = URL(
                            string: UIApplication.openSettingsURLString
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundStyle(.white)

                case "مركز الأمان":
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 45))

                    Text("إرشادات حماية الجهاز")
                        .font(.title2.bold())

                    info("التحديثات", "حافظ على تحديث iOS")
                    info("الخصوصية", "راجع أذونات التطبيقات")
                    info("الحسابات", "استخدم كلمات مرور قوية")

                default:
                    Text("الوحدة غير متاحة")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundStyle(.white)
            .navigationTitle(module.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("إغلاق") {
                        selectedModule = nil
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func info(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct NetworkModuleView: View {
    @State private var status = "جاري الفحص..."
    @State private var connectionType = "غير معروف"
    @State private var monitor: NWPathMonitor?

    private let queue = DispatchQueue(
        label: "ALMASIH.ModulesNetwork"
    )

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi")
                .font(.system(size: 45))

            Text(status)
                .font(.title2.bold())

            Text("نوع الاتصال: \(connectionType)")
                .foregroundStyle(.gray)

            Text(
                "هذا الفحص يعرض حالة اتصال الشبكة، ولا يقيس سرعة الإنترنت."
            )
            .font(.caption)
            .foregroundStyle(.gray)
        }
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        stopMonitoring()

        let newMonitor = NWPathMonitor()
        monitor = newMonitor

        newMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                status = path.status == .satisfied
                    ? "الشبكة متصلة"
                    : "لا يوجد اتصال"

                if path.usesInterfaceType(.wifi) {
                    connectionType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    connectionType = "بيانات الهاتف"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    connectionType = "Ethernet"
                } else {
                    connectionType = "غير معروف"
                }
            }
        }

        newMonitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}
