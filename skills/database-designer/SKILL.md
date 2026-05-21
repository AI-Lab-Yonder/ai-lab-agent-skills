---
name: database-designer
description: "Design database schemas, write migrations, and model relationships. Use when: starting a new project that needs a database, adding tables, designing relationships, or optimizing queries."
version: 1.0.0
level: beginner
category: database
---

# Database Designer

Design clean, performant database schemas from requirements.

## When to Use

- Starting a new project that needs a database
- Adding new tables or columns
- Modeling relationships (one-to-many, many-to-many)
- Writing migrations
- Optimizing slow queries with indexes

## How It Works

### 1. From Requirements to Tables

Translate nouns in your requirements into tables:

```
Requirement: "Users can create posts, and other users can comment on them"

Nouns → Tables:
- Users    → users table
- Posts    → posts table
- Comments → comments table

Relationships:
- User has many Posts       (one-to-many)
- Post has many Comments    (one-to-many)
- User has many Comments    (one-to-many)
```

### 2. Schema Design with Prisma

```prisma
// prisma/schema.prisma

model User {
  id        String    @id @default(cuid())
  email     String    @unique
  name      String
  password  String    // hashed, never plaintext
  role      Role      @default(USER)
  posts     Post[]
  comments  Comment[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  @@index([email])
}

model Post {
  id        String    @id @default(cuid())
  title     String
  content   String
  published Boolean   @default(false)
  author    User      @relation(fields: [authorId], references: [id])
  authorId  String
  comments  Comment[]
  tags      Tag[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  @@index([authorId])
  @@index([published, createdAt])
}

model Comment {
  id        String   @id @default(cuid())
  body      String
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
  postId    String
  createdAt DateTime @default(now())

  @@index([postId])
  @@index([authorId])
}

// Many-to-many: posts can have multiple tags, tags can be on multiple posts
model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}

enum Role {
  USER
  ADMIN
}
```

### 3. Relationship Patterns

**One-to-Many** (most common):
```prisma
// A user has many posts
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  author   User   @relation(fields: [authorId], references: [id])
  authorId String
}
```

**Many-to-Many** (implicit join table):
```prisma
// Posts can have many tags, tags can be on many posts
model Post {
  id   String @id @default(cuid())
  tags Tag[]
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}
```

**Self-Relation** (e.g., followers):
```prisma
model User {
  id        String @id @default(cuid())
  followers User[] @relation("UserFollows")
  following User[] @relation("UserFollows")
}
```

### 4. Migration Workflow

```bash
# Create migration from schema changes
npx prisma migrate dev --name add-comments-table

# Apply migrations in production
npx prisma migrate deploy

# Reset database (development only!)
npx prisma migrate reset

# Generate Prisma client after schema changes
npx prisma generate

# View your database in browser
npx prisma studio
```

### 5. Indexing Rules

Add indexes for columns that appear in:

```
WHERE clauses     → @@index([columnName])
JOIN conditions   → @@index([foreignKey])
ORDER BY clauses  → @@index([sortColumn])
UNIQUE lookups    → @unique

DON'T index:
- Columns with very few distinct values (boolean, enum with 2 values)
- Tables with < 1000 rows (full scan is fine)
- Columns that are rarely queried
```

### 6. Common Patterns

**Soft Delete:**
```prisma
model Post {
  id        String    @id @default(cuid())
  deletedAt DateTime? // null = not deleted

  @@index([deletedAt])
}

// Query: where: { deletedAt: null }
```

**Timestamps on everything:**
```prisma
model AnyModel {
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**Enums for fixed values:**
```prisma
enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}
```

## Quality Checklist

- [ ] Every table has a primary key (`@id`)
- [ ] Foreign keys have indexes (`@@index`)
- [ ] Unique constraints on natural keys (email, slug)
- [ ] `createdAt` and `updatedAt` on every table
- [ ] Cascade deletes configured where appropriate
- [ ] No nullable fields that should be required
- [ ] Enums used for fixed sets of values

## Examples

```
> Design a database schema for a todo app with projects and labels
> Add a comments feature to the existing blog schema
> Create a schema for an e-commerce store with products, orders, and inventory
```
