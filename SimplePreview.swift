import SwiftUI

struct SimplePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("智能摄影助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("AI分析环境，推荐最佳拍摄参数")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("拍摄环境照片") {
                print("拍摄按钮被点击")
            }
            .font(.title2)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(15)
        }
        .padding()
    }
}

#Preview {
    SimplePreview()
}
