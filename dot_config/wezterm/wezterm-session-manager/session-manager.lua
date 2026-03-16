local wezterm = require("wezterm")
local platform = require("utils.platform")
local session_manager = {}
local os = wezterm.target_triple

--- Displays a notification in WezTerm.
-- @param message string: The notification message to be displayed.
local function display_notification(message)
  wezterm.log_info(message)
  -- Additional code to display a GUI notification can be added here if needed
end

--- Retrieves the current workspace data from the active window.
-- @return table or nil: The workspace data table or nil if no active window is found.
local function retrieve_workspace_data(window)
  local workspace_name = window:active_workspace()
  local workspace_data = {
    name = workspace_name,
    tabs = {}
  }

  -- Iterate over tabs in the current window
  for _, tab in ipairs(window:mux_window():tabs()) do
    local tab_data = {
      tab_id = tostring(tab:tab_id()),
      panes = {}
    }

    -- Iterate over panes in the current tab
    for _, pane_info in ipairs(tab:panes_with_info()) do
      -- Collect pane details, including layout and process information
      table.insert(tab_data.panes, {
        pane_id = tostring(pane_info.pane:pane_id()),
        index = pane_info.index,
        is_active = pane_info.is_active,
        is_zoomed = pane_info.is_zoomed,
        left = pane_info.left,
        top = pane_info.top,
        width = pane_info.width,
        height = pane_info.height,
        pixel_width = pane_info.pixel_width,
        pixel_height = pane_info.pixel_height,
        cwd = tostring(pane_info.pane:get_current_working_dir()),
        tty = tostring(pane_info.pane:get_foreground_process_name())
      })
    end

    table.insert(workspace_data.tabs, tab_data)
  end

  return workspace_data
end

--- Saves data to a JSON file.
-- @param data table: The workspace data to be saved.
-- @param file_path string: The file path where the JSON file will be saved.
-- @return boolean: true if saving was successful, false otherwise.
local function save_to_json_file(data, file_path)
  if not data then
    wezterm.log_info("No workspace data to log.")
    return false
  end

  -- Ensure directory exists
  local dir = file_path:match("(.*/)")
  if dir then
    platform.ensure_dir(dir)
  end

  local file = io.open(file_path, "w")
  if file then
    file:write(wezterm.json_encode(data))
    file:close()
    return true
  else
    wezterm.log_error("Failed to write session file: " .. file_path)
    return false
  end
end

--- Recreates the workspace based on the provided data.
-- @param workspace_data table: The data structure containing the saved workspace state.
local function recreate_workspace(window, workspace_data)
  local function extract_path_from_dir(working_directory)
    local path = platform.parse_cwd_uri(working_directory)
    if not path or path == "" then
      return platform.get_home_dir()
    end
    return platform.normalize_path(path)
  end

  if not workspace_data or not workspace_data.tabs then
    wezterm.log_info("Invalid or empty workspace data provided.")
    return
  end

  local tabs = window:mux_window():tabs()

  if #tabs ~= 1 or #tabs[1]:panes() ~= 1 then
    wezterm.log_info(
      "Restoration can only be performed in a window with a single tab and a single pane, to prevent accidental data loss.")
    return
  end

  local initial_pane = window:active_pane()
  local foreground_process = initial_pane:get_foreground_process_name()
  local process_basename = foreground_process:match("([^/\\]+)$") or foreground_process
  local shell_names = {
    sh = true, bash = true, zsh = true, fish = true, csh = true,
    tcsh = true, dash = true, ksh = true, ash = true, nu = true,
    ["cmd.exe"] = true, ["powershell.exe"] = true, ["pwsh.exe"] = true,
  }

  -- Check if the foreground process is a shell
  if shell_names[process_basename] then
    -- Safe to close
    initial_pane:send_text("exit\r")
  else
    wezterm.log_info("Active program detected. Skipping exit command for initial pane.")
  end

  -- Recreate tabs and panes from the saved state
  for _, tab_data in ipairs(workspace_data.tabs) do
    local cwd_uri = tab_data.panes[1].cwd
    local cwd_path = extract_path_from_dir(cwd_uri)

    local new_tab = window:mux_window():spawn_tab({ cwd = cwd_path })
    if not new_tab then
      wezterm.log_info("Failed to create a new tab.")
      break
    end

    -- Activate the new tab before creating panes
    new_tab:activate()

    -- Recreate panes within this tab
    for j, pane_data in ipairs(tab_data.panes) do
      local new_pane
      if j == 1 then
        new_pane = new_tab:active_pane()
      else
        local direction = 'Right'
        if pane_data.left == tab_data.panes[j - 1].left then
          direction = 'Bottom'
        end

        local pane_cwd = extract_path_from_dir(pane_data.cwd)
        new_pane = new_tab:active_pane():split({
          direction = direction,
          cwd = pane_cwd
        })
      end

      if not new_pane then
        wezterm.log_info("Failed to create a new pane.")
        break
      end

      -- Restore TTY/program (platform-aware)
      if pane_data.tty and pane_data.tty ~= "" then
        local tty = tostring(pane_data.tty)
          
        -- Only restore nvim on non-Windows or if path exists
        if tty:match("nvim$") or tty:match("vim$") then
          if not platform.is_windows or tty:match("%.exe$") then
            new_pane:send_text(tty .. " .\n")
          end
        elseif not tty:match("bash$") and not tty:match("zsh$") and not tty:match("fish$") then
          -- Don't restore shell processes, but restore other programs
          -- Skip if it's a complex command that might not work
          if not tty:match("%s") then
            new_pane:send_text(tty .. "\n")
          end
        end
      end
    end
  end

  wezterm.log_info("Workspace recreated with new tabs and panes based on saved state.")
  return true
