set_project("wxwidgets-testing")
set_languages("c++20")

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

add_cxxflags("-nostdinc++", {force = true})
add_cxxflags("-isystem C:/Users/Logan Hunt/AppData/Local/Microsoft/WinGet/Packages/zig.zig_Microsoft.Winget.Source_8wekyb3d8bbwe/zig-windows-x86_64-0.13.0/lib/libcxx/include", {force = true})
add_cxxflags("-isystem C:/Users/Logan Hunt/AppData/Local/Microsoft/WinGet/Packages/zig.zig_Microsoft.Winget.Source_8wekyb3d8bbwe/zig-windows-x86_64-0.13.0/lib/libcxxabi/include", {force = true})
add_ldflags("-LC:/Users/Logan Hunt/AppData/Local/Microsoft/WinGet/Packages/zig.zig_Microsoft.Winget.Source_8wekyb3d8bbwe/zig-windows-x86_64-0.13.0/lib/libcxx", {force = true})

add_repositories("overrides overrides")

add_requires("wxwidgets")

target("test")
    set_kind("binary")
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")
    add_packages("wxwidgets")
    add_cxxflags("-static", {force = true})
target_end()
