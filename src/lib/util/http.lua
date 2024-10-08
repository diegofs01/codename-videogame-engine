local function is_ok(status)
    return (status and 200 <= status and status < 300) or false
end

local function is_redirect(status)
    return (status and 300 <= status and status < 400) or false
end

local function url_search_param(param_list, param_dict)
    local index, params = 1, ''
    while param_list and param_dict and index <= #param_list do
        local param = param_list[index]
        local value = param_dict[param]
        if #params == 0 then
            params = params..'?'
        else
            params = params..'&'
        end
        params = params..param..'='..(value or '')
        index = index + 1
    end
    return params
end

local function create_request(method, uri)
    local self = {
        body_content = '',
        header_list = {},
        header_dict = {},
        header_imutable = {}
    }

    self.add_body_content = function (body)
        self.body_content = self.body_content..(body or '')
        return self
    end

    self.add_imutable_header = function (header, value, cond)
        if cond == false then return self end
        if self.header_imutable[header] == nil then
            self.header_list[#self.header_list + 1] = header
            self.header_dict[header] = value
        elseif self.header_imutable[header] == false then
            self.header_dict[header] = value
        end
        self.header_imutable[header] = true
        return self
    end

    self.add_mutable_header = function (header, value, cond)
        if cond == false then return self end
        if self.header_imutable[header] == nil then
            self.header_list[#self.header_list + 1] = header
            self.header_imutable[header] = false
            self.header_dict[header] = value
        end
        return self
    end

    self.add_custom_headers = function(header_list, header_dict)
        local index = 1
        while header_list and #header_list >= index do
            local header = header_list[index]
            local value = header_dict[header]

            if self.header_imutable[header] == nil then
                self.header_list[#self.header_list + 1] = header
                self.header_imutable[header] = false
                self.header_dict[header] = value
            elseif self.header_imutable[header] == false then
                self.header_dict[header] = value
            end

            index = index + 1
        end
        return self
    end

    self.to_http_protocol = function ()
        local index = 1
        local request = method..' '..uri..' HTTP/1.1\r\n'
        
        while index <= #self.header_list do
            local header = self.header_list[index]
            local value = self.header_dict[header]
            request = request..header..': '..value..'\r\n'
            index = index + 1
        end
        
        request = request..'\r\n'

        if method ~= 'GET' and method ~= 'HEAD' and #self.body_content > 0 then
            request = request..self.body_content..'\r\n\r\n'
        end
        self = nil
        return request, function() end
    end

    self.to_curl_cmd = function ()
        local index = 1
        local request = 'curl -L \x2D\x2Dsilent \x2D\x2Dinsecure -w "\n%{http_code}" '

        if method == 'HEAD' then
            request = request..'\x2D\x2DHEAD '
        else
            request = request..'-X '..method..' '
        end
        
        while index <= #self.header_list do
            local header = self.header_list[index]
            local value = self.header_dict[header]
            request = request..'-H "'..header..': '..value..'" '
            index = index + 1
        end

        if method ~= 'GET' and method ~= 'HEAD' and #self.body_content > 0 then
            request = request..'-d \''..self.body_content..'\' '
        end

        request = request..uri

        self = nil
        return request, function() end
    end

    return self
end

return {
    is_ok=is_ok,
    is_redirect=is_redirect,
    url_search_param=url_search_param,
    create_request=create_request
}
