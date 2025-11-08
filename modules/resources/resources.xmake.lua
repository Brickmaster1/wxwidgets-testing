local function get_check_cxsnippets()
    return import("lib.detect.check_cxsnippets")
end

local function get_utils()
    return import("utils.utils")
end

function has_image_resources()
    local check_cxsnippets = get_check_cxsnippets()
    return check_cxsnippets({test = [[
        #include <wx/wxprec.h>
        #ifndef WX_PRECOMP
            #include <wx/wx.h>
        #endif
        #include "wx/gdicmn.h"
        #ifndef wxHAS_IMAGE_RESOURCES
            #error "No images in resources."
        #endif
    ]]}, {configs = {languages = "c++14"}})
end

function resources(target, image_resources, files, options)
    local utils = get_utils()
    local files = files or {}
    local options = options or {}

    if target:is_os("windows") then
        target:add("rcincludes", path.join("resources", "windows"))
        target:add("rcincludes", path.join("resources", target:name(), "windows"))
    end

    local resource_files = {
        project = {
            platform = {}
        },
        target = {
            platform = {}
        }
    }
    table.join2(resource_files, files)

    target:add("files",
        path.join("resources", target:os(), table.unpack(resource_files.project.platform[target:os()] or {})),
        path.join("resources", target:os(), target:name(), table.unpack(resource_files.target.platform[target:os()] or {})),
        path.join("resources", target:name(), utils.unpack_except(resource_files.project or {}, "platform")),
        path.join("resources", target:name(), utils.unpack_except(resource_files.target or {}, "platform"))
    )

    if not image_resources then
        target:add("files", path.join("resources", target:name(), "bitmaps", "**.c"))
    end
end
