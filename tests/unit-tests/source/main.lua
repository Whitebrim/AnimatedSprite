import 'luaunit/playdate_luaunit_fix'
import 'luaunit/luaunit'
import '../../../AnimatedSprite.lua'
import 'tests'

-- turns off updating
playdate.stop()
playdate.graphics.drawText("*TEST*", 180, 110)
playdate.graphics.drawText("open console", 152, 130)
-- when outputting a table, include a table address
luaunit.PRINT_TABLE_REF_IN_ERROR_MSG = true

-- process the command line args (if any)
local testOutputFilename = "test_output"
local outputType = "text"
local luaunit_args = {'--output', 'text', '--verbose', '-r'}

-- run the tests
local returnValue = luaunit.LuaUnit.run(table.unpack(luaunit_args))

print("unit test return value = "..returnValue)

if (returnValue == 0) then
    playdate.graphics.drawText("*SUCCESS*", 166, 180)
else
    playdate.graphics.drawText("*FAIL*", 185, 180)
end