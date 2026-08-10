--[[
    -> annotations
    -> forcing types
]]

function ispositive(x: number): boolean
    return x >0 
end
local result: boolean = ispositive(1)
result = ispositive(3)

print(result)

--[[
    string literals
    "\xAB"
    "\u{ABC}"
    "\z"
]]
print("\\x literals:")

for i = 1, 24 do
    print(string.char(i))
end
print("\\u{ABC} literals:")

 print(utf8.char(128512))

--[[

    -> number literals that are supported
    0xABC
    0b01010101
    1_048_576
    0xFFFF_FFFF
    0b_0101_0101
]]
print(0xABC)
print(0b01010101)
print(1_048_576)
print(0xDEAD_BEEF)
print(0b_0101_0101)

--[[
    if not true then

    end

    repeat 
        do end
    until true

    compound statements:
    -> +=
    -> -=
    -> *=   multiplication
    -> /=   division
    -> //=  floor division
    -> %= mod
    -> ^=   exponentation
    -> ..= concatenation
]]

--annotation
function foo(x: number, y: string): boolean 
    local k: string = y:rep(x)
    return k == "a"
end

--type cast
function foo2(x: number, y: string): boolean 
    local k = (y :: string):rep(x)
    return k == "a"
end
local no_returns: (number, string) -> ()

-- annotation

function foo(x: number)

print(foo(6,"a"))

local array: {
    [number]: string
}
local object{
    x: number, 
    y: string
}

--[[
    Lua uses standard lua syntax

    for vars in values do

    end
]]

local obj = {items = {1,4,9}}
setmetatable(obj, { __iter = function(o) return next, o.items end})
