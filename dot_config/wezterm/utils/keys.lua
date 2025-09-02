local wezterm = require("wezterm")
local act = wezterm.action

local Keys = {}

-- Smart pane navigation that works with vim/nvim
local function is_vim(pane)
    -- Check if the current pane is running vim/nvim
    local process_name = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
    return process_name == 'nvim' or process_name == 'vim'
end

-- Create smart navigation function
local function navigate_pane_or_vim_split(key, direction)
    return wezterm.action_callback(function(window, pane)
        if is_vim(pane) then
            -- Send the key to vim/nvim
            window:perform_action({
                SendKey = { key = key, mods = 'CTRL' }
            }, pane)
        else
            -- Navigate wezterm panes
            window:perform_action({ ActivatePaneDirection = direction }, pane)
        end
    end)
end

-- Create smart scrolling function for Ctrl+U and Ctrl+D
local function smart_scroll(key, scroll_action)
    return wezterm.action_callback(function(window, pane)
        if is_vim(pane) then
            -- Send the key to vim/nvim for half-page scrolling
            window:perform_action({
                SendKey = { key = key, mods = 'CTRL' }
            }, pane)
        else
            -- Use WezTerm's scroll action
            window:perform_action(scroll_action, pane)
        end
    end)
end

-- Quick directory navigation
local function quick_select_directory()
    return act.QuickSelectArgs({
        label = 'open directory',
        patterns = { [[(?:~|\.{1,2})?/[^\s]+]] },
        action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            if url then
                window:perform_action(
                    act.SpawnCommandInNewTab({ args = { 'cd', url } }),
                    pane
                )
            end
        end),
    })
end

-- Smart tab switching with workspace awareness
local function smart_tab_switch(direction)
    return wezterm.action_callback(function(window, pane)
        local tabs = window:mux_window():tabs()
        local current_idx = window:active_tab():tab_id()
        
        -- Find current tab index
        local current_pos = 1
        for i, tab in ipairs(tabs) do
            if tab:tab_id() == current_idx then
                current_pos = i
                break
            end
        end
        
        local new_pos
        if direction > 0 then
            new_pos = current_pos % #tabs + 1
        else
            new_pos = current_pos == 1 and #tabs or current_pos - 1
        end
        
        window:perform_action(act.ActivateTab(new_pos - 1), pane)
    end)
end

-- Workspace switcher with fuzzy matching
local function workspace_switcher()
    return wezterm.action_callback(function(window, pane)
        local workspaces = {}
        for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
            table.insert(workspaces, {
                id = workspace,
                label = workspace,
            })
        end
        
        window:perform_action(
            act.InputSelector({
                action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
                    if not id and not label then
                        return
                    end
                    inner_window:perform_action(
                        act.SwitchToWorkspace({ name = id }),
                        inner_pane
                    )
                end),
                title = 'Select Workspace',
                choices = workspaces,
                fuzzy = true,
            }),
            pane
        )
    end)
end

-- Project launcher
local function project_launcher()
    return wezterm.action_callback(function(window, pane)
        local home = os.getenv("HOME")
        local projects = {
            { id = home .. "/projects", label = "~/projects" },
            { id = home .. "/.config", label = "~/.config" },
            { id = home .. "/Documents", label = "~/Documents" },
            { id = home .. "/Downloads", label = "~/Downloads" },
            { id = "/tmp", label = "/tmp" },
        }
        
        -- Add git repositories if available
        local success, result = pcall(function()
            local handle = io.popen("find " .. home .. " -name '.git' -type d 2>/dev/null | head -20")
            for line in handle:lines() do
                local project_dir = line:gsub("/.git$", "")
                local project_name = project_dir:match("([^/]+)$")
                table.insert(projects, {
                    id = project_dir,
                    label = "📁 " .. project_name .. " (" .. project_dir .. ")"
                })
            end
            handle:close()
        end)
        
        window:perform_action(
            act.InputSelector({
                action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
                    if not id then
                        return
                    end
                    inner_window:perform_action(
                        act.SpawnCommandInNewTab({
                            args = { "zsh", "-c", "cd " .. id .. " && exec zsh" },
                        }),
                        inner_pane
                    )
                end),
                title = 'Select Project Directory',
                choices = projects,
                fuzzy = true,
            }),
            pane
        )
    end)
end

-- Enhanced copy mode with better defaults
local function enter_copy_mode()
    return act.Multiple({
        act.CopyMode('MoveToStartOfLine'),
        act.CopyMode('MoveToSelectionOtherEnd'),
    })
end

-- Quick command runner
local function quick_command()
    return act.PromptInputLine({
        description = 'Run command:',
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:perform_action(
                    act.SpawnCommandInNewTab({ args = { "zsh", "-c", line } }),
                    pane
                )
            end
        end),
    })
end

-- Session management with names
local function named_session_save()
    return act.PromptInputLine({
        description = 'Session name:',
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                -- Save with custom name
                wezterm.emit('save_session', window, line)
            end
        end),
    })
end

