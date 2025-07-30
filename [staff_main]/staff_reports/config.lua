-- Replace this with your actual staff check import or function
-- Example: assuming staff_commands resource exports IsStaff function

Config = {}

-- Function to check if a player is staff, calling the export from staff_commands
function Config.IsStaff(source)
    -- Use the export from staff_commands resource, adapt if needed
    if exports.staff_commands then
        return exports.staff_commands:IsStaff(source)
    end
    return false
end