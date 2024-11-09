local M = {}

Nvim_cc_term_buffn = nil

if Nvim_cc_split_size == nil then
    Nvim_cc_split_size = 15
end

if Nvim_cc_auto_read == nil then
    Nvim_cc_auto_read = false
end

if Nvim_cc_auto_sync == nil then
    Nvim_cc_auto_sync = false
end

if Nvim_cc_file_name == nil or Nvim_cc_file_name == "" then
    Nvim_cc_file_name = "nvim-cc.txt"
end

if Nvim_cc_blacklist_dir_name == nil or Nvim_cc_blacklist_dir_name == "" then
    Nvim_cc_blacklist_dir_name = {"src"}
end

function M.set_compile_command_from_file()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    for i = 1, #Nvim_cc_blacklist_dir_name, 1 do
        local item = Nvim_cc_blacklist_dir_name[i]
        if directory:sub(-#item -1) == "/" .. item then
            directory = directory:sub(1, -#item - 2)
        end
    end

    local file_path = directory .. "/" .. Nvim_cc_file_name
    local success, file_content = pcall(vim.fn.readfile, file_path)

    if success and #file_content > 0 then
        Nvim_cc_compile_command = ""
        for index in pairs(file_content)
        do
            if Nvim_cc_compile_command ~= nil and Nvim_cc_compile_command ~= "" then
                Nvim_cc_compile_command = Nvim_cc_compile_command .. " && " .. file_content[index]
            else
                Nvim_cc_compile_command = file_content[index]
            end
        end
        print("nvim-cc : ".. Nvim_cc_compile_command)
    end
end

function M.input_compile_command()
    if Nvim_cc_compile_command == nil then
        Nvim_cc_compile_command = ""
    end
    local compile_command = vim.fn.input({
        prompt = "Enter Compile command : ",
        default = Nvim_cc_compile_command,
        completion = "shellcmd",
        wildchar = vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
    })
    if compile_command ~= "" then
        Nvim_cc_compile_command = compile_command
    end
end

function M.run_compile_command()
    if Nvim_cc_compile_command == "" or Nvim_cc_compile_command == nil then
        print("There is no compile command specified!")
        return
    end

    local split_mode
    if Nvim_cc_vsplit_mode == nil or Nvim_cc_vsplit_mode == false then
        Nvim_cc_vsplit_mode = false
        split_mode = "split"
    else
        split_mode = "vsplit"
    end
    local cmd = Nvim_cc_split_size .. split_mode .. " | terminal echo \"> " .. Nvim_cc_compile_command .. "\" && " .. Nvim_cc_compile_command
    vim.cmd(cmd)
    Nvim_cc_term_buffn = vim.api.nvim_get_current_buf()
    vim.cmd("startinsert")
end

function M.run_compile_command_silent()
    if Nvim_cc_compile_command == "" or Nvim_cc_compile_command == nil then
        print("There is no compile command specified!")
        return
    end
    local cmd = ":!"..Nvim_cc_compile_command
    vim.cmd(cmd)
end

function M.sync_directory_to_buffer()
    if vim.bo.filetype == 'netrw' or vim.b.netrw_bufnr then
        return
    end
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    for i = 1, #Nvim_cc_blacklist_dir_name, 1 do
        local item = Nvim_cc_blacklist_dir_name[i]
        if directory:sub(-#item -1) == "/" .. item then
            directory = directory:sub(1, -#item - 2)
        end
    end

    vim.cmd('cd ' .. directory)
    print('cwd : ' .. directory)
end

function M.export_compile_command()
    local file = io.open(Nvim_cc_file_name, "w")
    if file ~= nil then
        file:write(Nvim_cc_compile_command)
        print("Saved " .. Nvim_cc_file_name)
    else
        print("Failed to export " .. Nvim_cc_file_name)
    end
end

function M.jump_to_error_position()
    local line = vim.fn.getline(".")
    local file, line_num, col_num = line:match("([^:]+):(%d+):(%d+)")
    if col_num == nil or col_num == "" then
        file, line_num = line:match("([^:]+):(%d+)")
        col_num = 1
    end
    if file and line_num then
        -- `0` to get the current one
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf ~= Nvim_cc_term_buffn then
                vim.api.nvim_set_current_win(win)
                break
            end
        end

        -- `0` to get the current one
        file = file:match("^%s*(.-)%s*$")
        file = vim.fn.getcwd() .. "/" .. file
        if vim.api.nvim_buf_get_name(0) ~= file then
            vim.cmd("edit " .. file)
        end

        vim.api.nvim_win_set_cursor(0, {tonumber(line_num), tonumber(col_num) - 1})
    else
        print("nvim-cc : not a valid jump pattern.")
    end
end

if Nvim_cc_auto_read == true then
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("nvim-cc-autoread", {clear = true}),
        callback = function ()
            M.set_compile_command_from_file()
        end
    })
end

if Nvim_cc_auto_sync == true then
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("nvim-cc-autosync", {clear = true}),
        callback = function ()
            M.sync_directory_to_buffer()
        end
    })
end

return M
