-- 作者： 枕月
-- z_word_select.lua

-- 以詞取字
-- 拼音反查模式下： 
-- [ 或 , 取詞首字
-- ] 或 . 取詞末字
-- 單字吞鍵，不輸出標點。


-- 安全提取 UTF-8 字符串的第一個字符
local function utf8_head(str)
    for _, c in utf8.codes(str) do
        return utf8.char(c)
    end
    return ""
end

local function utf8_tail(str)
    local lastchar
    for _, c in utf8.codes(str) do
        lastchar = utf8.char(c)
    end
    return lastchar or ""
end

local function func(key_event, env)
    local context = env.engine.context
    local keycode = key_event.keycode
    if keycode < 32 or keycode > 255 then return 2 end
    local ch = string.char(keycode)

    -- 取首字键： [  ,
    -- 取末字键： ]  .
    local is_head = (ch == '[' or ch == ',')
    local is_tail = (ch == ']' or ch == '.')
    if not (is_head or is_tail) then return 2 end

    if key_event:release() or key_event:alt() or key_event:ctrl() or key_event:shift() or key_event:caps() then return 2 end

    -- 只在反查模式（以 z 开头）下生效
    if not context.input:match("^z") then return 2 end

    if not context:has_menu() then return 2 end
    local seg = context.composition:back()
    if not seg then return 2 end
    local cand = seg:get_selected_candidate()
    if not cand then return 2 end

    local text = cand.text
    if utf8.len(text) > 1 then
        local target = is_head and utf8_head(text) or utf8_tail(text)
        env.engine:commit_text(target)
        context:clear()
        return 1
    end

    -- 单字时：吞键，避免默认确认候选并输出标点
    return 1
end

return { func = func }
