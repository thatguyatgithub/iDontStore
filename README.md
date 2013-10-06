About iDontStore
================

 iDontStore is a tiny piece of software that acts as a benevolent Man-In-The-Midle service that allows to parties that are unable to talk directly to each other to exchange a file via HTTP/HTTPS on two simple steps.

 Built upon the high performance [nginx] HTTP server, using the [embedded Lua interpreter](http://wiki.nginx.org/HttpLuaModule). The nginx Lua module, ngx lua, embeds Lua, via the standard Lua interpreter or LuaJIT 2.0, into Nginx and by leveraging Nginx's subrequests, allows the integration of the powerful Lua threads (Lua coroutines) into the Nginx event model.

 This is a [PoC](https://en.wikipedia.org/wiki/Proof_of_concept) of how the ngx lua stack can be used to build relatively small yet extremely high performance applications over the very HTTP server stack.


Status
======

 As a PoC application, iDontShare is a work in progress. Basic functionality is provided, although it should be carefully used.
 

Architecture
============

 As its name suggests it, this software does not store the file at any time, but buffers it between the two parties on a non-persistant fashion using the featureful and lightweight nginx's shared memory architecture between different nginx threads. 

 Once a receiver or a person willing to receive a file (initiator), requests a safe-conduct, a temporal shared key is assigned to the whole session for a small period of time (Session Lifetime). At that time, the sender (or target) starts sending chunks of data using a binary HTTP POST.
 The sender then waits for reception confirmation (AckRecv flag) on the receiver end and starts pushing another chunk. This repeats until the whole file is transfer as specified by "boundary" and "content-length" values describes.

 Built using the [lua-resty-upload](https://github.com/agentzh/lua-resty-upload) upload handler for buffered reading, created by the genius Yichun "agentzh" Zhang, internally relying on the ngx lua Cosocket API, granting a 100% non-blocking behavior. 
 

Steps
=====

 TODO

See Also
========
* the ngx lua module: http://wiki.nginx.org/HttpLuaModule
* the [lua-resty-redis](https://github.com/agentzh/lua-resty-redis) library
* the redis wired protocol specification: http://redis.io/topics/protocol
* the [lua-resty-memcached](https://github.com/agentzh/lua-resty-memcached) library
