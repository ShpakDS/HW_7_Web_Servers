local _M = {}
local lrucache = require "resty.lrucache"

local ITEMS_COUNT = 2
local CACHE_MIN_USES = 2

-- Створення кешу
local cache, err = lrucache.new(ITEMS_COUNT)
if not cache then
    error("Failed to create the cache: " .. (err or "unknown"))
end

-- Отримання статичного контенту
function _M.get_static()
    local filepath = get_static_path()
    local content, use_count = cache:get(filepath)

    use_count = use_count or 0

    if content then
        ngx.header["X-Cache-Status"] = "HIT"
    else
        ngx.header["X-Cache-Status"] = "MISS"
        content = read_file_or_404(filepath)

        -- Визначення, чи слід кешувати контент
        local should_cache = (use_count < CACHE_MIN_USES - 1)
        cache:set(filepath, should_cache and content or false, nil, use_count + 1)
    end

    ngx.print(content)
end

-- Очищення кешу для статичного контенту
function _M.purge_static()
    cache:delete(get_static_path())
    ngx.exit(ngx.HTTP_NO_CONTENT)
end

-- Читання файлу або повернення 404
function read_file_or_404(filepath)
    local f = io.open(filepath, "rb")
    if not f then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end

    local content = f:read("*all")
    f:close()
    return content
end

-- Отримання шляху до статичного файлу
function get_static_path()
    return ngx.var.document_root .. ngx.var.uri
end

return _M