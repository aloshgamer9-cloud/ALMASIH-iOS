
import SwiftUI

struct ToolsView: View {
    private let tools = [
        ("فحص الاتصال", "wifi"),
        ("معلومات الجهاز", "iphone"),
        ("مساحة التخزين", "internaldrive"),
        ("إدارة البطارية", "battery.100"),
        ("إعدادات النظام", "gearshape")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("TOOLS")
                        .font(.largeTitle.bold())
                        .tracking(3)
                        .foregroundStyle(.white)

                    Text("مركز أدوات ALMASIH")
                        .foregroundStyle(.gray)

                    ForEach(tools, id: \.0) { tool in
                        HStack(spacing: 15) {
                            Image(systemName: tool.1)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            Text(tool.0)
                                .foregroundStyle(.white)
                                .font(.headline)

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
        .preferredColorScheme(.dark)
    }
}
