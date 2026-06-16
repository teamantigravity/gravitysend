import os
import re

for file_path in ['app/macos/Runner.xcodeproj/project.pbxproj', 'app/ios/Runner.xcodeproj/project.pbxproj']:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove DEVELOPMENT_TEAM
    content = re.sub(r'DEVELOPMENT_TEAM\s*=\s*[A-Z0-9]+;', 'DEVELOPMENT_TEAM = "";', content)
    
    # Change CODE_SIGN_IDENTITY to ad-hoc ("-")
    content = re.sub(r'CODE_SIGN_IDENTITY\s*=\s*"[^"]+";', 'CODE_SIGN_IDENTITY = "-";', content)
    content = re.sub(r'CODE_SIGN_STYLE\s*=\s*Automatic;', 'CODE_SIGN_STYLE = Manual;', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
print("Done")
