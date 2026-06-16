import os

def update_podfile(path):
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'" not in content:
        injection_ios = """flutter_additional_ios_build_settings(target)
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end"""
        injection_macos = """flutter_additional_macos_build_settings(target)
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end"""
        content = content.replace('flutter_additional_ios_build_settings(target)', injection_ios)
        content = content.replace('flutter_additional_macos_build_settings(target)', injection_macos)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

update_podfile('app/ios/Podfile')
update_podfile('app/macos/Podfile')
print("Podfile updated")
