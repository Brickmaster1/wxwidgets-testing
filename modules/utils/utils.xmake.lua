function table.unpack_except(tbl, except_key)
    local out = {}
    for k, v in pairs(tbl or {}) do
        if k ~= except_key then
            if type(v) == "table" then
                -- recursively flatten nested tables
                for _, vv in ipairs(v) do
                    table.insert(out, vv)
                end
            else
                table.insert(out, v)
            end
        end
    end
    return table.unpack(out)
end