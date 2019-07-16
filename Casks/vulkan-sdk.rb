cask 'vulkan-sdk' do
  version '1.1.108.0'
  sha256 'f493b0e9abc73e80a29fa24ef9bae3c2311513df973ade6ffc56008c30eaf60d'

  url "https://sdk.lunarg.com/sdk/download/#{version}/mac/vulkansdk-macos-#{version}.tar.gz?Human=true"
  name 'LunarG Vulkan SDK'
  homepage 'https://vulkan.lunarg.com/sdk/home'

  depends_on macos: '>= :el_capitan'

  #==============================

  VK_BIN      = "#{staged_path}/macOS/bin"
  VK_LIB      = "#{staged_path}/macOS/lib"
  VK_INCLUDE  = "#{staged_path}/macOS/include/vulkan"
  MVK_INCLUDE = "#{staged_path}/MoltenVK/include/MoltenVK"
  PORT_INCLUDE = "#{staged_path}/MoltenVK/include/vulkan-portability"
  VK_ICD      = "#{staged_path}/macOS/etc/vulkan/icd.d"
  VK_LAYER    = "#{staged_path}/macOS/etc/vulkan/explicit_layer.d"

  DEST_BIN          = "/usr/local/bin"
  DEST_LIB          = "/usr/local/lib"
  DEST_INCLUDE      = "/usr/local/include/vulkan"
  DEST_INCLUDE_MVK  = "/usr/local/include/MoltenVK"
  DEST_INCLUDE_PORT  = "/usr/local/include/vulkan-portability"
  DEST_ICD          = "/usr/local/share/vulkan/icd.d"
  DEST_LAYER        = "/usr/local/share/vulkan/explicit_layer.d"
  
  mylist = version.split(".")
  lib_version = mylist[0] + "." + mylist[1] + "." + mylist[2]

  #Vulkan Executable Binaries to Install
  #============================== 

  binary "#{VK_BIN}/glslangValidator"
  binary "#{VK_BIN}/glslc"
  binary "#{VK_BIN}/spirv-as"
  binary "#{VK_BIN}/spirv-cfg"
  binary "#{VK_BIN}/spirv-cross"
  binary "#{VK_BIN}/spirv-dis"
  binary "#{VK_BIN}/spirv-lesspipe.sh"
  binary "#{VK_BIN}/spirv-link"
  binary "#{VK_BIN}/spirv-opt"
  binary "#{VK_BIN}/spirv-reduce"
  binary "#{VK_BIN}/spirv-remap"
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
    FileUtils.mkdir_p(DEST_INCLUDE) unless Dir.exist?(DEST_INCLUDE)

    FileUtils.ln_sf "#{VK_INCLUDE}/vk_icd.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_layer.h",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_platform.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_sdk_platform.h",    DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.hpp",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_android.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_core.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_fuchsia.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_ggp.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_ios.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_macos.h",       DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_metal.h",       DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_vi.h",          DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_wayland.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_win32.h",       DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xcb.h",         DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xlib.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_xlib_xrandr.h", DEST_INCLUDE

    FileUtils.mkdir_p(DEST_INCLUDE_MVK) unless Dir.exist?(DEST_INCLUDE_MVK)

    FileUtils.ln_sf "#{MVK_INCLUDE}/mvk_vulkan.h",        DEST_INCLUDE_MVK
    FileUtils.ln_sf "#{MVK_INCLUDE}/mvk_datatypes.h",     DEST_INCLUDE_MVK
    FileUtils.ln_sf "#{MVK_INCLUDE}/vk_mvk_moltenvk.h",   DEST_INCLUDE_MVK

    FileUtils.mkdir_p(DEST_INCLUDE_PORT) unless Dir.exist?(DEST_INCLUDE_PORT)

    FileUtils.ln_sf "#{PORT_INCLUDE}/vk_extx_portability_subset.h",   DEST_INCLUDE_PORT


    #VULKAN DYLIB FILES
    #===============================================
    #Versioned libvulkan libraries
    FileUtils.ln_sf "#{VK_LIB}/libvulkan.#{lib_version}.dylib",     DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",   "#{DEST_LIB}/libvulkan.1.dylib"
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.1.dylib",                "#{DEST_LIB}/libvulkan.dylib"
    
    FileUtils.ln_sf "#{VK_LIB}/libshaderc_shared.1.dylib",          "#{DEST_LIB}/libshaderc_shared.1.dylib"
    FileUtils.ln_sf "#{DEST_LIB}/libshaderc_shared.1.dylib",        "#{DEST_LIB}/libshaderc_shared.dylib"
    
    FileUtils.ln_sf "#{VK_LIB}/libMoltenVK.dylib",                      DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libSPIRV-Tools-shared.dylib",            DEST_LIB
    
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_api_dump.dylib",              DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_core_validation.dylib",       DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_khronos_validation.dylib",    DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_object_lifetimes.dylib",      DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_stateless_validation.dylib",  DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_thread_safety.dylib",         DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_unique_objects.dylib",        DEST_LIB

    
    
    #VULKAN ICD FOR MACOS
    #===============================================    
    FileUtils.mkdir_p(DEST_ICD) unless Dir.exist?(DEST_ICD)
    FileUtils.ln_sf "#{VK_ICD}/MoltenVK_icd.json", DEST_ICD

    #The relative file path in this json file is invalid once these files are installed
    #in system directories.  So replace that path with an absolute path.
    file = File.read("#{VK_ICD}/MoltenVK_icd.json")
    
    data_hash = JSON.parse(file)
    data_hash["ICD"]["library_path"] = "#{DEST_LIB}/libMoltenVK.dylib"

    File.open("#{VK_ICD}/MoltenVK_icd.json", "w") do |f|
        f.write( JSON.pretty_generate(data_hash) + "\n" )
    end

    #VULKAN LAYERS FOR DEBUGGING
    #===============================================
    FileUtils.mkdir_p(DEST_LAYER) unless Dir.exist?(DEST_LAYER)

    layers = [
              "VkLayer_api_dump",
              "VkLayer_core_validation",
              "VkLayer_khronos_validation",
              "VkLayer_object_lifetimes",
              "VkLayer_standard_validation",
              "VkLayer_stateless_validation",
              "VkLayer_thread_safety",
              "VkLayer_unique_objects"
              ]
    
    layers.each do |layer|
        layer_filename = "#{VK_LAYER}/#{layer}.json"
        FileUtils.ln_sf layer_filename, DEST_LAYER
        
        unless layer == "VkLayer_standard_validation"
          #fix the file path in the json file
          file = File.read(layer_filename)
          
          data_hash = JSON.parse(file)
          layer_lib_filename = "lib#{layer}.dylib"
          data_hash["layer"]["library_path"] = "#{DEST_LIB}/#{layer_lib_filename}"

          File.open(layer_filename, "w") do |f|
              f.write( JSON.pretty_generate(data_hash) + "\n" )
          end
        end

    end
  end

  uninstall delete: DEST_INCLUDE

  uninstall delete: [
                      "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",
                      "#{DEST_LIB}/libvulkan.1.dylib",
                      "#{DEST_LIB}/libvulkan.dylib",
    
                      "#{DEST_LIB}/libshaderc_shared.1.dylib",
                      "#{DEST_LIB}/libshaderc_shared.dylib",
    
                      "#{DEST_LIB}/libMoltenVK.dylib",
                      "#{DEST_LIB}/libSPIRV-Tools-shared.dylib",
    
                      "#{DEST_LIB}/libVkLayer_api_dump.dylib",
                      "#{DEST_LIB}/libVkLayer_core_validation.dylib",
                      "#{DEST_LIB}/libVkLayer_khronos_validation.dylib",
                      "#{DEST_LIB}/libVkLayer_object_lifetimes.dylib",
                      "#{DEST_LIB}/libVkLayer_stateless_validation.dylib",
                      "#{DEST_LIB}/libVkLayer_thread_safety.dylib",
                      "#{DEST_LIB}/libVkLayer_unique_objects.dylib"
                    ]

  uninstall delete: '/usr/local/share/vulkan'

  caveats do
    license 'https://vulkan.lunarg.com/sdk/home#sdk-license'
  end

end
