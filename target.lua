-- helpers definitions
--
local cjson     = require "cjson"
local upload    = require "upload"

local random    = math.random
local shm       = ngx.shared.shm

-- static definitions
-- Caution: Keep this value WAY far from client.max_body_size!
local chunksize = 1024 -- in bytes
local retries   = 1
local timeout   = 0   -- in seconds
local lockFirst = true
local lockRecv  = false

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(5000) -- in milliseconds

-- ToDo: add objects expiration!
local cliente     = '127.0.0.1'
shm:set('xchgKey','1')
shm:set(cliente, '1')


-- ToDo: handle xchgKey on receiver end
if not shm:get('xchgKey') then
    ngx.log(ngx.ERR,'[ BREAK ] Exchange key not found: ',xchgKey)
end

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.log(ngx.ERR, "failed to read: ", err)
        return
    end

    while not shm:get(cliente) and retries > 0 do
        os.execute('sleep '..timeout)
        retries = retries -1
    end
    if not shm:get(cliente) then
        ngx.log(ngx.ERR,'No receiver found on the line. Die miserably.')
        break
        ngx.exit(408)
    end


    if typ == 'body' and lockRecv then
        shm:set('toXclient_chunk', res)
        shm:set('')
    end

    if typ == "eof" then
        break
    end
end
