from PIL import Image
import os

sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}

img = Image.open('app/assets/img/quicktile.png')
for folder, size in sizes.items():
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    path = f'app/android/app/src/main/res/mipmap-{folder}/ic_launcher_quicktile_foreground.png'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    resized.save(path)
    print(f'Saved {path}')
