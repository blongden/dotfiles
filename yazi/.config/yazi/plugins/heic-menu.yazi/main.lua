--- heic-menu.yazi
--- Type-aware Enter: default `open` for everything, but for HEIC/HEIF files
--- pop a `ya.which` menu offering view / convert-to-jpg|png, saved alongside
--- or straight to the Wayland clipboard. Conversion is delegated to the
--- `heic2img` script (also bound directly to C / J / <C-y> / <C-p>).

local M = {}

-- hovered file's path, or nil in an empty directory (needs sync context)
local hovered = ya.sync(function()
	local h = cx.active.current.hovered
	return h and tostring(h.url) or nil
end)

local function is_heic(path)
	local ext = path:lower():match("%.([%w]+)$")
	return ext == "heic" or ext == "heif" or ext == "hif"
end

function M:entry()
	local path = hovered()
	if not path then
		return
	end

	if not is_heic(path) then
		ya.emit("open", { hovered = true })
		return
	end

	local choice = ya.which({
		cands = {
			{ on = "v", desc = "Open" },
			{ on = "j", desc = "JPG" },
			{ on = "y", desc = "JPG →clip" },
			{ on = "p", desc = "PNG" },
			{ on = "P", desc = "PNG →clip" },
		},
	})
	if not choice then
		return -- cancelled
	end

	if choice == 1 then
		ya.emit("open", { hovered = true })
		return
	end

	local verb = ({ [2] = "save jpg", [3] = "clip jpg", [4] = "save png", [5] = "clip png" })[choice]
	local bin = (os.getenv("HOME") or "") .. "/.local/bin/heic2img"

	ya.emit("shell", {
		string.format("%s %s %s", ya.quote(bin), verb, ya.quote(path)),
		orphan = true, -- fire-and-forget; heic2img reports via notify-send
	})
end

return M
