---
name: tdd-workflow
description: "Full test-driven development cycle: Red-Green-Refactor. Write tests first, then implement, then clean up. Use when: building new features with high confidence, or enforcing disciplined development practices."
level: advanced
category: testing
---

# TDD Workflow

Build features by writing tests first, then making them pass.

## When to Use

- Building a new feature from scratch
- Fixing a bug (write a test that reproduces it first)
- Working on critical business logic (payments, auth, data processing)
- When you want high confidence that code works correctly

## How It Works

### The Cycle: Red → Green → Refactor

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│   RED    │───→│  GREEN   │───→│ REFACTOR │───→ repeat
│Write test│    │Make pass │    │Clean up  │
│(fails)   │    │(minimal) │    │(tests ✓) │
└──────────┘    └──────────┘    └──────────┘
```

### Step 1: RED — Write a Failing Test

Start with what the code SHOULD do, not what it does:

```typescript
// Start from the user's perspective
describe('ShoppingCart', () => {
  it('starts empty', () => {
    const cart = new ShoppingCart()
    expect(cart.items).toEqual([])
    expect(cart.total).toBe(0)
  })

  it('adds an item', () => {
    const cart = new ShoppingCart()
    cart.add({ id: '1', name: 'Widget', price: 9.99, quantity: 1 })
    expect(cart.items).toHaveLength(1)
    expect(cart.total).toBe(9.99)
  })

  it('increases quantity when adding the same item', () => {
    const cart = new ShoppingCart()
    cart.add({ id: '1', name: 'Widget', price: 9.99, quantity: 1 })
    cart.add({ id: '1', name: 'Widget', price: 9.99, quantity: 1 })
    expect(cart.items).toHaveLength(1)
    expect(cart.items[0].quantity).toBe(2)
    expect(cart.total).toBe(19.98)
  })

  it('applies percentage discount', () => {
    const cart = new ShoppingCart()
    cart.add({ id: '1', name: 'Widget', price: 100, quantity: 1 })
    cart.applyDiscount({ type: 'percentage', value: 10 })
    expect(cart.total).toBe(90)
  })

  it('does not allow negative totals', () => {
    const cart = new ShoppingCart()
    cart.add({ id: '1', name: 'Widget', price: 10, quantity: 1 })
    cart.applyDiscount({ type: 'fixed', value: 50 })
    expect(cart.total).toBe(0) // floor at 0, not -40
  })
})
```

Run the tests — they should ALL FAIL (red). If any pass, the test isn't testing new behavior.

### Step 2: GREEN — Make Tests Pass

Write the minimum code to pass each test:

```typescript
interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
}

interface Discount {
  type: 'percentage' | 'fixed'
  value: number
}

class ShoppingCart {
  items: CartItem[] = []
  private discount?: Discount

  get total(): number {
    const subtotal = this.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
    if (!this.discount) return subtotal
    if (this.discount.type === 'percentage') {
      return Math.max(0, subtotal * (1 - this.discount.value / 100))
    }
    return Math.max(0, subtotal - this.discount.value)
  }

  add(item: CartItem) {
    const existing = this.items.find(i => i.id === item.id)
    if (existing) {
      existing.quantity += item.quantity
    } else {
      this.items.push({ ...item })
    }
  }

  applyDiscount(discount: Discount) {
    this.discount = discount
  }
}
```

Run tests — they should ALL PASS (green). Don't optimize yet.

### Step 3: REFACTOR — Clean Up

Now improve the code while keeping tests green:

- Extract helper functions
- Remove duplication
- Improve naming
- Simplify logic

Run tests after EVERY change. If they break, undo immediately.

### Test Coverage Targets

| Type | Target | What to cover |
|------|--------|--------------|
| Unit tests | 80%+ | Pure functions, business logic, utilities |
| Integration | Key paths | API endpoints, database operations |
| E2E | Critical flows | Login, checkout, core user journeys |

### Edge Cases to Always Test

```
- Empty input ([], '', null, undefined)
- Boundary values (0, 1, max, min)
- Invalid input (wrong type, missing fields)
- Error conditions (network failure, timeout)
- Concurrent operations (race conditions)
```

## Process Summary

```
1. Write ONE test (should fail)
2. Write MINIMUM code to pass it
3. Run all tests (should pass)
4. Refactor if needed (tests must stay green)
5. Commit
6. Write NEXT test → repeat
```

## Examples

```
> Build a user registration system using TDD
> Implement a pagination utility with TDD
> Create a permission system — tests first
```