end

--- Loads data from a JSON file.
-- @param file_path string: The file path from which the JSON data will be loaded.
-- @return table or nil: The loaded data as a Lua table, or nil if loading failed.
local function load_from_json_file(file_path)
  local file = io.open(file_path, "r")
  if not file then
    wezterm.log_info("Failed to open file: " .. file_path)
    return nil
  end

  local file_content = file:read("*a")
  file:close()

  local data = wezterm.json_parse(file_content)
  if not data then
    wezterm.log_info("Failed to parse JSON data from file: " .. file_path)
  end
  return data
end

--- Loads the saved json file matching the current workspace.
function session_manager.restore_state(window)
  local workspace_name = window:active_workspace()
  local session_dir = platform.get_session_dir()
  local separator = platform.is_windows and "\\" or "/"
  local file_path = session_dir .. separator .. "wezterm_state_" .. workspace_name .. ".json"

  local workspace_data = load_from_json_file(file_path)
  if not workspace_data then
    window:toast_notification('WezTerm',
      'Workspace state file not found for workspace: ' .. workspace_name, nil, 4000)
    return
  end

  if recreate_workspace(window, workspace_data) then
    window:toast_notification('WezTerm', 'Workspace state loaded for workspace: ' .. workspace_name,
      nil, 4000)
  else
    window:toast_notification('WezTerm', 'Workspace state loading failed for workspace: ' .. workspace_name,
      nil, 4000)
  end
end

--- Allows to select which workspace to load via an InputSelector.
function session_manager.load_state(window)
  local session_dir = platform.get_session_dir()
  local separator = platform.is_windows and "\\" or "/"
  local pattern = session_dir .. separator .. "wezterm_state_*.json"

  local files = wezterm.glob(pattern)
  if not files or #files == 0 then
    window:toast_notification("WezTerm Session Manager", "No saved sessions found", nil, 4000)
    return
  end

  local choices = {}
  for _, file_path in ipairs(files) do
    local name = file_path:match("wezterm_state_(.+)%.json$")
    if name then
      table.insert(choices, { id = file_path, label = name })
    end
  end

  if #choices == 0 then
    window:toast_notification("WezTerm Session Manager", "No saved sessions found", nil, 4000)
    return
  end

  window:perform_action(
    wezterm.action.InputSelector({
      title = "Select Session to Load",
      choices = choices,
      action = wezterm.action_callback(function(inner_window, pane, id, label)
        if not id or not label then
          return
        end

        local workspace_data = load_from_json_file(id)
        if not workspace_data then
          inner_window:toast_notification("WezTerm Session Manager",
            "Failed to load session: " .. label, nil, 4000)
          return
        end

        if recreate_workspace(inner_window, workspace_data) then
          inner_window:toast_notification("WezTerm Session Manager",
            "Session loaded: " .. label, nil, 4000)
        else
          inner_window:toast_notification("WezTerm Session Manager",
            "Failed to restore session: " .. label, nil, 4000)
        end
      end),
    }),
    window:active_pane()
  )
end

--- Orchestrator function to save the current workspace state.
-- Collects workspace data, saves it to a JSON file, and displays a notification.
function session_manager.save_state(window)
  local data = retrieve_workspace_data(window)

  -- Construct the file path based on the workspace name
  local session_dir = platform.get_session_dir()
  local separator = platform.is_windows and "\\" or "/"
  local file_path = session_dir .. separator .. "wezterm_state_" .. data.name .. ".json"

  -- Save the workspace data to a JSON file and display the appropriate notification
  if save_to_json_file(data, file_path) then
    window:toast_notification('WezTerm Session Manager', 'Workspace state saved successfully', nil, 4000)
  else
    window:toast_notification('WezTerm Session Manager', 'Failed to save workspace state', nil, 4000)
  end
end

return session_manager
