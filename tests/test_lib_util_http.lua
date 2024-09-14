local luaunit = require('luaunit')
local zeebo_util_http = require('src/lib/util/http')

function test_no_params()
    local query = zeebo_util_http.url_search_param({}, {})
    luaunit.assertEquals(query, '')
end

function test_one_param()
    local query = zeebo_util_http.url_search_param({'foo'}, {foo='bar'})
    luaunit.assertEquals(query, '?foo=bar')
end

function test_three_params()
    local query = zeebo_util_http.url_search_param({'foo', 'z'}, {foo='bar', z='zoom'})
    luaunit.assertEquals(query, '?foo=bar&z=zoom')
end

function test_four_params_with_null()
    local query = zeebo_util_http.url_search_param({'foo', 'z', 'zig'}, {foo='bar', z='zoom'})
    luaunit.assertEquals(query, '?foo=bar&z=zoom&zig=')
end

function test_create_request_overrides()
    local request = zeebo_util_http.create_request('GET', '/')
        .add_imutable_header('h1', '1')
        .add_mutable_header('h1', '2')
        .add_mutable_header('h2', '3')
        .add_imutable_header('h2', '4')
        .add_mutable_header('h2', '5')
        .add_imutable_header('h3', '6')
        .add_mutable_header('h4', '7')
        .add_custom_headers({'h3', 'h4'}, {h3='8', h4='9'})
        .add_custom_headers({'h5', 'h6'}, {h5='10', h6='11'})
        .add_imutable_header('h3', '13')
        .add_mutable_header('h5', '14')
        .add_imutable_header('h6', '15')
        .add_mutable_header('h7', '16')
        .to_http_protocol()

    luaunit.assertEquals(request, 'GET / HTTP/1.1\r\nh1: 1\r\nh2: 4\r\nh3: 6\r\nh4: 9\r\nh5: 10\r\nh6: 15\r\nh7: 16\r\n\r\n')
end

function test_create_request_conditions()
    local request = zeebo_util_http.create_request('HEAD', '/')
        .add_imutable_header('h1', '1', nil)
        .add_imutable_header('h2', '2', false)
        .add_imutable_header('h3', '3', true)
        .add_mutable_header('h4', '4', nil)
        .add_mutable_header('h5', '5', false)
        .add_mutable_header('h6', '6', true)
        .to_http_protocol()

    luaunit.assertEquals(request, 'HEAD / HTTP/1.1\r\nh1: 1\r\nh3: 3\r\nh4: 4\r\nh6: 6\r\n\r\n')
end

function test_create_request_add_body_post()
    local request = zeebo_util_http.create_request('POST', '/')
        .add_imutable_header('Content-Length', 9)
        .add_body_content('foo bar z')
        .to_http_protocol()

    luaunit.assertEquals(request, 'POST / HTTP/1.1\r\nContent-Length: 9\r\n\r\nfoo bar z\r\n\r\n')
end

function test_create_request_no_body_in_get()
    local request = zeebo_util_http.create_request('GET', '/')
        .add_body_content('foo bar z')
        .to_http_protocol()

    luaunit.assertEquals(request, 'GET / HTTP/1.1\r\n\r\n')
end

os.exit(luaunit.LuaUnit.run())
