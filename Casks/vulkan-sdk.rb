cask 'vulkan-sdk' do
  version '1.2.162.1'
  sha256 '2781c334997598c2828d8a3368aef7b7c94a25204c90d5503396e40c7a03fd5c'

  url "https://sdk.lunarg.com/sdk/download/#{version}/mac/vulkansdk-macos-#{version}.dmg?Human=true"
  name 'LunarG Vulkan SDK'
  homepage 'https://vulkan.lunarg.com/sdk/home'

  depends_on macos: '>= :el_capitan'
  
  # ==============================

  VK_BIN          = "#{staged_path}/macOS/bin"
  VK_LIB          = "#{staged_path}/macOS/lib"
  VK_INCLUDE      = "#{staged_path}/macOS/include/vulkan"
  MVK_INCLUDE     = "#{staged_path}/MoltenVK/include/MoltenVK"
  PORT_INCLUDE    = "#{staged_path}/MoltenVK/include/vulkan-portability"
  SHADERC_INCLUDE = "#{staged_path}/macOS/include/shaderc"
  VK_SHARE_ICD             = "#{staged_path}/macOS/share/vulkan/icd.d"
  VK_SHARE_LAYER           = "#{staged_path}/macOS/share/vulkan/explicit_layer.d"
  VK_SHARE_CONFIG          = "#{staged_path}/macOS/share/vulkan/config/VK_LAYER_LUNARG_device_simulation"
  VK_SHARE_REGISTRY        = "#{staged_path}/macOS/share/vulkan/registry"

  DEST_BIN             = "/usr/local/bin"
  DEST_LIB             = "/usr/local/lib"
  DEST_INCLUDE         = "/usr/local/include/vulkan"
  DEST_INCLUDE_MVK     = "/usr/local/include/MoltenVK"
  DEST_INCLUDE_PORT    = "/usr/local/include/vulkan-portability"
  DEST_INCLUDE_SHADERC = "/usr/local/include/shaderc"
  DEST_SHARE_ICD             = "/usr/local/share/vulkan/icd.d"
  DEST_SHARE_LAYER           = "/usr/local/share/vulkan/explicit_layer.d"
  DEST_SHARE_CONFIG          = "/usr/local/share/vulkan/config/VK_LAYER_LUNARG_device_simulation"
  DEST_SHARE_REGISTRY        = "/usr/local/share/vulkan/registry"

  mylist = version.split(".")
  lib_version = mylist[0] + "." + mylist[1] + "." + mylist[2]

  #Vulkan Executable Binaries to Install
  #==============================

  binary "#{VK_BIN}/dxc"
  binary "#{VK_BIN}/dxc-3.7"
  binary "#{VK_BIN}/glslangValidator"
  binary "#{VK_BIN}/glslc"
  binary "#{VK_BIN}/MoltenVKShaderConverter"
  binary "#{VK_BIN}/spirv-as"
  binary "#{VK_BIN}/spirv-cfg"
  binary "#{VK_BIN}/spirv-cross"
  binary "#{VK_BIN}/spirv-dis"
  binary "#{VK_BIN}/spirv-lesspipe.sh"
  binary "#{VK_BIN}/spirv-link"
  binary "#{VK_BIN}/spirv-opt"
  binary "#{VK_BIN}/spirv-reduce"
  binary "#{VK_BIN}/spirv-reflect"
  binary "#{VK_BIN}/spirv-remap"
  binary "#{VK_BIN}/spirv-val"
  binary "#{VK_BIN}/vkvia"
  binary "#{VK_BIN}/vulkaninfo"

  #==============================

  postflight do

    #VULKAN INCLUDE FILES
    #===============================================
    FileUtils.mkdir_p(DEST_INCLUDE) unless Dir.exist?(DEST_INCLUDE)

    FileUtils.ln_sf "#{VK_INCLUDE}/vk_enum_string_helper.h", DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_icd.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_layer.h",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_platform.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vk_sdk_platform.h",    DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.h",             DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan.hpp",           DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_android.h",     DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_beta.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_core.h",        DEST_INCLUDE
    FileUtils.ln_sf "#{VK_INCLUDE}/vulkan_directfb.h",    DEST_INCLUDE
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

    #Added for campatibility issues per:
    #https://github.com/KhronosGroup/MoltenVK/issues/492
    FileUtils.ln_sf "#{MVK_INCLUDE}/mvk_vulkan.h",        DEST_INCLUDE_MVK
    FileUtils.ln_sf "#{MVK_INCLUDE}/mvk_datatypes.h",     DEST_INCLUDE_MVK
    FileUtils.ln_sf "#{MVK_INCLUDE}/vk_mvk_moltenvk.h",   DEST_INCLUDE_MVK

    FileUtils.mkdir_p(DEST_INCLUDE_PORT) unless Dir.exist?(DEST_INCLUDE_PORT)

    FileUtils.ln_sf "#{PORT_INCLUDE}/vk_extx_portability_subset.h",   DEST_INCLUDE_PORT

    FileUtils.mkdir_p(DEST_INCLUDE_SHADERC) unless Dir.exist?(DEST_INCLUDE_SHADERC)

    FileUtils.ln_sf "#{SHADERC_INCLUDE}/env.h",        DEST_INCLUDE_SHADERC
    FileUtils.ln_sf "#{SHADERC_INCLUDE}/shaderc.h",    DEST_INCLUDE_SHADERC
    FileUtils.ln_sf "#{SHADERC_INCLUDE}/shaderc.hpp",  DEST_INCLUDE_SHADERC
    FileUtils.ln_sf "#{SHADERC_INCLUDE}/status.h",     DEST_INCLUDE_SHADERC
    FileUtils.ln_sf "#{SHADERC_INCLUDE}/visibility.h", DEST_INCLUDE_SHADERC

    #VULKAN DYLIB FILES
    #Versioned libvulkan libraries
    #===============================================
    FileUtils.ln_sf "#{VK_LIB}/libMoltenVK.dylib",                      DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libSPIRV-Tools-shared.dylib",            DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_device_simulation.dylib",     DEST_LIB

    #Validation Layer Dylibs
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_api_dump.dylib",              DEST_LIB
    FileUtils.ln_sf "#{VK_LIB}/libVkLayer_khronos_validation.dylib",    DEST_LIB

    #DX Compiler
    FileUtils.ln_sf "#{VK_LIB}/libdxcompiler.3.7.dylib",                DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libdxcompiler.3.7.dylib",              "#{DEST_LIB}/libdxcompiler.dylib"
  
    #ShaderC
    FileUtils.ln_sf "#{VK_LIB}/libshaderc_shared.1.dylib",              DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libshaderc_shared.1.dylib",            "#{DEST_LIB}/libshaderc_shared.dylib"
    
    #SPIRV Cross C
    FileUtils.ln_sf "#{VK_LIB}/libspirv-cross-c-shared.0.44.0.dylib",   DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libspirv-cross-c-shared.0.44.0.dylib", "#{DEST_LIB}/libspirv-cross-c-shared.0.dylib"
    FileUtils.ln_sf "#{DEST_LIB}/libspirv-cross-c-shared.0.dylib",      "#{DEST_LIB}/libspirv-cross-c-shared.dylib"
    
    #Vulkan
    FileUtils.ln_sf "#{VK_LIB}/libvulkan.#{lib_version}.dylib",         DEST_LIB
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",       "#{DEST_LIB}/libvulkan.1.dylib"
    FileUtils.ln_sf "#{DEST_LIB}/libvulkan.1.dylib",                    "#{DEST_LIB}/libvulkan.dylib"
                                                                        
                                                                        

    #VULKAN ICD FOR MACOS
    #===============================================
    FileUtils.mkdir_p(DEST_SHARE_ICD) unless Dir.exist?(DEST_SHARE_ICD)
    FileUtils.ln_sf "#{VK_SHARE_ICD}/MoltenVK_icd.json", DEST_SHARE_ICD

    #The relative file path in this json file is invalid once these files are installed
    #in system directories.  So replace that path with an absolute path.
    file = File.read("#{VK_SHARE_ICD}/MoltenVK_icd.json")

    data_hash = JSON.parse(file)
    data_hash["ICD"]["library_path"] = "#{DEST_LIB}/libMoltenVK.dylib"

    File.open("#{VK_SHARE_ICD}/MoltenVK_icd.json", "w") do |f|
        f.write( JSON.pretty_generate(data_hash) + "\n" )
    end

    #VULKAN LAYERS FOR DEBUGGING
    #===============================================
    FileUtils.mkdir_p(DEST_SHARE_LAYER) unless Dir.exist?(DEST_SHARE_LAYER)

    layers = [
              "VkLayer_api_dump",
              "VkLayer_khronos_validation",
              ]

    layers.each do |layer|
        layer_filename = "#{VK_SHARE_LAYER}/#{layer}.json"
        FileUtils.ln_sf layer_filename, DEST_SHARE_LAYER

          #fix the file path in the json file
          file = File.read(layer_filename)

          data_hash = JSON.parse(file)
          layer_lib_filename = "lib#{layer}.dylib"
          data_hash["layer"]["library_path"] = "#{DEST_LIB}/#{layer_lib_filename}"

          File.open(layer_filename, "w") do |f|
              f.write( JSON.pretty_generate(data_hash) + "\n" )
          end
    end
    
    #VULKAN DEVICE SIMULATION (hope this works)
    #===============================================
    FileUtils.mkdir_p(DEST_SHARE_CONFIG) unless Dir.exist?(DEST_SHARE_CONFIG)
    FileUtils.ln_sf "#{VK_SHARE_CONFIG}/iOS_gpu_family_3_portability.json", DEST_SHARE_CONFIG
    FileUtils.ln_sf "#{VK_SHARE_CONFIG}/iOS_gpu_family_5_portability.json", DEST_SHARE_CONFIG
    FileUtils.ln_sf "#{VK_SHARE_CONFIG}/macOS_gpu_family_1_portability.json", DEST_SHARE_CONFIG
    
    FileUtils.mkdir_p(DEST_SHARE_REGISTRY) unless Dir.exist?(DEST_SHARE_REGISTRY)
    FileUtils.ln_sf "#{VK_SHARE_REGISTRY}/vk.xml", DEST_SHARE_REGISTRY
    
  end

  uninstall delete: DEST_INCLUDE
  uninstall delete: DEST_INCLUDE_MVK
  uninstall delete: DEST_INCLUDE_PORT
  uninstall delete: DEST_INCLUDE_SHADERC

  uninstall delete: [                      
                      "#{DEST_LIB}/libMoltenVK.dylib",                
                      "#{DEST_LIB}/libSPIRV-Tools-shared.dylib",      

                      #Validation Layer Dylibs
                      "#{DEST_LIB}/libVkLayer_api_dump.dylib",   
                      "#{DEST_LIB}/libVkLayer_khronos_validation.dylib",   

                      #DX Compiler
                      "#{DEST_LIB}/libdxcompiler.3.7.dylib",
                      "#{DEST_LIB}/libdxcompiler.dylib",
  
                      #ShaderC
                      "#{DEST_LIB}/libshaderc_shared.1.dylib",            
                      "#{DEST_LIB}/libshaderc_shared.dylib",
    
                      #SPIRV Cross C
                      "#{DEST_LIB}/libspirv-cross-c-shared.0.36.0.dylib", 
                      "#{DEST_LIB}/libspirv-cross-c-shared.0.dylib",
                      "#{DEST_LIB}/libspirv-cross-c-shared.dylib",
    
                      #Vulkan
                      "#{DEST_LIB}/libvulkan.#{lib_version}.dylib",       
                      "#{DEST_LIB}/libvulkan.1.dylib",
                      "#{DEST_LIB}/libvulkan.dylib",
                      
                      #Device Simulation
                      "#{DEST_LIB}/libVkLayer_device_simulation.dylib"
                    ]

  uninstall delete: '/usr/local/share/vulkan'

  caveats do
    license 'https://vulkan.lunarg.com/sdk/home#sdk-license'
  end

end
