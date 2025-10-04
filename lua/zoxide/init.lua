local M = {}

function M.cd_highest_ranked(opts)
  -- FIX: Handle case where flags(--help, etc.) are passed in as query
  local query = opts.args

  -- Handle empty query
  if query == "" then
    vim.notify("Usage: :Z <query>", vim.log.levels.WARN)
    return
  end

  vim.system(
    { "powershell", "-c", "zoxide query " .. query },
    { text = true },
    function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify("zoxide: no match found for '" .. query .. "'", vim.log.levels.ERROR)
        else
          local path = vim.trim(res.stdout or "")
          if path ~= "" then
            vim.cmd.tcd(path)
            vim.notify("Changed directory to:\n" .. path, vim.log.levels.INFO)
          else
            vim.notify("No directory found for query: " .. query, vim.log.levels.WARN)
          end
        end
      end)
    end
  )
end

-- TODO: Telescope integration
-- Below is the plan for this plugin
-- Lazy load the plugin
-- cmd: Z <query>
-- notify: Zoxide: On it!
-- do below asynchronously
-- if(zoxide_suggestions.len > 1 and telescope_available) then
--    launch telescope with suggestions
-- else try tcd <zoxide_suggestions[0]>
-- Notify error/success
-- Only work for windows support now
vim.api.nvim_create_user_command('Z', M.cd_highest_ranked, {
  nargs = 1,
  desc = "Navigate to directory using zoxide"
})

return M
