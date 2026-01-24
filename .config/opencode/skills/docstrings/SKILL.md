---
name: docstrings
description: Creates and updates code documentation including docstrings, JSDoc, inline comments, and type annotations. Load when documenting functions, classes, methods, or adding comments to code files.
---

# Code Documentation

Create clear, accurate documentation directly in source code files.

## Documentation Types

| Type | Use For |
|------|---------|
| Docstrings | Functions, classes, methods, modules |
| JSDoc/TSDoc | JavaScript/TypeScript functions and types |
| Inline comments | Complex logic, algorithms, non-obvious decisions |
| Type annotations | Parameter and return types |

## Style Rules

- Start descriptions with a verb (Returns, Creates, Validates, Calculates)
- Document the "why" for complex logic, not the "what"
- Include practical examples that can be copy-pasted
- Match existing project conventions

## What NOT to Document

- Self-explanatory code (`i++`, simple getters/setters)
- Private implementation details (unless complex)
- Obvious variable names
- Temporary or debugging code

## Language Patterns

### Python

```python
def calculate_total(base_price: float, tax_rate: float, discount: float = 0) -> float:
    """
    Calculate the total price including tax and discounts.

    Args:
        base_price: The original price before modifications
        tax_rate: Tax rate as a decimal (e.g., 0.08 for 8%)
        discount: Optional discount amount to subtract (default: 0)

    Returns:
        The final calculated price

    Raises:
        ValueError: If base_price or tax_rate is negative

    Example:
        >>> calculate_total(100, 0.08, 10)
        97.2
    """
```

### JavaScript/TypeScript (JSDoc)

```javascript
/**
 * Calculates the total price including tax and discounts.
 *
 * @param {number} basePrice - The original price before modifications
 * @param {number} taxRate - Tax rate as a decimal (e.g., 0.08 for 8%)
 * @param {number} [discount=0] - Optional discount amount to subtract
 * @returns {number} The final calculated price
 * @throws {Error} If basePrice or taxRate is negative
 *
 * @example
 * const total = calculateTotal(100, 0.08, 10);
 * // Returns: 97.2
 */
```

### Go

```go
// CalculateTotal computes the total price including tax and discounts.
//
// It applies the tax rate to the base price, then subtracts the discount.
// Returns an error if basePrice or taxRate is negative.
func CalculateTotal(basePrice, taxRate, discount float64) (float64, error) {
```

### Rust

```rust
/// Calculates the total price including tax and discounts.
///
/// # Arguments
///
/// * `base_price` - The original price before modifications
/// * `tax_rate` - Tax rate as a decimal (e.g., 0.08 for 8%)
/// * `discount` - Optional discount amount to subtract
///
/// # Returns
///
/// The final calculated price
///
/// # Errors
///
/// Returns `PriceError` if base_price or tax_rate is negative
///
/// # Examples
///
/// ```
/// let total = calculate_total(100.0, 0.08, 10.0)?;
/// assert_eq!(total, 97.2);
/// ```
```

## Inline Comments

Use sparingly for:

```python
# Use binary search here because the list is always sorted
# and can contain millions of items
index = bisect.bisect_left(sorted_items, target)

# HACK: API returns dates in inconsistent formats
# TODO: Remove after API v2 migration (ticket #1234)
parsed_date = try_parse_multiple_formats(date_string)
```

## Checklist

Before completing code documentation:

- [ ] All public functions/methods have docstrings
- [ ] Parameters and return types are documented
- [ ] Edge cases and exceptions are noted
- [ ] Examples are included for non-trivial functions
- [ ] Complex algorithms have explanatory comments
- [ ] Matches project's existing documentation style
