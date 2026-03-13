local function debugRequire(lib)
	package.loaded[lib] = nil
	return require(lib)
end

local function debugPrint(tbl)
	print(vim.inspect(tbl))
end

return {
	debugPrint = debugPrint,
	debugRequire = debugRequire
}
