import os
from PIL import Image

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Go up one level to project root
    project_root = os.path.dirname(script_dir)
    
    png_path = os.path.join(project_root, "app", "assets", "img", "app_icon.png")
    logo_ico_path = os.path.join(project_root, "app", "assets", "packaging", "logo.ico")
    app_icon_ico_path = os.path.join(project_root, "app", "windows", "runner", "resources", "app_icon.ico")
    
    if not os.path.exists(png_path):
        print(f"Error: app_icon.png not found at {png_path}")
        return

    print(f"Loading {png_path}...")
    img = Image.open(png_path)
    
    # Standard sizes to bundle inside Windows ICO format
    sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    
    print(f"Generating logo.ico at {logo_ico_path}...")
    # Ensure packaging directory exists
    os.makedirs(os.path.dirname(logo_ico_path), exist_ok=True)
    img.save(logo_ico_path, format="ICO", sizes=sizes)
    
    print(f"Generating app_icon.ico at {app_icon_ico_path}...")
    # Ensure resources directory exists
    os.makedirs(os.path.dirname(app_icon_ico_path), exist_ok=True)
    img.save(app_icon_ico_path, format="ICO", sizes=sizes)
    
    print("Icons generated successfully!")

if __name__ == "__main__":
    main()
