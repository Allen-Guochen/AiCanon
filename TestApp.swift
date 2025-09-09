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

// MARK: - 分析状态枚举
enum AnalysisStep: String, CaseIterable {
    case analyzingSubject = "分析主体"
    case analyzingLight = "分析光线"
    case analyzingColor = "分析色彩"
    case analyzingComposition = "分析空间"
    case completed = "分析完成"
}

// MARK: - AI分析加载界面
struct AnalysisLoadingView: View {
    let originalImage: UIImage?
    @State private var currentStep: AnalysisStep = .analyzingSubject
    @State private var progress: Double = 0.0
    @State private var showResults = false
    @State private var isAnalyzing = true
    @Environment(\.dismiss) private var dismiss
    
    private let analysisSteps: [AnalysisStep] = [.analyzingSubject, .analyzingLight, .analyzingColor, .analyzingComposition]
    
    var body: some View {
        ZStack {
            // 主内容区域
            VStack(spacing: 30) {
                if showResults {
                    AnalysisResultsView(originalImage: originalImage)
                } else {
                    // 加载界面
                    VStack(spacing: 40) {
                        // 图片预览
                        if let image = originalImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(15)
                                .opacity(0.8)
                        }
                        
                        // AI分析动画
                        VStack(spacing: 20) {
                            // 分析图标动画
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.5), value: progress)
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.1)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: currentStep)
                            }
                            
                            // 当前分析步骤
                            VStack(spacing: 15) {
                                Text("AI正在分析中...")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                // 当前分析步骤文本
                                Text(getCurrentStepText())
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .scaleEffect(1.1)
                                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                
                                // 进度百分比
                                Text("\(Int(progress * 100))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 分析步骤指示器
                        HStack(spacing: 25) {
                            ForEach(analysisSteps, id: \.self) { step in
                                Circle()
                                    .fill(step == currentStep ? Color.blue : 
                                          (analysisSteps.firstIndex(of: step)! < analysisSteps.firstIndex(of: currentStep)! ? Color.green : Color.gray.opacity(0.3)))
                                    .frame(width: 20, height: 20)
                                    .scaleEffect(step == currentStep ? 1.4 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                        
                        // 底部取消按钮
                        Button(action: {
                            cancelAnalysis()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                Text("取消分析")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(25)
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .opacity(isAnalyzing ? 1.0 : 0.0)
                        .scaleEffect(isAnalyzing ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
                        .padding(.top, 20)
                    }
                }
            }
            
            // 右上角X图标
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        cancelAnalysis()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .opacity(isAnalyzing ? 1.0 : 0.0)
                    .scaleEffect(isAnalyzing ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            startAnalysis()
        }
    }
    
    private func startAnalysis() {
        // 开始AI分析
        isAnalyzing = true
        performAIAnalysis()
    }
    
    private func cancelAnalysis() {
        // 取消分析，直接返回到主页
        isAnalyzing = false
        withAnimation(.easeInOut(duration: 0.3)) {
            dismiss()
        }
    }
    
    private func performAIAnalysis() {
        // 模拟AI分析过程
        let stepDurations: [AnalysisStep: TimeInterval] = [
            .analyzingSubject: 1.5,    // 分析主体：1.5秒
            .analyzingLight: 1.2,      // 分析光线：1.2秒
            .analyzingColor: 1.0,      // 分析色彩：1.0秒
            .analyzingComposition: 1.3  // 分析空间：1.3秒
        ]
        
        var cumulativeTime: TimeInterval = 0
        
        for (index, step) in analysisSteps.enumerated() {
            let duration = stepDurations[step] ?? 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime) {
                guard isAnalyzing else { return } // 检查是否已取消
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = step
                    progress = Double(index + 1) / Double(analysisSteps.count)
                }
            }
            
            cumulativeTime += duration
        }
        
        // 分析完成
        DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime) {
            guard isAnalyzing else { return } // 检查是否已取消
            
            withAnimation(.easeInOut(duration: 0.5)) {
                currentStep = .completed
                progress = 1.0
            }
            
            // 显示结果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard isAnalyzing else { return } // 检查是否已取消
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    isAnalyzing = false
                    showResults = true
                }
            }
        }
    }
    
    private func getCurrentStepText() -> String {
        switch currentStep {
        case .analyzingSubject:
            return "分析主体"
        case .analyzingLight:
            return "分析光线"
        case .analyzingColor:
            return "分析色彩"
        case .analyzingComposition:
            return "分析空间"
        case .completed:
            return "分析完成"
        }
    }
}

// MARK: - 分析结果展示界面
struct AnalysisResultsView: View {
    let originalImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 标题
                Text("AI分析结果")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 拍摄的图片
                if let image = originalImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                // 分析结果卡片
                VStack(spacing: 20) {
                    // 分析信息
                    VStack(alignment: .leading, spacing: 15) {
                        Text("分析详情")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        AnalysisInfoRow(title: "拍摄主体", value: "风景摄影", icon: "target")
                        AnalysisInfoRow(title: "光线条件", value: "自然光，光线充足", icon: "sun.max")
                        AnalysisInfoRow(title: "色彩色调", value: "暖色调，色彩饱和度高", icon: "paintpalette")
                        AnalysisInfoRow(title: "构图元素", value: "三分法构图，层次分明", icon: "camera.depth.of.field")
                        AnalysisInfoRow(title: "分析置信度", value: "87%", icon: "checkmark.circle")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    
                    // 推荐参数
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推荐相机参数")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 10) {
                            ParameterRow(parameter: "光圈", value: "f/8.0")
                            ParameterRow(parameter: "快门速度", value: "1/250s")
                            ParameterRow(parameter: "ISO", value: "200")
                            ParameterRow(parameter: "对焦模式", value: "单点对焦")
                            ParameterRow(parameter: "测光模式", value: "矩阵测光")
                            ParameterRow(parameter: "白平衡", value: "自动")
                        }
                        
                        Divider()
                        
                        Text("拍摄建议")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("根据AI分析，这是一个风景场景，建议使用小光圈获得深景深，配合较快的快门速度确保画面清晰。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                
                // 完成按钮
                Button(action: {
                    dismiss()
                }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - 分析信息行组件
struct AnalysisInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 参数行组件
struct ParameterRow: View {
    let parameter: String
    let value: String
    
    var body: some View {
        HStack {
            Text(parameter)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 2)
    }
}

struct ResultsView: View {
    let originalImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        AnalysisLoadingView(originalImage: originalImage)
    }
}

#Preview {
    ContentView()
}