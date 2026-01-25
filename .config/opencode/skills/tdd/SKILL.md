---
name: tdd
description: Test-driven development patterns and practices. Load when writing tests first, practicing red-green-refactor, or improving test quality and coverage.
---

## What I Do

- Guide the red-green-refactor cycle
- Structure tests for clarity and maintainability
- Select appropriate test types and assertions
- Identify testable units and boundaries
- Refactor safely with test coverage

## The TDD Cycle

```
┌─────────────────────────────────────────┐
│                                         │
│    ┌───────┐                            │
│    │  RED  │ Write a failing test       │
│    └───┬───┘                            │
│        │                                │
│        ▼                                │
│    ┌───────┐                            │
│    │ GREEN │ Write minimal code to pass │
│    └───┬───┘                            │
│        │                                │
│        ▼                                │
│    ┌──────────┐                         │
│    │ REFACTOR │ Improve without         │
│    └────┬─────┘ changing behavior       │
│         │                               │
│         └───────────────────────────────┘
```

### RED Phase

1. Write a test that describes desired behavior
2. Run the test - it MUST fail
3. Failure should be for the RIGHT reason (not syntax error)

### GREEN Phase

1. Write the SIMPLEST code that passes
2. Don't optimize, don't generalize
3. "Fake it till you make it" is valid
4. Run tests - they must pass

### REFACTOR Phase

1. Improve code structure
2. Remove duplication
3. Improve naming
4. Tests must stay green throughout

## Test Structure

### Arrange-Act-Assert (AAA)

```
// Arrange: Set up preconditions
const calculator = new Calculator();
const a = 5, b = 3;

// Act: Execute the behavior
const result = calculator.add(a, b);

// Assert: Verify the outcome
expect(result).toBe(8);
```

### Given-When-Then (BDD style)

```
describe('Calculator', () => {
  describe('when adding two numbers', () => {
    it('should return their sum', () => {
      // given
      const calc = new Calculator();
      
      // when
      const result = calc.add(2, 3);
      
      // then
      expect(result).toBe(5);
    });
  });
});
```

## Test Naming

| Pattern | Example |
|---------|---------|
| `should_X_when_Y` | `should_return_sum_when_adding_positive_numbers` |
| `X_given_Y` | `returns_empty_list_given_no_matches` |
| `test_X_Y` | `test_add_positive_numbers` |

Good test names read like specifications.

## Test Types

| Type | Scope | Speed | Use For |
|------|-------|-------|---------|
| Unit | Single function/class | Fast | Logic, calculations, transformations |
| Integration | Multiple units | Medium | Service interactions, database |
| E2E | Full system | Slow | Critical user journeys |

### The Testing Pyramid

```
        /\
       /  \      E2E (few)
      /────\
     /      \    Integration (some)
    /────────\
   /          \  Unit (many)
  /────────────\
```

## Assertion Patterns

### Equality

```javascript
expect(result).toBe(expected);          // Strict equality
expect(result).toEqual(expected);       // Deep equality
expect(result).toBeCloseTo(3.14, 2);    // Floating point
```

### Truthiness

```javascript
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeDefined();
```

### Collections

```javascript
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key', value);
```

### Exceptions

```javascript
expect(() => riskyOperation()).toThrow();
expect(() => riskyOperation()).toThrow(SpecificError);
expect(() => riskyOperation()).toThrow('message');
```

### Async

```javascript
await expect(asyncFn()).resolves.toBe(value);
await expect(asyncFn()).rejects.toThrow();
```

## Test Doubles

| Double | Purpose | Use When |
|--------|---------|----------|
| Stub | Returns canned data | Need predictable input |
| Mock | Verifies interactions | Testing side effects |
| Spy | Wraps real implementation | Partial observation |
| Fake | Simplified implementation | Complex dependency (e.g., in-memory DB) |

### When to Use

- **Stub external services**: APIs, databases, file system
- **Mock for verification**: "Was this method called with these args?"
- **Don't mock what you own**: Test real implementations when feasible

## Common Patterns

### Testing Edge Cases

Always test:
- Empty inputs (null, undefined, [], "")
- Boundary values (0, -1, MAX_INT)
- Invalid inputs (wrong type, malformed)
- Single item collections
- Duplicate values

### Testing Errors

```javascript
it('throws when dividing by zero', () => {
  expect(() => calculator.divide(10, 0))
    .toThrow('Division by zero');
});
```

### Testing Async Code

```javascript
it('fetches user data', async () => {
  const user = await userService.getById(1);
  expect(user.name).toBe('Alice');
});
```

### Parameterized Tests

```javascript
describe.each([
  [1, 1, 2],
  [2, 3, 5],
  [0, 0, 0],
])('add(%i, %i)', (a, b, expected) => {
  it(`returns ${expected}`, () => {
    expect(add(a, b)).toBe(expected);
  });
});
```

## Refactoring Safely

### Prerequisites

- [ ] All tests passing
- [ ] Sufficient coverage of code being changed
- [ ] Tests are trustworthy (not false positives)

### Safe Refactoring Steps

1. Run tests - ensure green
2. Make ONE small change
3. Run tests - ensure still green
4. Repeat

### Common Refactorings

| Refactoring | TDD Safety |
|-------------|------------|
| Rename | Safe - tests verify behavior unchanged |
| Extract function | Safe - existing tests still pass |
| Change signature | Update tests first (new RED phase) |
| Delete code | Tests prove it's unused if they pass |

## TDD Anti-patterns

- **Test after**: Writing tests after implementation misses design benefits
- **Testing implementation**: Asserting on internals, not behavior
- **Excessive mocking**: Tests coupled to implementation details
- **Slow tests**: Feedback loop too long, TDD abandoned
- **Flaky tests**: Non-deterministic tests erode trust
- **One assertion per test taken too far**: Related assertions can group
- **Testing private methods**: Test through public interface

## Checklist

Before marking a TDD cycle complete:

```
[ ] Test written BEFORE implementation
[ ] Test failed for the RIGHT reason
[ ] Implementation is minimal (no premature optimization)
[ ] All tests pass
[ ] Code refactored for clarity
[ ] Tests still pass after refactoring
[ ] Test names describe behavior
[ ] Edge cases covered
```
