import os
from PIL import Image

def generate_icons():
    source_path = 'assets/logo.webp'
    if not os.path.exists(source_path):
        print(f"Error: {source_path} not found")
        return

    base_img = Image.open(source_path).convert('RGBA')
    print(f"Loaded {source_path}: size={base_img.size}")

    # 1. Web icons
    web_targets = {
        'web/favicon.png': (64, 64),
        'web/icons/Icon-192.png': (192, 192),
        'web/icons/Icon-512.png': (512, 512),
        'web/icons/Icon-maskable-192.png': (192, 192),
        'web/icons/Icon-maskable-512.png': (512, 512),
    }

    for path, size in web_targets.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = base_img.resize(size, Image.Resampling.LANCZOS)
        resized.save(path, 'PNG')
        print(f"Generated {path} ({size[0]}x{size[1]})")

    # 2. Android icons
    android_targets = {
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': (48, 48),
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': (72, 72),
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': (96, 96),
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': (144, 144),
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': (192, 192),
    }

    for path, size in android_targets.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = base_img.resize(size, Image.Resampling.LANCZOS)
        resized.save(path, 'PNG')
        print(f"Generated {path} ({size[0]}x{size[1]})")

    # 3. iOS icons
    ios_targets = {
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': (20, 20),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': (40, 40),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': (60, 60),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': (29, 29),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': (58, 58),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': (87, 87),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': (40, 40),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': (80, 80),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': (120, 120),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': (120, 120),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': (180, 180),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': (76, 76),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': (152, 152),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': (167, 167),
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png': (1024, 1024),
    }

    for path, size in ios_targets.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = base_img.resize(size, Image.Resampling.LANCZOS)
        resized.save(path, 'PNG')
        print(f"Generated {path} ({size[0]}x{size[1]})")

    # 4. Windows ICO
    windows_ico_path = 'windows/runner/resources/app_icon.ico'
    if os.path.exists(os.path.dirname(windows_ico_path)):
        ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
        base_img.save(windows_ico_path, format='ICO', sizes=ico_sizes)
        print(f"Generated {windows_ico_path}")

    print("All app icons & favicon successfully created!")

if __name__ == '__main__':
    generate_icons()
