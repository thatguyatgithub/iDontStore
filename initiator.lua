-- helpers definitions
--
local cjson     = require "cjson"
local upload    = require "upload"

local random    = math.random
local shm       = ngx.shared.shm

-- static definitions
-- Caution: Keep this value WAY far from client.max_body_size!
local retries   = 3
local timeout   = 1   -- in seconds

-- Status code table
--
-- If exists, initiator is assumed active for 'session lifetime' (expiration key)
-- 0 = Initiator HELOed and is holding on its end
-- 1 = Target pushed chunk and Initiator is ready to pick it up
-- 2 = Initiator is waiting for data
-- 3 = Completed, both ends are done
-- else = error

-- ToDo: add objects expiration!
local cliente     = '127.0.0.1'
shm:set(cliente, '0')

-- Give the target some time to fire up
os.execute('sleep 2')

-- Initiator download loop
while true do

    -- Repeat until no data or timeout
    while not shm:get(cliente) == 1 and retries > 0 do
        ngx.log(ngx.ERR,'No data pending to pull yet')
        retries = retries - 1
        os.execute('sleep ',timeout)
        ngx.log(ngx.ERR, 'loop segundo ')
    end

    -- Changui for synchronization issues or network latency
    os.execute('sleep 0.5')

    if shm:get(cliente) ~= 1 then
        ngx.say('ERROR, Remote End Timeout.')
        ngx.flush()
        shm:delete(cliente)
        ngx.exit(408)

    elseif shm:get(cliente) == 1 then
        ngx.say(shm:get('toXclient_chunk'))
        ngx.flush()
        shm:set(cliente,2)
        ngx.log(ngx.ERR,'Client read chunk. Yummy yummy!')
    elseif shm:get(cliente) == 3 then
        ngx.log(ngx.ERR, 'No more data to be pulled. DONE! :D    ')
        shm:delete(cliente)
        break
    end

    ngx.log(ngx.ERR, 'loopeeaaaaaaa ')
end