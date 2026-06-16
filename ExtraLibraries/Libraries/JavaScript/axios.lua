-- Copy of Axios from JavaScript for Luau (MacFries Hub!): https://www.npmjs.com/package/axios
--
-- MacFries Axios Version: 0.875.885 - BETA CHANNEL!

local Promise = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Libraries/JavaScript/Promise.lua'))()

local validate
validate = function(table, template)
    if typeof(table) ~= "table" then
        return template
    end

    for k, v in template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            table[k] = validate(table[k], v)
        elseif table[k] == nil then
            table[k] = v
        end
    end

    return table
end

local function toRequestTable(tbl, type)
    if type == 'request' then
        return {
            Url = tbl.url,
            Method = tbl.method
        }
    end
end

local function makeStatusReport(info, type)
    if type == 'AxiosError' then
        return {
            name = 'AxiosError',
            message = string.format('timeout of %sms exceeded', tostring(info.timeout)),
            code = 'ECONNABORTED',
            status = 408,

            config = info,
            
            response = nil
        }
    elseif type == 'AxiosResult' then
        return {
            data = info.Body,
            status = info.StatusCode,
            statusText = info.StatusMessage,
            headers = info.Headers,
            config = info.config
        }
    end
end


local axios = {}
axios.__index = axios

function axios.get(url, config)
    return Promise.new(function(res, rej)
        config = validate(config, {
            timeout = 0
        })

        local result = {}
        local timeout = config.timeout

        local timeoutThread
        local requestThread = task.spawn(function()
            if request then
                local response = request(toRequestTable({
                    url = url,
                    method = 'GET'
                }, 'request'))

                res(makeStatusReport({
                    Body = response.Body,
                    StatusCode = response.StatusCode,
                    StatusMessage = response.StatusMessage,
                    Headers = response.Headers,
                    config = config
                }, 'AxiosResult'))
            end

            if timeoutThread and coroutine.status(timeoutThread) == 'running' then
                task.cancel(timeoutThread)
            end
        end)

        if timeout > 0 then
            timeoutThread = task.delay(timeout / 1000, function()
                if coroutine.status(requestThread) == 'running' then
                    task.cancel(requestThread)
                end

                res(makeStatusReport(config, 'AxiosError'))
            end)
        end
    end)
end

return axios
