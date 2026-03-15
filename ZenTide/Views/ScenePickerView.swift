import SwiftUI

/// 场景选择器
struct ScenePickerView: View {
    @Binding var selectedScene: SoundScene
    let onSelect: (SoundScene) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(SoundScene.allCases) { scene in
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        onSelect(scene)
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(scene.icon)
                            .font(.system(size: 28))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(selectedScene == scene
                                          ? scene.accentColor.opacity(0.2)
                                          : Color.white.opacity(0.06))
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedScene == scene
                                            ? scene.accentColor.opacity(0.5)
                                            : Color.clear, lineWidth: 1.5)
                            )
                        
                        Text(scene.displayName)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(selectedScene == scene
                                             ? scene.accentColor
                                             : .white.opacity(0.4))
                    }
                }
            }
        }
    }
}
