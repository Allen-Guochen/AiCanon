#!/usr/bin/env python3
"""
生成iOS应用图标脚本
需要安装: pip install Pillow
"""

from PIL import Image, ImageDraw
import os

def create_camera_icon(size, output_path):
    """创建相机图标"""
    # 创建图像
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 计算缩放比例
    scale = size / 1024
    
    # 背景圆角矩形
    bg_size = int(624 * scale)
    bg_x = (size - bg_size) // 2
    bg_y = int(300 * scale)
    bg_height = int(424 * scale)
    
    # 绘制背景
    draw.rounded_rectangle(
        [bg_x, bg_y, bg_x + bg_size, bg_y + bg_height],
        radius=int(40 * scale),
        fill=(30, 64, 175, 255)  # 深蓝色
    )
    
    # 相机主体
    body_margin = int(20 * scale)
    body_x = bg_x + body_margin
    body_y = bg_y + body_margin
    body_width = bg_size - 2 * body_margin
    body_height = bg_height - 2 * body_margin
    
    draw.rounded_rectangle(
        [body_x, body_y, body_x + body_width, body_y + body_height],
        radius=int(20 * scale),
        fill=(255, 255, 255, 255)  # 白色
    )
    
    # 镜头外环
    lens_center_x = size // 2
    lens_center_y = size // 2
    lens_outer_radius = int(120 * scale)
    lens_inner_radius = int(80 * scale)
    
    draw.ellipse(
        [lens_center_x - lens_outer_radius, lens_center_y - lens_outer_radius,
         lens_center_x + lens_outer_radius, lens_center_y + lens_outer_radius],
        fill=(55, 65, 81, 255)  # 深灰色
    )
    
    # 镜头内环
    draw.ellipse(
        [lens_center_x - lens_inner_radius, lens_center_y - lens_inner_radius,
         lens_center_x + lens_inner_radius, lens_center_y + lens_inner_radius],
        fill=(30, 64, 175, 255)  # 深蓝色
    )
    
    # 镜头高光
    highlight_radius = int(20 * scale)
    highlight_x = lens_center_x - int(32 * scale)
    highlight_y = lens_center_y - int(32 * scale)
    
    draw.ellipse(
        [highlight_x - highlight_radius, highlight_y - highlight_radius,
         highlight_x + highlight_radius, highlight_y + highlight_radius],
        fill=(96, 165, 250, 200)  # 亮蓝色，半透明
    )
    
    # 闪光灯
    flash_width = int(80 * scale)
    flash_height = int(60 * scale)
    flash_x = lens_center_x - int(162 * scale)
    flash_y = int(200 * scale)
    
    draw.rounded_rectangle(
        [flash_x, flash_y, flash_x + flash_width, flash_y + flash_height],
        radius=int(10 * scale),
        fill=(255, 255, 255, 255)
    )
    
    # 闪光灯光芒
    flash_center_x = flash_x + flash_width // 2
    flash_center_y = flash_y + flash_height // 2
    
    # 垂直光芒
    draw.rounded_rectangle(
        [flash_center_x - int(10 * scale), flash_y - int(50 * scale),
         flash_center_x + int(10 * scale), flash_y + flash_height + int(50 * scale)],
        radius=int(5 * scale),
        fill=(255, 255, 255, 230)
    )
    
    # 水平光芒
    draw.rounded_rectangle(
        [flash_x - int(30 * scale), flash_center_y - int(10 * scale),
         flash_x + flash_width + int(30 * scale), flash_center_y + int(10 * scale)],
        radius=int(5 * scale),
        fill=(255, 255, 255, 230)
    )
    
    # 顶部旋钮
    knob_width = int(40 * scale)
    knob_height = int(60 * scale)
    knob_x = lens_center_x - int(212 * scale)
    knob_y = int(200 * scale)
    
    draw.rounded_rectangle(
        [knob_x, knob_y, knob_x + knob_width, knob_y + knob_height],
        radius=int(20 * scale),
        fill=(255, 255, 255, 255)
    )
    
    # 快门按钮
    button_radius = int(15 * scale)
    button_x = lens_center_x + int(88 * scale)
    button_y = int(200 * scale)
    
    draw.ellipse(
        [button_x - button_radius, button_y - button_radius,
         button_x + button_radius, button_y + button_radius],
        fill=(55, 65, 81, 255)
    )
    
    # 保存图像
    img.save(output_path, 'PNG')
    print(f"生成图标: {output_path} ({size}x{size})")

def main():
    """主函数"""
    # 创建输出目录
    output_dir = "Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    
    # 定义需要的图标尺寸
    icon_sizes = [
        (40, "icon-20@2x.png"),
        (60, "icon-20@3x.png"),
        (58, "icon-29@2x.png"),
        (87, "icon-29@3x.png"),
        (80, "icon-40@2x.png"),
        (120, "icon-40@3x.png"),
        (120, "icon-60@2x.png"),
        (180, "icon-60@3x.png"),
        (1024, "icon-1024.png")
    ]
    
    # 生成所有尺寸的图标
    for size, filename in icon_sizes:
        output_path = os.path.join(output_dir, filename)
        create_camera_icon(size, output_path)
    
    print("\n所有图标生成完成！")
    print("请将生成的图标文件添加到Xcode项目的Assets.xcassets中。")

if __name__ == "__main__":
    main()
