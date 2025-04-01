package("wxwidgets")
    set_homepage("https://www.wxwidgets.org/")
    set_description("Cross-Platform C++ GUI Library")

    if is_plat("linux", "macosx", "mingw") then
        add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxWidgets-$(version).tar.bz2",
                 "https://github.com/wxWidgets/wxWidgets.git")
        add_versions("3.2.0", "356e9b55f1ae3d58ae1fed61478e9b754d46b820913e3bfbc971c50377c1903a")
        add_versions("3.2.2", "8edf18672b7bc0996ee6b7caa2bee017a9be604aad1ee471e243df7471f5db5d")
        add_versions("3.2.3", "c170ab67c7e167387162276aea84e055ee58424486404bba692c401730d1a67a")
        add_versions("3.2.4", "0640e1ab716db5af2ecb7389dbef6138d7679261fbff730d23845ba838ca133e")
        add_versions("3.2.5", "0ad86a3ad3e2e519b6a705248fc9226e3a09bbf069c6c692a02acf7c2d1c6b51")

        add_deps("cmake 3.26.4")

        add_deps("zlib-ng", {configs = {zlib_compat = true}})
        add_deps("expat", "libjpeg-turbo", "libpng", "nanosvg", "opengl", "pcre2")

        if is_plat("linux", "macosx") then
            add_deps("pango", "glib")
        end

        if is_plat("linux") then
            add_deps("at-spi2-core")
            add_patches("<=3.2.5", "patches/3.2.5/add_libdir.patch", "9a9fe4d745b4b6b09998ec7a93642d69761a8779d203fbb42a3df8c3d62adeb0")
        end
    end
    
    if is_plat("macosx") then
        add_defines("__WXOSX_COCOA__", "__WXMAC__", "__WXOSX__", "__WXMAC_XCODE__")
        add_frameworks("AudioToolbox", "WebKit", "CoreFoundation", "Security", "Carbon", "Cocoa", "IOKit", "QuartzCore")
        add_syslinks("iconv")
    elseif is_plat("linux") then
        add_defines("__WXGTK3__", "__WXGTK__")
        add_syslinks("pthread", "m", "dl")
        add_syslinks("X11", "Xext", "Xtst", "xkbcommon")
        add_links(
            "pango-1.0", "pangoxft-1.0", "pangocairo-1.0", "pangoft2-1.0"
        )
    elseif is_plat("mingw") then
        add_defines("__WXMSW__")
        -- add_links(
        --     "wxbase32u", "wxbase32u_net", "wxbase32u_xml", --[["wxexpat",]]
        --     --[["wxjpeg",]] "wxmsw32u_adv", "wxmsw32u_aui", "wxmsw32u_core", "wxmsw32u_gl",
        --     "wxmsw32u_html", "wxmsw32u_media", "wxmsw32u_propgrid", "wxmsw32u_qa", "wxmsw32u_ribbon",
        --     "wxmsw32u_richtext", "wxmsw32u_stc", "wxmsw32u_webview", "wxmsw32u_xrc",
        --     --[["wxpng",]] "wxregexu", "wxscintilla"--[[, "wxtiff",]] --[["wxzlib"]]
        -- )
    end

    on_load(function (package)
        if package:is_plat("macosx", "linux", "mingw") then
            local version = package:version()
            local suffix = version:major() .. "." .. version:minor()
            local static = package:config("shared") and "" or "-static"

            -- if package:is_plat("macosx") then
            --     package:add("includedirs", path.join("lib", "wx", "include", "osx_cocoa-unicode" .. static .. "-" .. suffix))
            -- elseif package:is_plat("linux") then
            --     package:add("includedirs", path.join("lib", "wx", "include", "gtk3-unicode" .. static .. "-" .. suffix))
            -- elseif package:is_plat("mingw") then
            --     package:add("includedirs", path.join("lib", "wx", "include", "msw-unicode" .. static .. "-" .. suffix))
            -- end

            -- package:add("includedirs", path.join("include", "wx-" .. suffix))

            if package:is_plat("macosx") then
                package:add("includedirs", path.join("lib", "wx", "config", "osx_cocoa-unicode" .. static .. "-" .. suffix))
            elseif package:is_plat("linux") then
                package:add("includedirs", path.join("lib", "wx", "config", "gtk3-unicode" .. static .. "-" .. suffix))
            elseif package:is_plat("mingw") then
                package:add("includedirs", path.join("lib", "wx", "config", "msw-unicode" .. static .. "-" .. suffix))
            end

            package:add("includedirs", path.join("include"))
            
            if package:debug() then
                package:add("defines", "wxDEBUG_LEVEL=2")
            end
            if package:config("shared") then
                package:add("defines", "WXUSINGDLL")
                package:add("deps", "libtiff", {configs = {shared = true}})
                package:add("deps", "gdk-pixbuf", {configs = {shared = true}})
            else
                package:add("deps", "libtiff")

                if is_plat("linux", "macosx") then
                    package:add("deps", "gdk-pixbuf")
                end
            end

            if is_plat("linux") then
                 if package:config("shared") then
                    package:add("deps", "gtk3", {configs = {shared = true}})
                else
                    package:add("deps", "gtk3")
                end
            end
        end
    end)

    on_install("macosx", "linux", "mingw", function (package)
        -- Notify the user about issues caused by the CMake version.
        local cmake = package:dep("cmake")
        local cmake_fetch = cmake:fetch()
        local major, minor, patch = cmake_fetch.version:match("^(%d+)%.(%d+)%.(%d+)$")
        local cmake_version = tonumber(major.. minor.. patch)
        if cmake_version > 3280 then
            wprint("\ncmake may not find Cmath detail in https://github.com/prusa3d/PrusaSlicer/issues/12169\n")
        end

        io.replace("build/cmake/modules/FindGTK3.cmake", "FIND_PACKAGE_HANDLE_STANDARD_ARGS(GTK3 DEFAULT_MSG GTK3_INCLUDE_DIRS GTK3_LIBRARIES VERSION_OK)", 
                                                         [[FIND_PACKAGE_HANDLE_STANDARD_ARGS(GTK3 DEFAULT_MSG GTK3_INCLUDE_DIRS GTK3_LIBRARY_DIRS GTK3_LIBRARIES VERSION_OK)]], {plain = true})
        local configs = {"-DwxBUILD_TESTS=OFF",
                         "-DwxBUILD_SAMPLES=OFF",
                         "-DwxBUILD_DEMOS=OFF",
                         "-DwxBUILD_PRECOMP=OFF",
                         "-DwxBUILD_BENCHMARKS=OFF",
                         "-DwxUSE_REGEX=sys",
                         "-DwxUSE_ZLIB=sys",
                         "-DwxUSE_EXPAT=sys",
                         "-DwxUSE_LIBJPEG=sys",
                         "-DwxUSE_LIBPNG=sys",
                         "-DwxUSE_NANOSVG=sys",
                         "-DwxUSE_LIBTIFF=builtin"
                        }
        
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:debug() then
            table.insert(configs, "-DwxBUILD_DEBUG_LEVEL=2")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        local version = package:version()
        -- local subdir = "wx-" .. version:major() .. "." .. version:minor()
        local subdir = "wx-" .. version:major() .. "." .. version:minor()
        local setupdir
        if package:is_plat("macosx") then
            setupdir = "osx"
        elseif package:is_plat("linux") then
            setupdir = "gtk"
        elseif package:is_plat("mingw") then
            setupdir = "msw"
        end

        -- os.cp(path.join(package:installdir("include", subdir, "wx", setupdir, "setup.h")),
        --     path.join(package:installdir("include", subdir, "wx")))
        os.cp(path.join(package:installdir("lib", "clang_x64_lib", "mswu", "wx", "setup.h")),
            path.join(package:installdir("include", "wx")))
        os.cp(path.join(package:installdir("lib", "clang_x64_lib", "*.a")),
            path.join(package:installdir("lib")))
        os.rm(path.join(package:installdir("lib", "clang_x64_lib")))

        local lib_suffix = version:major() .. "." .. version:minor()
        if package:is_plat("linux") then
            package:add("links", "wx_gtk3u_xrc-" .. lib_suffix, "wx_gtk3u_html-" .. lib_suffix, "wx_gtk3u_qa-" .. lib_suffix, "wx_gtk3u_core-" .. lib_suffix, "wx_baseu_xml-" .. lib_suffix, "wx_baseu_net-" .. lib_suffix, "wx_baseu-" .. lib_suffix)
        end
    end)

    -- #include <wx/wxprec.h>
    -- #ifndef WX_PRECOMP
    --     #include <wx/wx.h>
    -- #endif

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <wx/wx.h>
            #include "wx/app.h"
            #include "wx/cmdline.h"
            void test() {
                wxApp::CheckBuildOptions(WX_BUILD_OPTIONS_SIGNATURE, "program");
                wxInitializer initializer;
                if (!initializer) {
                    fprintf(stderr, "Failed to initialize the wxWidgets library, aborting.");
                }
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)