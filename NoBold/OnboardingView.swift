import SwiftUI

struct OnboardingView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 44)

            Image(systemName: "bold")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)

            Spacer()
                .frame(height: 20)

            Text("NoBold")
                .font(.system(size: 26, weight: .bold, design: .monospaced))

            Spacer()
                .frame(height: 6)

            Text("Strips bold formatting from your clipboard.")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 32)

            VStack(alignment: .leading, spacing: 18) {
                featureRow(
                    icon: "doc.on.clipboard",
                    title: "Watches your clipboard",
                    detail: "Monitors copies from any app and strips bold in real time."
                )

                featureRow(
                    icon: "textformat",
                    title: "RTF, HTML, and Markdown",
                    detail: "Handles bold from rich text, web content, and markdown markers."
                )

                featureRow(
                    icon: "menubar.rectangle",
                    title: "Lives in your menu bar",
                    detail: "Look for the B icon in the menu bar to control NoBold."
                )
            }
            .padding(.horizontal, 8)

            Spacer()
                .frame(height: 36)

            Button(action: onDismiss) {
                Text("Get Started")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.primary)

            Spacer()
                .frame(height: 10)

            Text("NoBold is running. Control it from the menu bar.")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 28)
        }
        .padding(.horizontal, 36)
        .frame(width: 400, height: 480)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                Text(detail)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
