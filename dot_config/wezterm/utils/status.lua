local wezterm = require("wezterm")

local Status = {}

-- Get battery information (Linux/macOS)
local function get_battery_info()
    local battery_info = {}
    
    -- Try to get battery info on Linux
    local success, result = pcall(function()
        local handle = io.popen("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null")
        local capacity = handle:read("*a")
        handle:close()
        
        if capacity and capacity ~= "" then
            local level = tonumber(capacity:match("(%d+)"))
            if level then
                local handle2 = io.popen("cat /sys/class/power_supply/BAT*/status 2>/dev/null")
                local status = handle2:read("*a"):match("(%w+)")
                handle2:close()
                
                return {
                    level = level,
                    status = status or "Unknown"
                }
            end
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    
    -- Try macOS battery info
    success, result = pcall(function()
        local handle = io.popen("pmset -g batt 2>/dev/null")
        local output = handle:read("*a")
        handle:close()
        
        local level = output:match("(%d+)%%")
        local status = output:match("'([^']+)'")
        
        if level then
            return {
                level = tonumber(level),
                status = status or "Unknown"
            }
        end
        return nil
    end)
    
    return success and result or nil
end

-- Get memory usage
local function get_memory_usage()
    local success, result = pcall(function()
        -- Linux
        local handle = io.popen("free -m 2>/dev/null | awk 'NR==2{printf \"%.0f\", $3*100/$2}'")
        local mem_percent = handle:read("*a")
        handle:close()
        
        if mem_percent and mem_percent ~= "" then
            return tonumber(mem_percent)
        end
        
        -- macOS fallback
        local handle2 = io.popen("vm_stat 2>/dev/null | awk '/free/ {free=$3} /inactive/ {inactive=$3} /wired/ {wired=$4} /active/ {active=$3} END {total=free+inactive+wired+active; used=active+wired; printf \"%.0f\", used*100/total}'")
        local mem_percent_mac = handle2:read("*a")
        handle2:close()
        
        return tonumber(mem_percent_mac)
    end)
    
    return success and result or nil
end

-- Get CPU usage
local function get_cpu_usage()
    local success, result = pcall(function()
        -- Linux
        local handle = io.popen("top -bn1 2>/dev/null | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1")
        local cpu_percent = handle:read("*a")
        handle:close()
        
        if cpu_percent and cpu_percent ~= "" then
            return tonumber(cpu_percent)
        end
        
        -- macOS fallback
        local handle2 = io.popen("ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s}'")
        local cpu_percent_mac = handle2:read("*a")
        handle2:close()
        
        return tonumber(cpu_percent_mac)
    end)
    
    return success and result or nil
end

-- Get current Git branch
local function get_git_branch(cwd)
    if not cwd then
        return nil
    end
    
    local success, result = pcall(function()
        local handle = io.popen(string.format("cd '%s' && git branch --show-current 2>/dev/null", cwd))
        local branch = handle:read("*a"):gsub("\n", "")
        handle:close()
        
        if branch and branch ~= "" then
            return branch
        end
        return nil
    end)
    
    return success and result or nil
end

-- Get Git status info
local function get_git_status(cwd)
    if not cwd then
        return nil
    end
    
    local success, result = pcall(function()
        local handle = io.popen(string.format("cd '%s' && git status --porcelain 2>/dev/null", cwd))
        local status = handle:read("*a")
        handle:close()
        
        if status then
            local modified = 0
            local added = 0
            local deleted = 0
            local untracked = 0
            
            for line in status:gmatch("[^\r\n]+") do
                local status_char = line:sub(1, 2)
                if status_char:match("^M") or status_char:match("^.M") then
                    modified = modified + 1
                elseif status_char:match("^A") or status_char:match("^.A") then
                    added = added + 1
                elseif status_char:match("^D") or status_char:match("^.D") then
                    deleted = deleted + 1
                elseif status_char:match("^%?%?") then
                    untracked = untracked + 1
                end
            end
            
            return {
                modified = modified,
                added = added,
                deleted = deleted,
                untracked = untracked
            }
        end
        return nil
    end)
    
    return success and result or nil
end

-- Format battery display
local function format_battery(battery)
    if not battery then
        return ""
    end
    
    local icon = "🔋"
    if battery.status == "Charging" then
        icon = "🔌"
    elseif battery.level <= 20 then
        icon = "🪫"
    elseif battery.level <= 50 then
        icon = "🔋"
    else
        icon = "🔋"
    end
    
    local color = "#a7c080" -- green
    if battery.level <= 20 then
        color = "#e67e80" -- red
    elseif battery.level <= 50 then
        color = "#dbbc7f" -- yellow
    end
    
    return {
        { Foreground = { Color = color } },
        { Text = string.format("%s %d%% ", icon, battery.level) },
    }
end

-- Format memory display
local function format_memory(memory)
    if not memory then
        return ""
    end
    
    local color = "#a7c080" -- green
    if memory >= 80 then
        color = "#e67e80" -- red
    elseif memory >= 60 then
        color = "#dbbc7f" -- yellow
    end
    
    return {
        { Foreground = { Color = color } },
        { Text = string.format("🧠 %d%% ", memory) },
    }
end

-- Format CPU display
local function format_cpu(cpu)
    if not cpu then
        return ""
    end
    
    local color = "#a7c080" -- green
    if cpu >= 80 then
        color = "#e67e80" -- red
    elseif cpu >= 60 then
        color = "#dbbc7f" -- yellow
    end
    
    return {
        { Foreground = { Color = color } },
        { Text = string.format("⚡ %d%% ", cpu) },
    }
end

-- Format Git information
local function format_git(branch, status, colors)
    if not branch then
        return {}
    end
    
    local elements = {
        { Foreground = { Color = colors.orange or "#e69875" } },
        { Text = " " .. branch },
    }
    
    if status then
        if status.modified > 0 then
            table.insert(elements, { Foreground = { Color = colors.yellow or "#dbbc7f" } })
            table.insert(elements, { Text = " ~" .. status.modified })
        end
        if status.added > 0 then
            table.insert(elements, { Foreground = { Color = colors.green or "#a7c080" } })
            table.insert(elements, { Text = " +" .. status.added })
        end
        if status.deleted > 0 then
            table.insert(elements, { Foreground = { Color = colors.red or "#e67e80" } })
            table.insert(elements, { Text = " -" .. status.deleted })
        end
        if status.untracked > 0 then
            table.insert(elements, { Foreground = { Color = colors.purple or "#d699b6" } })
            table.insert(elements, { Text = " ?" .. status.untracked })
        end
    end
    
    table.insert(elements, { Foreground = { Color = colors.fg or "#d3c6aa" } })
    table.insert(elements, { Text = " " })
    
    return elements
end

-- Get current working directory from pane
local function get_cwd_from_pane(pane)
    local cwd_uri = pane.current_working_dir
    if not cwd_uri then
        return nil
    end
    
    local cwd = ""
    if type(cwd_uri) == "userdata" then
        cwd = cwd_uri.file_path
    else
        cwd_uri = cwd_uri:sub(8) -- Remove "file://"
        local slash = cwd_uri:find("/")
        if slash then
            cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
                return string.char(tonumber(hex, 16))
            end)
        end
    end
    
    return cwd ~= "" and cwd or nil
