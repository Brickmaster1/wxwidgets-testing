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

target("test")
    set_kind("binary")
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")
    add_packages("wxwidgets")
    add_cxxflags("-static", {force = true})
    -- add_cxxflags("-fno-inline-functions", {force = true})
    add_cxxflags("-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS", "-D_LIBCPP_HARDENING_MODE_DEFAULT=_LIBCPP_HARDENING_MODE_NONE")
    if is_os("windows") then
        add_files("resources/windows/**.rc")
    end
target_end()