-- Multi-pane layouts
local function create_layout(layout_type)
    return wezterm.action_callback(function(window, pane)
        local tab = window:active_tab()
        
        if layout_type == "ide" then
            -- Create IDE-like layout: main + sidebar + bottom
            tab:set_title("IDE Layout")
            window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
            window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
            -- Focus back to main pane
            window:perform_action(act.ActivatePaneDirection("Left"), pane)
        elseif layout_type == "terminal" then
            -- Create terminal layout: main + bottom split
            tab:set_title("Terminal Layout")
            window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
        elseif layout_type == "quad" then
            -- Create quad layout: 2x2 grid
            tab:set_title("Quad Layout")
            window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
            window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
            window:perform_action(act.ActivatePaneDirection("Left"), pane)
            window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
        end
    end)
end

-- Export key binding configurations
Keys.leader_key = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

Keys.keys = {
    -- System integration
    { key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") },
    { key = "C", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
    
    -- Smart pane navigation (works with vim/nvim)
    { key = "h", mods = "CTRL", action = navigate_pane_or_vim_split("h", "Left") },
    { key = "l", mods = "CTRL", action = navigate_pane_or_vim_split("l", "Right") },
    { key = "k", mods = "CTRL", action = navigate_pane_or_vim_split("k", "Up") },
    { key = "j", mods = "CTRL", action = navigate_pane_or_vim_split("j", "Down") },
    
    -- Standard pane navigation fallback
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
    { key = "UpArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    
    -- Pane resizing
    { key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
    
    -- Enhanced scrolling (context-aware for vim/nvim)
    { key = "u", mods = "CTRL", action = smart_scroll("u", act.ScrollByPage(-0.5)) },
    { key = "d", mods = "CTRL", action = smart_scroll("d", act.ScrollByPage(0.5)) },
    { key = "k", mods = "CTRL|ALT", action = act.ScrollByLine(-3) },
    { key = "j", mods = "CTRL|ALT", action = act.ScrollByLine(3) },
    { key = "Home", mods = "CTRL", action = act.ScrollToTop },
    { key = "End", mods = "CTRL", action = act.ScrollToBottom },
    
    -- Leader-based bindings
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    
    -- Pane management
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "!", mods = "LEADER|SHIFT", action = act.PaneSelect({ mode = "SwapWithActive" }) },
    { key = "q", mods = "LEADER", action = act.PaneSelect },
    
    -- Tab management
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = smart_tab_switch(1) },
    { key = "p", mods = "LEADER", action = smart_tab_switch(-1) },
    { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
    
    -- Enhanced tab navigation
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    
    -- Workspace management
    { key = "w", mods = "LEADER", action = workspace_switcher() },
    { key = "W", mods = "LEADER|SHIFT", action = act.PromptInputLine({
        description = "New workspace name:",
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
            end
        end),
    })},
    
    -- Quick applications and tools
    { key = "g", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { "lazygit" } }) },
    { key = "f", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { "ranger" } }) },
    { key = "m", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { "btop" } }) },
    { key = "v", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { "nvim" } }) },
    
    -- Project and directory navigation
    { key = "o", mods = "LEADER", action = project_launcher() },
    { key = "D", mods = "LEADER|SHIFT", action = quick_select_directory() },
    
    -- Enhanced copy/search mode
    { key = "Space", mods = "LEADER", action = enter_copy_mode() },
    { key = "/", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
    { key = "?", mods = "LEADER|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },
    
    -- Session management
    { key = "s", mods = "LEADER", action = named_session_save() },
    { key = "S", mods = "LEADER|SHIFT", action = act.EmitEvent("save_session") },
    { key = "r", mods = "LEADER", action = act.EmitEvent("restore_session") },
    { key = "L", mods = "LEADER|SHIFT", action = act.EmitEvent("load_session") },
    
    -- Quick layouts
    { key = "1", mods = "LEADER|ALT", action = create_layout("ide") },
    { key = "2", mods = "LEADER|ALT", action = create_layout("terminal") },
    { key = "3", mods = "LEADER|ALT", action = create_layout("quad") },
    
    -- Command and launcher
    { key = ":", mods = "LEADER", action = quick_command() },
    { key = "l", mods = "LEADER", action = act.ShowLauncher },
    { key = "P", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
    
    -- Font and UI
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
    { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
    
    -- Tab renaming and management
    { key = "e", mods = "LEADER", action = act.PromptInputLine({
        description = "Tab name:",
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:active_tab():set_title(line)
            end
        end),
    })},
    
    -- Debug and configuration
    { key = "F5", mods = "NONE", action = act.ReloadConfiguration },
    { key = "F12", mods = "NONE", action = act.ShowDebugOverlay },
    
    -- Leader key passthrough
    { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
    
    -- Window management
    { key = "N", mods = "CTRL|SHIFT", action = act.SpawnWindow },
}

-- Add number key bindings for tab navigation (both leader and alt)
for i = 1, 9 do
    table.insert(Keys.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1),
    })
    table.insert(Keys.keys, {
        key = tostring(i),
        mods = "ALT",
        action = act.ActivateTab(i - 1),
    })
end

return Keys