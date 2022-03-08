-- stub out require

function require()
	-- do nothing
end





-- replace 'os' functionality

os = {}

function os.clock()
	return playdate.getCurrentTimeMilliseconds() // 1000
end

function os.getenv()
	return nil
end

function os.date(arg)
	return nowAsString()
end

function os.exit(value)
    if playdate.isSimulator then
	    playdate.simulator.exit(value)
    end
end

function nowAsString()
	local now = playdate.getTime()
	local nowString = now.year.."-"..now.month.."-"..now.day.." "..now.hour..":"..now.minute..":"..now.second
	return nowString
end


-- replace 'io' functionality

io = {}
io.stdout = {}

function io.stdout:write(...)
	print(...)
end

function io.open(filename, readwrite)
	local fileOpenAttr = nil
	if readwrite == 'w' then
		fileOpenAttr = playdate.file.kFileWrite
	elseif readwrite == 'r' then
		fileOpenAttr = playdate.file.kFileRead
	elseif readwrite == 'a' then
		fileOpenAttr = playdate.file.kFileAppend
	end
	local fd = playdate.file.open(filename, fileOpenAttr)
	assert(fd)
	return fd
end

function skipDueToIssue(issueURL)

	local debugInfo = debug.getinfo(2)
	local skipMessage = string.format("\n%s:%d Test SKIPPED due to issue %s", debugInfo.short_src, debugInfo.currentline, issueURL)
	print(skipMessage)

end
