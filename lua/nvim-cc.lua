local M = {}

local enable_auto = false
function M.change_auto_read(input)
    enable_auto = input
end

function M.set_compile_command_from_file()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    local file_path = directory .. "/nvim-cc.txt"
    local success, file_content = pcall(vim.fn.readfile, file_path)

    if success and #file_content > 0 then
        GLOBAL_compile_command = file_content[1]
        print("nvim-cc : ".. GLOBAL_compile_command)
    end
end

function M.input_compile_command()
    if GLOBAL_compile_command == nil then
        GLOBAL_compile_command = ""
    end
    local compile_command = vim.fn.input("Enter Compile command : ", GLOBAL_compile_command)
    if compile_command ~= "" then
        GLOBAL_compile_command = compile_command
    end
end

function M.run_compile_command()
    if GLOBAL_compile_command == "" or GLOBAL_compile_command == nil then
        print("There is no compile command specified!")
        return
    end
    local cmd = "split | terminal echo \"> " .. GLOBAL_compile_command .. "\" && " .. GLOBAL_compile_command
    vim.cmd(cmd)
    vim.cmd("startinsert")
end

function M.run_compile_command_silent()
    if GLOBAL_compile_command == "" or GLOBAL_compile_command == nil then
        print("There is no compile command specified!")
        return
    end
    local cmd = ":!"..GLOBAL_compile_command
    vim.cmd(cmd)
end

function M.sync_directory_to_buffer()
        local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    vim.cmd('cd ' .. directory)
    M.set_compile_command_from_file()
    print('cwd : ' .. directory .. ' | nvim-cc : ' .. GLOBAL_compile_command)
end


-- AUTOMATICALLY READ ``nvim-cc.txt`` WHEN CHANGING BUFFER WHICH I DONT LIKE BUT ITS POSSIBLE
if enable_auto == true then
    vim.api.nvim_exec([[
    autocmd BufEnter * lua require('nvim-cc').set_compile_command_from_file()
    ]], false)
end

return M
