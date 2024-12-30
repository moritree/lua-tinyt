A short, sweet, simple unit test framework for Lua. Refer to `example.lua` for usage.

# Creating a test suite
Import the test script.

```
local test = require('lunit').create()
```

Register tests with `test:test(name, fn)`. Write your test code in `fn`, and use `test:expect()` statements to make your assertions.

```
test:test("True is true", function()
  test:expect(true).is_true()
end)

test:test("Basic maths is real", function()
  test:expect(2 + 2).to_eq(4)
)
```

Run your registered tests.

```
test:run()
```
