set_project("wxwidgets-testing")
set_languages("c++17")

add_moduledirs("modules")

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

if is_plat("linux") then
    add_requires("gperf", {configs = {toolchains = "zig"}})
end
add_requires("wxwidgets", {debug = true})

local project_resources = {
    project = {
        windows = {
            "*.rc"
        },
        macosx = {
            "*.icns"
        },
        linux = {
            "*.xpm"
        }
    }
}

local target_resources = {
    target = {
        windows = {
            "*.rc"
        },
        macosx = {
            "*.icns"
        },
        linux = {
            "*.xpm"
        }
    }
}

-- local function check_has_image_resources()
--     local check_cxsnippets = import("lib.detect.check_cxsnippets")
--     return check_cxsnippets({test = [[
--         #include <wx/wxprec.h>
--         #ifndef WX_PRECOMP
--             #include <wx/wx.h>
--         #endif
--         #include "wx/gdicmn.h"
--         #ifndef wxHAS_IMAGE_RESOURCES
--             #error "No images in resources."
--         #endif
--     ]]}, {configs = {languages = "c++14"}})
-- end

-- local function resources(target, image_resources, files, options)
--     local files = files or {}
--     local options = options or {}

--     if is_os("windows") then
--         target:add("rcincludes", path.join("resources", "windows"))
--         target:add("rcincludes", path.join("resources", target:name(), "windows"))
--     end

--     local resource_files = {
--         project = {
--             platform = {}
--         },
--         target = {
--             platform = {}
--         }
--     }
--     table.join2(resource_files, files)

--     target:add("files",
--         path.join("resources", target:os(), table.unpack(resource_files.project.platform[target:os()] or {})), -- Project-level platform-specific resources
--         path.join("resources", target:os(), target:name(), table.unpack(resource_files.target.platform[target:os()] or {})), -- Target-level platform-specific resources
--         path.join("resources", target:name(), table.unpack_except(resource_files.project or {}, "platform")), -- Project-level platform-independent resources
--         path.join("resources", target:name(), table.unpack_except(resource_files.target or {}, "platform"))  -- Target-level platform-independent resources
--     )

--     if not image_resources then
--         target:add("files", path.join("resources", target:name(), "bitmaps", "**.c"))
--     end
-- end

target("minimal")
    set_kind("binary")
    add_packages("wxwidgets")
    add_cxxflags("-static", {force = true})
    add_cxxflags("-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS", "-D_LIBCPP_HARDENING_MODE_DEFAULT=_LIBCPP_HARDENING_MODE_NONE")
    add_cxxflags("-DUNICODE", {force = true})
    on_load(function (target)
        target:add("files", path.join("src", target:name(), "**.cpp"))
        target:add("headerfiles", path.join("src", target:name(), "**.h"))
        target:add("includedirs", path.join("src", target:name()))

        import("resources.resources")
        resources(target, has_image_resources(), table.join(project_resources, target_resources))
    end)
target_end()

target("toolbar")
    set_kind("binary")
    add_packages("wxwidgets")
    add_cxxflags("-static", {force = true})
    add_cxxflags("-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS", "-D_LIBCPP_HARDENING_MODE_DEFAULT=_LIBCPP_HARDENING_MODE_NONE")
    add_cxxflags("-DWIN32", "-D__WXMSW__", "-D_UNICODE", "-DUNICODE", {force = true})
    on_load(function (target)
        target:add("files", path.join("src", target:name(), "**.cpp"))
        target:add("headerfiles", path.join("src", target:name(), "**.h"))
        target:add("includedirs", path.join("src", target:name()))

        import("resources.resources")
        resources(target, has_image_resources(), table.join(project_resources, target_resources))
    end)
target_end()
