cask 'vulkan-sdk' do
  version '1.1.77.0'
  sha256 '229d4c1cb0bf30c43fe91c9118dcf0d453af197b7289f1be646503c26fdd41f6'

  url "https://sdk.lunarg.com/sdk/download/#{version}/mac/vulkansdk-macos-#{version}.tar.gz"
  name 'LunarG Vulkan SDK'
  homepage 'https://vulkan.lunarg.com/sdk/home'

  depends_on macos: '>= :el_capitan'

  # binary "#{staged_path}/macOS/bin/vulkaninfo"
  binaries_list = Dir.glob("#{staged_path}/macOS/bin/*")
  puts binaries_list

  binaries_list.each do |binary_filename|
    binary binary_filename
  end

  #global
  list = version.split(".")
  lib_version = list[0] + "." + list[1] + "." + list[2]

  libvulkan_dylibs = ["libvulkan.dylib",
                      "libvulkan.1.dylib",
                      "libvulkan.#{lib_version}.dylib"]

  all_dylibs = Dir.glob("#{staged_path}/macOS/lib/*.dylib")
  all_dylibs = all_dylibs.map{|x| File.basename(x)}
  other_dylibs = all_dylibs - libvulkan_dylibs


  # Move contents of redundant folder (that matches the name of the archive) up a folder
  # and then delete that folder.
  preflight do
    FileUtils.mv Dir.glob("#{staged_path}/vulkansdk-macos-#{version}/*"), staged_path.to_s
    FileUtils.remove_dir "#{staged_path}/vulkansdk-macos-#{version}"
  end

  postflight do
    #include
    #===============================================    
    FileUtils.mkdir("/usr/local/include/vulkan") unless Dir.exist?("/usr/local/include/vulkan")
    FileUtils.ln_sf Dir.glob("#{staged_path}/macOS/include/vulkan/*"), "/usr/local/include/vulkan"

    #dylib
    #===============================================
    FileUtils.ln_sf "#{staged_path}/macOS/lib/libvulkan.#{lib_version}.dylib", "/usr/local/lib"
    FileUtils.ln_sf "/usr/local/lib/libvulkan.#{lib_version}.dylib", "/usr/local/lib/libvulkan.1.dylib"
    FileUtils.ln_sf "/usr/local/lib/libvulkan.1.dylib", "/usr/local/lib/libvulkan.dylib"

    other_dylibs.each do |lib_filename|
        FileUtils.ln_sf "#{staged_path}/macOS/lib/#{lib_filename}", "/usr/local/lib"
    end
    
    #ICD
    #===============================================
    # FileUtils.mkdir_p "/etc/vulkan/icd.d"
    # FileUtils.ln_sf Dir.glob("#{staged_path}/macOS/etc/icd.d/*"), "/etc/vulkan/icd.d", sudo:true    

    system_command '/bin/mkdir', args: ['-p', "/etc/vulkan/icd.d"], sudo: true
    system_command '/bin/ln', args: ['-sf', "#{staged_path}/macOS/etc/vulkan/icd.d/MoltenVK_icd.json", "/etc/vulkan/icd.d"], sudo: true

    #patching the file path in the json file
    file = File.read("#{staged_path}/macOS/etc/vulkan/icd.d/MoltenVK_icd.json")
    
    data_hash = JSON.parse(file)
    data_hash["ICD"]["library_path"] = "#{staged_path}/macOS/lib/libvulkan.dylib"

    File.open("#{staged_path}/macOS/etc/vulkan/icd.d/MoltenVK_icd.json", "w") do |f|
        f.write( JSON.pretty_generate(data_hash) + "\n" )
    end

    # #layers
    #===============================================
    # FileUtils.mkdir_p "/etc/vulkan/explicit_layer.d", sudo:true
    # FileUtils.ln_sf Dir.glob("#{staged_path}/macOS/etc/vulkan/*"), "/etc/vulkan/explicit_layer.d", sudo:true    

    system_command '/bin/mkdir', args: ['-p', "/etc/vulkan/explicit_layer.d"], sudo: true
    explicit_layers = Dir.glob("#{staged_path}/macOS/etc/vulkan/explicit_layer.d/*")
    
    explicit_layers.each do |layer_filename|
        system_command '/bin/ln', args: ['-sf', layer_filename, "/etc/vulkan/explicit_layer.d"], sudo: true        

        #patching the file path in the json file
        file = File.read(layer_filename)
        
        data_hash = JSON.parse(file)
        data_hash["layer"]["library_path"] = "#{staged_path}/macOS/lib/libvulkan.dylib"
        #puts data_hash["layer"]["library_path"]

        File.open(layer_filename, "w") do |f|
            f.write( JSON.pretty_generate(data_hash) + "\n" )
        end

    end

    #Framework
    #===============================================
    system_command '/bin/cp', args: ['-r', "#{staged_path}/macOS/Frameworks/vulkan.framework", "/Library/Frameworks"], sudo: true
    

  end

  uninstall delete: ["/usr/local/include/vulkan"],

            delete: all_dylibs.map{|x| "/usr/local/lib/" + x},
            
            script: {
                     executable: "/bin/rm",
                     args: ['-rf', "/etc/vulkan"],
                     sudo: true
                    },

            script: {
                     executable: "/bin/rm",
                     args: ['-rf', "/Library/Frameworks/vulkan.framework"],
                     sudo: true
                    }

  caveats do
    license 'https://vulkan.lunarg.com/sdk/home#sdk-license'
  end

end
