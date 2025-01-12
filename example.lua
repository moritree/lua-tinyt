local test = require('tinyt').create("Example test suite")

test:test("Basic math still works", function()
    test:expect(2 + 2).to_eq(4)
end)

test:test("Nil causes problems", function()
    test:expect(function() return nil + 1 end).to_throw("attempt to perform arithmetic on")
end)

test:test("This test is supposed to fail!", function()
    test:expect(function() return nil + 1 end).to_eq(1)
end)

test:test("Definitely true", function()
    test:expect(1 == 1).is_true()
end)

test:test("Number is number", function()
    test:expect(42).is_type("number")
end)

test:run()
