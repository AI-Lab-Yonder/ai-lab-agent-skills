---
name: refactorer
description: |
  Clean up and improve existing code safely. Restructure without changing
  behavior. Use when: code is messy, duplicated, hard to read, or needs
  modernization.
level: beginner
category: code-quality
---

# Refactorer

Improve code quality without changing what it does.

## When to Use

- Code is hard to read or understand
- Functions are too long (> 30 lines)
- Copy-pasted code in multiple places
- Outdated patterns that have modern alternatives
- Preparing code for a new feature (clean first, build second)

## How It Works

### 1. Safety First

Before touching anything:

```bash
# Make sure tests pass
npm test

# Check for uncommitted changes
git status

# Create a branch
git checkout -b refactor/clean-up-user-service
```

**Rule: Every refactoring step must keep tests green.**

### 2. Common Refactoring Patterns

#### Extract Function

```typescript
// Before: long function doing too much
function processOrder(order: Order) {
  // validate
  if (!order.items.length) throw new Error('Empty order')
  if (!order.customer) throw new Error('No customer')

  // calculate
  let total = 0
  for (const item of order.items) {
    total += item.price * item.quantity
  }
  if (total > 100) total *= 0.9 // 10% discount

  // save
  db.orders.create({ ...order, total })
  sendEmail(order.customer.email, 'Order confirmed')
}

// After: small, focused functions
function validateOrder(order: Order) {
  if (!order.items.length) throw new Error('Empty order')
  if (!order.customer) throw new Error('No customer')
}

function calculateTotal(items: OrderItem[]): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  return subtotal > 100 ? subtotal * 0.9 : subtotal
}

function processOrder(order: Order) {
  validateOrder(order)
  const total = calculateTotal(order.items)
  db.orders.create({ ...order, total })
  sendEmail(order.customer.email, 'Order confirmed')
}
```

#### Remove Duplication

```typescript
// Before: repeated logic
function getActiveUsers() {
  const users = db.users.findMany()
  return users.filter(u => u.status === 'active' && !u.deletedAt)
}
function getActiveAdmins() {
  const users = db.users.findMany({ where: { role: 'admin' } })
  return users.filter(u => u.status === 'active' && !u.deletedAt)
}

// After: shared filter
function isActive(user: User): boolean {
  return user.status === 'active' && !user.deletedAt
}
function getActiveUsers() {
  return db.users.findMany().then(users => users.filter(isActive))
}
function getActiveAdmins() {
  return db.users.findMany({ where: { role: 'admin' } }).then(users => users.filter(isActive))
}
```

#### Simplify Conditionals

```typescript
// Before: nested ifs
function getDiscount(user: User, total: number) {
  if (user.isPremium) {
    if (total > 100) {
      return 0.2
    } else {
      return 0.1
    }
  } else {
    if (total > 100) {
      return 0.05
    } else {
      return 0
    }
  }
}

// After: early returns or lookup
function getDiscount(user: User, total: number): number {
  if (user.isPremium && total > 100) return 0.2
  if (user.isPremium) return 0.1
  if (total > 100) return 0.05
  return 0
}
```

### 3. Process

```
1. Read the code, understand what it does
2. Run tests — make sure they pass
3. Make ONE refactoring change
4. Run tests — confirm they still pass
5. Commit
6. Repeat
```

**Small steps. Never refactor and add features at the same time.**

## Quality Checklist

- [ ] Tests pass before AND after each change
- [ ] No behavior changes (same inputs = same outputs)
- [ ] Each commit is one logical refactoring step
- [ ] Code is shorter or easier to read (ideally both)
- [ ] No dead code left behind

## Examples

```
> Refactor this 200-line function into smaller pieces
> Remove duplicated code between UserService and AdminService
> Modernize this class to use async/await instead of callbacks
```
