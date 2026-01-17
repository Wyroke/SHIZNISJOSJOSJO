local Players = game:GetService("Players")

local WHITELIST_URL = "https://raw.githubusercontent.com/Wyroke/Whitelist/refs/heads/main/SpecWL"

local function getLocalPlayer()
    if Players.LocalPlayer then
        return Players.LocalPlayer
    end
    repeat task.wait() until Players.LocalPlayer
    return Players.LocalPlayer
end

local function isWhitelisted(userId)
    local success, data = pcall(function()
        return game:HttpGet(WHITELIST_URL, true)
    end)

    if not success or type(data) ~= "string" then
        return false
    end

    for id in data:gmatch("%d+") do
        if tonumber(id) == userId then
            return true
        end
    end

    return false
end

local player = getLocalPlayer()

if not isWhitelisted(player.UserId) then
    -- delayed kick = injector safe
    task.spawn(function()
        task.wait(1)
        player:Kick("You are not whitelisted NIGGER.")
    end)
    return
end

--// ORIGINAL LOADER
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
				'https://raw.githubusercontent.com/Wyroke/SHIZNISJOSJOSJO/' ..
				readfile('ReVape/profiles/commit.txt') .. '/' ..
				select(1, path:gsub('ReVape/', '')),
				true
			)
		end)

		if not suc or res == '404: Not Found' then
			error(res)
		end

		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end

		writefile(path, res)
	end

	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file)
			and select(1, readfile(file):find(
				'--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.'
			)) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {
	'ReVape',
	'ReVape/games',
	'ReVape/profiles',
	'ReVape/assets',
	'ReVape/libraries',
	'ReVape/guis'
} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/Wyroke/SHIZNISJOSJOSJO')
	end)

	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'

	if commit == 'main'
		or (isfile('ReVape/profiles/commit.txt')
		and readfile('ReVape/profiles/commit.txt') or '') ~= commit then

		wipeFolder('ReVape')
		wipeFolder('ReVape/games')
		wipeFolder('ReVape/guis')
		wipeFolder('ReVape/libraries')
	end

	writefile('ReVape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('ReVape/main.lua'), 'main')()
