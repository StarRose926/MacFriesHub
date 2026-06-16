local function switch(expression)
    local s = {
        _cases = {},
        _default = function() end,
        _found_match = false
    }

    function s:case(obj, onMatch)
        if obj == expression and not self._on_found_match then
            self._found_match = true
            onMatch()
        end

        return s
    end

    function s:default(on)
        if not self._found_match then
            self._on_found_match = true
            on()
        end
    end

    return s
end

return switch
