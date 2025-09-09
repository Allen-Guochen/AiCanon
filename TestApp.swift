import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showingCamera = false
    @State private var showingResults = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 应用标题
                VStack(spacing: 10) {
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
                }
                .padding(.top, 50)
                
                Spacer()
                
                // 主要功能按钮
                Button(action: {
                    showingCamera = true
                    print("拍摄环境照片按钮被点击")
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("拍摄环境照片")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 底部说明
                Text("拍摄一张环境照片，AI将为您分析并推荐最佳相机参数")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(onImageCaptured: { image in
                capturedImage = image
                showingCamera = false
                showingResults = true
            })
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(originalImage: capturedImage)
        }
    }
}

struct CameraView: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("相机界面")
                .font(.title)
                .padding()
            
            Text("这里将实现相机功能")
                .foregroundColor(.secondary)
                .padding()
            
            Button("模拟拍摄") {
                // 模拟拍摄
                let image = UIImage(systemName: "photo") ?? UIImage()
                onImageCaptured(image)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("取消") {
                dismiss()
            }
            .padding()
        }
    }
}

struct ResultsView: View {
    let originalImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AI分析结果")
                .font(.title)
                .padding()
            
            if let image = originalImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(15)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("推荐参数：")
                    .font(.headline)
                
                Text("• 光圈: f/2.8")
                Text("• 快门: 1/125s")
                Text("• ISO: 400")
                Text("• 对焦: 单点对焦")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("完成") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}