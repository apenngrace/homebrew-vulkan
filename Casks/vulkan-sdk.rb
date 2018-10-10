cask 'vulkan-sdk' do
  version '1.1.85.0'
  sha256 '3860127c7aaf2a4f429fb3a3a83cc259b621e308870f33ae95f73abcfbd8ab4d'

  url "https://sdk.lunarg.com/sdk/download/#{version}/mac/vulkansdk-macos-#{version}.tar.gz"
  name 'LunarG Vulkan SDK'
  homepage 'https://vulkan.lunarg.com/sdk/home'

  depends_on macos: '>= :el_capitan'

  #==============================

  VK_BIN      = "#{staged_path}/macOS/bin"
  VK_LIB      = "#{staged_path}/macOS/lib"
  VK_INCLUDE  = "#{staged_path}/macOS/include/vulkan"
  VK_ICD      = "#{staged_path}/macOS/etc/vulkan/icd.d"
  VK_LAYER    = "#{staged_path}/macOS/etc/vulkan/explicit_layer.d"

  DEST_BIN          = "/usr/local/bin"
  DEST_LIB          = "/usr/local/lib"
  DEST_INCLUDE      = "/usr/local/include/vulkan"
  DEST_ICD          = "/etc/vulkan/icd.d"
  DEST_LAYER        = "/etc/vulkan/explicit_layer.d"

  mylist = version.split(".")
  lib_version = mylist[0] + "." + mylist[1] + "." + mylist[2]

  #Vulkan Executable Binaries to Install
  #============================== 

  binary "#{VK_BIN}/glslangValidator"
  binary "#{VK_BIN}/glslc"
  binary "#{VK_BIN}/spirv-as"
  binary "#{VK_BIN}/spirv-cross"
  binary "#{VK_BIN}/spirv-dis"
  binary "#{VK_BIN}/spirv-lesspipe.sh"
  binary "#{VK_BIN}/spirv-link"
  binary "#{VK_BIN}/spirv-opt"
  binary "#{VK_BIN}/spirv-remap"
  binary "#{VK_BIN}/spirv-stats"
  binary "#{VK_BIN}/spirv-val"
  binary "#{VK_BIN}/vulkaninfo"

  #============================== 

  # Move contents of redundant folder (that matches the name of the archive) up a folder
  # and then delete that folder.
  preflight do
    FileUtils.mv Dir.glob("#{staged_path}/vulkansdk-macos-#{version}/*"), staged_path.to_s
    FileUtils.remove_dir "#{staged_path}/vulkansdk-macos-#{version}"
  end

  postflight do
    
    #VULKAN INCLUDE FILES
    #===============================================    
    FileUtils.mkdir("/usr/local/include/vulkan") unless Dir.exist?("/usr/local/include/vulkan")

    FileUtils.ln_sf "#{VK_INCLUDE}/vk_icd.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_layer.h",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_platform.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_sdk_platform.h",    DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.hpp",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_android.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_core.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_ios.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_macos.h",       DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_mir.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_vi.h",          DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_wayland.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_win32.h",       DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xcb.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xlib.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xlib_xrandr.h", DEST_INCLUDE


    #VULKAN DYLIB FILES
    #===============================================
    #Versioned libvulkan libraries
    FileUtils.ln_sf "#{VK_LIB}/libvulkan.#{lib_version}.dylib",     DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",   "#{DEST_LIB}/libvulkan.1.dylib"
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.1.dylib",                "#{DEST_LIB}/libvulkan.dylib"

    FileUtils.ln_sf "#{VK_LIB}/libMoltenVK.dylib",                      DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libSPIRV-Tools-shared.dylib",            DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_core_validation.dylib",       DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_object_tracker.dylib",        DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_parameter_validation.dylib",  DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_threading.dylib",             DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_unique_objects.dylib",        DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libshaderc_shared.dylib",                DEST_LIB
    
    #VULKAN ICD FOR MACOS
    #===============================================    
    system_command '/bin/mkdir', args: ['-p', DEST_ICD], sudo: true
    system_command '/bin/ln',    args: ['-sf', "#{VK_ICD}/MoltenVK_icd.json", DEST_ICD], sudo: true

    #The relative file path in this json file is invalid once these files are installed
    #in system directories.  So replace that path with an absolute path.
    file = File.read("#{VK_ICD}/MoltenVK_icd.json")
    
    data_hash = JSON.parse(file)
    data_hash["ICD"]["library_path"] = "#{DEST_LIB}/libvulkan.dylib"

    File.open("#{VK_ICD}/MoltenVK_icd.json", "w") do |f|
        f.write( JSON.pretty_generate(data_hash) + "\n" )
    end

    #VULKAN LAYERS FOR DEBUGGING
    #===============================================
    system_command '/bin/mkdir', args: ['-p', DEST_LAYER], sudo: true

    layers = [
              "#{VK_LAYER}/VkLayer_core_validation.json",
              "#{VK_LAYER}/VkLayer_object_tracker.json",
              "#{VK_LAYER}/VkLayer_parameter_validation.json",
              "#{VK_LAYER}/VkLayer_standard_validation.json",
              "#{VK_LAYER}/VkLayer_threading.json",
              "#{VK_LAYER}/VkLayer_unique_objects.json"
              ]
    
    layers.each do |layer_filename|
        system_command '/bin/ln', args: ['-sf', layer_filename, DEST_LAYER], sudo: true        

        #patching the file path in the json file
        file = File.read(layer_filename)
        
        data_hash = JSON.parse(file)
        data_hash["layer"]["library_path"] = "#{DEST_LIB}/libvulkan.dylib"

        File.open(layer_filename, "w") do |f|
            f.write( JSON.pretty_generate(data_hash) + "\n" )
        end

    end

    # #Framework
    # #===============================================
    # system_command '/bin/cp', args: ['-r', "#{staged_path}/macOS/Frameworks/vulkan.framework", "/Library/Frameworks"], sudo: true
    

  end

  uninstall script: {
                     executable: "/bin/rm",
                     args: ['-rf', DEST_INCLUDE],
                     sudo: true
                    },

            delete: [
                      "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",
                      "#{DEST_LIB}/libvulkan.1.dylib",
                      "#{DEST_LIB}/libvulkan.dylib",

                      "#{DEST_LIB}/libMoltenVK.dylib",                      
                      "#{DEST_LIB}/libSPIRV-Tools-shared.dylib",            
                      "#{DEST_LIB}/libVkLayer_core_validation.dylib",       
                      "#{DEST_LIB}/libVkLayer_object_tracker.dylib",        
                      "#{DEST_LIB}/libVkLayer_parameter_validation.dylib",  
                      "#{DEST_LIB}/libVkLayer_threading.dylib",             
                      "#{DEST_LIB}/libVkLayer_unique_objects.dylib",        
                      "#{DEST_LIB}/libshaderc_shared.dylib",                
                    ],
            
            #Deletes both ICDs & Explicit Layers
            script: {
                     executable: "/bin/rm",
                     args: ['-rf', "/etc/vulkan"],
                     sudo: true
                    }

            # script: {
            #          executable: "/bin/rm",
            #          args: ['-rf', "/Library/Frameworks/vulkan.framework"],
            #          sudo: true
            #         }

  caveats do
    license 'https://vulkan.lunarg.com/sdk/home#sdk-license'
  end

end