end

-- Setup status bar
function Status.setup(config, colors)
    colors = colors or {}
    
    -- Cache for expensive operations
    local cache = {
        battery = { value = nil, last_update = 0 },
        memory = { value = nil, last_update = 0 },
        cpu = { value = nil, last_update = 0 },
    }
    
    local function get_cached_value(key, getter, cache_duration)
        local now = os.time()
        local cached = cache[key]
        
        if not cached.value or (now - cached.last_update) > cache_duration then
            cached.value = getter()
            cached.last_update = now
        end
        
        return cached.value
    end
    
    -- Right status with system info
    wezterm.on("update-right-status", function(window, pane)
        local elements = {}
        
        -- Get current working directory
        local cwd = get_cwd_from_pane(pane)
        
        -- Git information (updated frequently)
        if cwd then
            local branch = get_git_branch(cwd)
            local git_status = get_git_status(cwd)
            local git_elements = format_git(branch, git_status, colors)
            for _, element in ipairs(git_elements) do
                table.insert(elements, element)
            end
        end
        
        -- System information (cached)
        local battery = get_cached_value("battery", get_battery_info, 60) -- 1 minute
        local memory = get_cached_value("memory", get_memory_usage, 5)    -- 5 seconds
        local cpu = get_cached_value("cpu", get_cpu_usage, 5)             -- 5 seconds
        
        -- Add system info
        local battery_elements = format_battery(battery)
        local memory_elements = format_memory(memory)
        local cpu_elements = format_cpu(cpu)
        
        if type(battery_elements) == "table" then
            for _, element in ipairs(battery_elements) do
                table.insert(elements, element)
            end
        end
        
        if type(memory_elements) == "table" then
            for _, element in ipairs(memory_elements) do
                table.insert(elements, element)
            end
        end
        
        if type(cpu_elements) == "table" then
            for _, element in ipairs(cpu_elements) do
                table.insert(elements, element)
            end
        end
        
        -- Workspace and time
        local workspace = window:active_workspace()
        local time = wezterm.strftime("%H:%M")
        local date = wezterm.strftime("%a %d")
        
        -- Add separator
        table.insert(elements, { Foreground = { Color = colors.bg3 or "#56635f" } })
        table.insert(elements, { Text = "│ " })
        
        -- Workspace
        table.insert(elements, { Foreground = { Color = colors.blue or "#7fbbb3" } })
        table.insert(elements, { Text = workspace .. " " })
        
        -- Date and time
        table.insert(elements, { Foreground = { Color = colors.fg or "#d3c6aa" } })
        table.insert(elements, { Text = date .. " " })
        table.insert(elements, { Foreground = { Color = colors.green or "#a7c080" } })
        table.insert(elements, { Text = time .. " " })
        
        window:set_right_status(wezterm.format(elements))
    end)
    
    -- Left status with hostname
    wezterm.on("update-status", function(window, pane)
        local hostname = wezterm.hostname()
        local tab_count = #window:mux_window():tabs()
        local active_tab = window:active_tab()
        local tab_index = 0
        
        -- Find current tab index
        for i, tab in ipairs(window:mux_window():tabs()) do
            if tab:tab_id() == active_tab:tab_id() then
                tab_index = i
                break
            end
        end
        
        local elements = {
            { Foreground = { Color = colors.fg or "#d3c6aa" } },
            { Text = string.format(" %s ", hostname) },
        }
        
        if tab_count > 1 then
            table.insert(elements, { Foreground = { Color = colors.bg3 or "#56635f" } })
            table.insert(elements, { Text = "│ " })
            table.insert(elements, { Foreground = { Color = colors.yellow or "#dbbc7f" } })
            table.insert(elements, { Text = string.format("%d/%d ", tab_index, tab_count) })
        end
        
        window:set_left_status(wezterm.format(elements))
    end)
    
    -- Enhanced window title
    wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
        local zoomed = ""
        if tab.active_pane.is_zoomed then
            zoomed = "[Z] "
        end
        
        local index = ""
        if #tabs > 1 then
            index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
        end
        
        local workspace = ""
        if #wezterm.mux.get_workspace_names() > 1 then
            workspace = string.format("[%s] ", tab.window.active_workspace or "default")
        end
        
        return zoomed .. workspace .. index .. (tab.active_pane.title or "WezTerm")
    end)
end

return Status