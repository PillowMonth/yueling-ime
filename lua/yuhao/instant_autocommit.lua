-- instant_autocommit.lua
-- 韻碼结尾或滿4碼立即上屏首選,無視重碼
-- 空碼時保留編碼不清屏

local function func(key_event, env)
    local context = env.engine.context

    -- 開關檢查
    if context:get_option("yuhao_autocommit") == false then
        return 2 -- kNoop
    end

    -- 只處理字母鍵按下
    if key_event:release() or key_event:alt() or key_event:ctrl() or key_event:shift() or key_event:caps() then
        return 2
    end

    local ch = string.char(key_event.keycode)
    if not ch:match("[a-zA-Z]") then
        return 2
    end

    local lower_ch = string.lower(ch)
    local new_input = context.input .. lower_ch

    -- 反查、宏等引導模式不觸發自動上屏
    if context.input:match("^[z/`]") then
        return 2
    end

    -- 上屏條件：總長≥4，或末碼爲 a e i o u
    if #new_input >= 4 or new_input:match("[aeiou]$") then
        context:push_input(lower_ch)

        local seg = context.composition:back()
        if seg then
            local cand = seg:get_selected_candidate()
            if cand then
                env.engine:commit_text(cand.text)
                context:clear()
                return 1 -- kAccepted，吞鍵
            end
        end

        -- 無候選：回退字母，不清屏
        context:pop_input(1)
        return 2
    end

    return 2
end

return { func = func }