-- Globals provided by AnimatedSprite.
--
-- This file can be used by toyboypy (https://toyboxpy.io) to import into a project's luacheck config.
--
-- Just add this to your project's .luacheckrc:
--    require "toyboxes/luacheck" (stds, files)
--
-- and then add 'toyboxes' to your std:
--    std = "lua54+playdate+toyboxes"

return {
    globals = {
        AnimatedSprite = {
            fields = {
                super = {
                    fields = {
                        className = {},
                        init = {}
                    }
                },
                className = {},
                init = {},
                new = {},
                playAnimation = {},
                pauseAnimation = {},
                toggleAnimation = {},
                stopAnimation = {},
                loadStates = {},
                getCurrentFrameIndex = {},
                getLocalStates = {},
                copyLocalStates = {},
                setStates = {},
                addState = {},
                changeState = {},
                forceNextAnimation = {},
                setDefaultState = {},
                printAllStates = {},
                updateAnimation = {},
                update = {}
            }
        }
    }
}
