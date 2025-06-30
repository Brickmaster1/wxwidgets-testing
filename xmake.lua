set_project("wxwidgets-testing")
set_languages("c++17")

add_rules("mode.debug", "mode.release")
add_rules("plugin.compile_commands.autoupdate", {outputdir = ".vscode"})

if is_mode("debug") then
    set_symbols("debug")
    set_optimize("none")
end

if is_mode("release") then
    set_symbols("hidden")
    set_optimize("fastest")
    set_strip("all")
end

set_toolset("mrc", "zig rc")

add_repositories("overrides overrides")

add_requires("wxwidgets", {debug = true})

local function add_platform_resources(target, images_in_resources)
    if is_os("windows") then
        target:add("files", "resources/windows/*.rc")
        target:add("files", "resources/" .. target:name() .. "/windows/**.rc")
    elseif is_os("macosx") then
        target:add("files", "resources/apple/*.icns")
        target:add("files", "resources/" .. target:name() .. "/apple/**.icns")
    elseif is_os("linux") then
        target:add("files", "resources/linux/*.xpm")
        target:add("files", "resources/" .. target:name() .. "/linux/**.xpm")
    end

    if images_in_resources then
        target:add("files", "resources/" .. target:name() .. "/**.c")
    end
end

target("minimal")
    set_kind("binary")
    add_packages("wxwidgets")
    add_cxxflags("-static", {force = true})
    add_cxxflags("-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS", "-D_LIBCPP_HARDENING_MODE_DEFAULT=_LIBCPP_HARDENING_MODE_NONE")
    on_load(function (target)
        target:add("files", "src/" .. target:name() .. "**.cpp")
        target:add("headerfiles", "src/" .. target:name() .. "**.h")
        target:add("includedirs", "src/" .. target:name())

        import("lib.detect.check_cxsnippets")
        local result = check_cxsnippets({test = [[
            #include <wx/wxprec.h>
            #ifndef WX_PRECOMP
                #include <wx/wx.h>
            #endif
            #include "wx/gdicmn.h"
            #ifndef wxHAS_IMAGES_IN_RESOURCES
                #error "No images in resources."
            #endif
        ]]}, {configs = {languages = "c++14"}})

        add_platform_resources(target, result)
    end)
target_end()

target("toolbar")
    set_kind("binary")
    add_packages("wxwidgets")
    add_options("compiled_images", {default = true, description = "Use static wxWidgets libraries"})
    add_cxxflags("-static", {force = true})
    add_cxxflags("-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS", "-D_LIBCPP_HARDENING_MODE_DEFAULT=_LIBCPP_HARDENING_MODE_NONE")
    on_load(function (target)
        target:add("files", "src/" .. target:name() .. "**.cpp")
        target:add("headerfiles", "src/" .. target:name() .. "**.h")
        target:add("includedirs", "src/" .. target:name())

        import("lib.detect.check_cxsnippets")
        local result = check_cxsnippets({test = [[
            #include <wx/wxprec.h>
            #ifndef WX_PRECOMP
                #include <wx/wx.h>
            #endif
            #include "wx/gdicmn.h"
            #ifndef wxHAS_IMAGES_IN_RESOURCES
                #error "No images in resources."
            #endif
        ]]}, {configs = {languages = "c++14"}})

        add_platform_resources(target, result)
    end)
target_end()
