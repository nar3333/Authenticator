# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Authenticator' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	pod "OneTimePassword"

  # Pods for Authenticator

end

post_install do |installer|
  # Cocoapods optimization, always clean project after pod updating
  Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
    flag_name = File.basename(script, ".sh") + "-Installation-Flag"
    folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    file = File.join(folder, flag_name)
    content = File.read(script)

    # Add conditional check to avoid unnecessary touch operations
    content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ ! -f \"$KG_FILE\" ]; then\n  mkdir -p \"#{folder}\"\n  touch \"$KG_FILE\"\n  chmod 666 \"$KG_FILE\"\nfi")

    File.write(script, content)
  end

  # Enable tracing resources
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end

  # To hide deployment target warnings
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

#post_install do |installer|
#     #Cocoapods optimization, always clean project after pod updating
#    Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
#        flag_name = File.basename(script, ".sh") + "-Installation-Flag"
#        folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
#        file = File.join(folder, flag_name)
#        content = File.read(script)
#        content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
#        File.write(script, content)
#    end
#
#    # Enable tracing resources
#    installer.pods_project.targets.each do |target|
#      if target.name == 'RxSwift'
#        target.build_configurations.each do |config|
#          if config.name == 'Debug'
#            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
#          end
#        end
#      end
#    end
#
#    # To hide deployment target warnings
#    installer.pods_project.targets.each do |target|
#      target.build_configurations.each do |config|
#        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
#      end
#    end
#end
