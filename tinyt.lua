--[[
Copyright 2024 Zuni Leone

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local M = {}

local color = {
    green = '\27[32m',
    red = '\27[31m',
    white = '\27[0m'
}

local function colored(str, col)
    return string.format("%s%s%s", col, str, color.white)
end

local function deep_eq(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end

    local seen = {}
    for k, v in pairs(a) do
        if not deep_eq(v, b[k]) then return false end
        seen[k] = true
    end

    for k in pairs(b) do
        if not seen[k] then return false end
    end

    return true
end

local TestRunner = {
    tests = {},
    before_each = function() end,
    after_each = function() end,
    setup = function() end,
    teardown = function() end,
}

-- Create a new test suite
function TestRunner:new(suite_name)
    local o = { tests = {}, results = {}, name = suite_name }
    setmetatable(o, { __index = self })
    return o
end

function TestRunner:test(name, fn)
    table.insert(self.tests, { name = name, fn = fn })
end

function TestRunner:expect(actual)
    return {
        is_true = function() return type(actual) == "boolean" and actual == true end,
        is_false = function() return type(actual) == "boolean" and actual == false end,
        to_eq = function(expected)
            if not deep_eq(actual, expected) then
                error(string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
            end
        end,
        to_throw = function(expected_err)
            local ok, err = pcall(actual)
            if ok then error("expected error, got success") end
            if expected_err and not string.match(err, expected_err) then
                error(string.format("expected error matching '%s', got '%s'", expected_err, err))
            end
        end,
        is_type = function(expected_type)
            return type(actual) == expected_type
        end
    }
end

function TestRunner:run()
    local results = { passed = {}, failed = {}, details = {} }

    self.setup()
    for ind, test in ipairs(self.tests) do
        local ok, err = xpcall(function()
            self.before_each()
            test.fn()
            self.after_each()
        end, debug.traceback)

        if ok then
            table.insert(results.passed, { status = colored("PASS", color.green), name = test.name, id = ind })
        else
            table.insert(results.failed, { status = colored("FAIL", color.red), error = err, name = test.name, id = ind })
        end
    end
    self.teardown()

    print(string.format("Ran %d tests%s...\t%s: %d, %s: %d", #results.passed + #results.failed,
        (self.name and string.format(" in %s", self.name) or ""),
        colored("Passed", color.green), #results.passed, colored("Failed", color.red), #results.failed))

    for _, pass in ipairs(results.passed) do
        print(string.format("[%d] %s:\t%s", pass.id, pass.status, pass.name))
    end

    for _, fail in ipairs(results.failed) do
        print(string.format("[%d] %s:\t%s\n%s", fail.id, fail.status, fail.name, colored(fail.error, color.red)))
    end
end

function M.create(suite_name)
    return TestRunner:new(suite_name)
end

return M
