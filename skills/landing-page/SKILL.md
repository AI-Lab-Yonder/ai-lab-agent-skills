---
name: landing-page
description: "Create polished, conversion-optimized landing pages quickly. Use when: building marketing pages, product launches, portfolio sites, or any single-page website that needs to look professional fast."
version: 1.0.0
level: beginner
category: frontend
---

# Landing Page

Build beautiful, responsive landing pages in minutes.

## When to Use

- Launching a new product or feature
- Creating a marketing or promotional page
- Building a portfolio or personal site
- Making a signup or waitlist page
- Prototyping a product concept quickly

## How It Works

### 1. Page Sections

Every effective landing page follows this structure:

```
┌─────────────────────────────┐
│  Navigation (logo + links)  │
├─────────────────────────────┤
│  Hero (headline + CTA)      │
├─────────────────────────────┤
│  Social Proof / Logos       │
├─────────────────────────────┤
│  Features (3-4 cards)       │
├─────────────────────────────┤
│  How It Works (3 steps)     │
├─────────────────────────────┤
│  Testimonials               │
├─────────────────────────────┤
│  Pricing (optional)         │
├─────────────────────────────┤
│  CTA (repeat main action)   │
├─────────────────────────────┤
│  Footer                     │
└─────────────────────────────┘
```

### 2. Hero Section

The hero makes or breaks the page. Keep it simple:

```tsx
function Hero() {
  return (
    <section className="py-20 px-6 text-center">
      {/* Badge */}
      <div className="inline-flex items-center rounded-full bg-blue-50 px-3 py-1 text-sm text-blue-700 mb-6">
        Now in public beta
      </div>

      {/* Headline — one clear value proposition */}
      <h1 className="text-5xl font-bold tracking-tight text-gray-900 max-w-3xl mx-auto">
        Ship your product <span className="text-blue-600">10x faster</span> with AI
      </h1>

      {/* Subheadline — support the headline */}
      <p className="mt-6 text-xl text-gray-600 max-w-2xl mx-auto">
        Stop writing boilerplate. Let AI handle the repetitive work
        while you focus on what matters.
      </p>

      {/* CTA — one primary action */}
      <div className="mt-10 flex gap-4 justify-center">
        <a href="#" className="px-8 py-3 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700">
          Get Started Free
        </a>
        <a href="#" className="px-8 py-3 border border-gray-300 rounded-lg font-medium hover:bg-gray-50">
          See Demo
        </a>
      </div>
    </section>
  )
}
```

### 3. Feature Cards

```tsx
const features = [
  { icon: '⚡', title: 'Lightning Fast', description: 'Deploy in seconds, not hours' },
  { icon: '🔒', title: 'Secure by Default', description: 'Enterprise-grade security built in' },
  { icon: '📊', title: 'Analytics', description: 'Real-time insights into your data' },
]

function Features() {
  return (
    <section className="py-20 px-6 bg-gray-50">
      <h2 className="text-3xl font-bold text-center mb-12">Everything you need</h2>
      <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
        {features.map(f => (
          <div key={f.title} className="bg-white p-6 rounded-xl shadow-sm">
            <div className="text-3xl mb-4">{f.icon}</div>
            <h3 className="text-lg font-semibold mb-2">{f.title}</h3>
            <p className="text-gray-600">{f.description}</p>
          </div>
        ))}
      </div>
    </section>
  )
}
```

### 4. Design Principles

- **One CTA per section** — don't overwhelm with choices
- **Whitespace is your friend** — generous padding (py-20, gap-8)
- **Max width on text** — never let text span full-width (max-w-3xl)
- **Visual hierarchy** — bigger = more important, use font-bold sparingly
- **Mobile first** — design for mobile, enhance with md: and lg: breakpoints
- **Fast load** — use next/image, minimize JS, no heavy libraries

### 5. Quick Setup

```bash
# Fastest path: Next.js + Tailwind
npx create-next-app@latest landing --typescript --tailwind --app
cd landing
npm run dev
```

## Quality Checklist

- [ ] Looks good on mobile (check at 375px width)
- [ ] Hero headline is clear and concise (< 10 words)
- [ ] One obvious CTA above the fold
- [ ] Page loads in < 2 seconds
- [ ] All links and buttons work
- [ ] Favicon and meta tags set

## Examples

```
> Build a landing page for an AI writing tool
> Create a waitlist page with email signup for a mobile app
> Build a portfolio landing page with project showcase
```
