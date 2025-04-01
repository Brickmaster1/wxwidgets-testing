package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("2022.12.3", "8c82e737eea2f8ab3667e227142abd2fd221f038")

    add_deps("meson", "ninja")

    -- Adjust settings based on the target platform (works for cross builds)
    on_load(function (package)
        if package:is_plat("macosx") then
            package:add("frameworks", "CoreGraphics", "CoreText", "Foundation", "AppKit")
        elseif package:is_plat("windows") then
            package:add("syslinks", "user32", "ole32", "gdi32", "d2d1", "dwrite", "comctl32", "windowscodecs")
        elseif package:is_plat("linux") then
            package:add("deps", "gtk+3", "glib")
        end
    end)

    -- Add "cross" so that cross builds (e.g. riscv64-linux-musl) are accepted.
    on_install("linux", "macosx", "windows", "mingw", function (package)
        local configs = {"-Dexamples=false", "-Dtests=false", "-Db_pie=false"}
        table.insert(configs, "--default-library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uiInit", {includes = "ui.h"}))
    end)
