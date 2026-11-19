-------------------------------------------------------
-- Workspace Setup
-- 1-5 on the laptop, 6-10 on the secondary HDMI monitor
-------------------------------------------------------

local function pin_workspaces(start_id, end_id, monitor_name)
    for i = start_id, end_id do
        hl.workspace_rule({
            workspace = tostring(i),
            monitor = monitor_name
        })
    end
end

pin_workspaces(1, 5, "eDP-1")
pin_workspaces(6, 10, "HDMI-A-2")
