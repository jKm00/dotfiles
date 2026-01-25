---
name: ui-ux
description: UI/UX design principles and implementation patterns. Load when designing interfaces, improving user experience, implementing components, or reviewing frontend code for usability.
---

## What I Do

- Apply UI/UX design principles to component implementation
- Evaluate interfaces for usability and accessibility
- Guide responsive and adaptive design decisions
- Recommend interaction patterns and micro-interactions
- Ensure consistency with design systems

## Core Principles

### User-Centered Design

| Principle | Application |
|-----------|-------------|
| Clarity | One primary action per screen, clear visual hierarchy |
| Feedback | Immediate response to all user actions |
| Forgiveness | Easy undo, confirmation for destructive actions |
| Consistency | Same patterns for same actions throughout |
| Efficiency | Minimize steps to complete tasks |

### Visual Hierarchy

Establish importance through:

1. **Size**: Larger elements draw attention first
2. **Color**: High contrast for primary actions
3. **Position**: Top-left reads first (LTR), F-pattern scanning
4. **Whitespace**: Isolation emphasizes importance
5. **Typography**: Weight and size signal hierarchy

### Interaction Design

| State | Visual Indicator |
|-------|------------------|
| Default | Base styling |
| Hover | Subtle highlight, cursor change |
| Focus | Visible outline (never remove for accessibility) |
| Active | Pressed/depressed appearance |
| Disabled | Reduced opacity (0.5-0.6), no pointer events |
| Loading | Spinner or skeleton, disable re-submission |
| Error | Red accent, icon, descriptive message |
| Success | Green accent, confirmation message |

## Accessibility Checklist

```
[ ] Color contrast ratio >= 4.5:1 (text), >= 3:1 (large text/UI)
[ ] All interactive elements keyboard accessible
[ ] Focus indicators visible and clear
[ ] Images have meaningful alt text
[ ] Form inputs have associated labels
[ ] Error messages descriptive and helpful
[ ] No content conveyed by color alone
[ ] Touch targets >= 44x44px on mobile
[ ] Reduced motion respected (@prefers-reduced-motion)
[ ] Screen reader testing completed
```

## Responsive Design

### Breakpoint Strategy

| Breakpoint | Target | Typical Width |
|------------|--------|---------------|
| xs | Mobile portrait | < 576px |
| sm | Mobile landscape | >= 576px |
| md | Tablet | >= 768px |
| lg | Desktop | >= 992px |
| xl | Large desktop | >= 1200px |

### Mobile-First Approach

1. Design for smallest screen first
2. Add complexity as viewport grows
3. Touch-friendly by default (larger targets, swipe gestures)
4. Consider thumb zones for primary actions

## Component Patterns

### Buttons

```
Primary   → Main action, one per section, high contrast
Secondary → Alternative actions, lower visual weight
Tertiary  → Low-priority actions, text-only or ghost style
Danger    → Destructive actions, red accent, confirm dialog
```

### Forms

- Group related fields visually
- Show validation inline, not just on submit
- Use appropriate input types (email, tel, number)
- Placeholder is not a label replacement
- Mark optional fields, not required (fewer marks)

### Navigation

- Current location always visible
- Maximum 7±2 primary nav items
- Mobile: hamburger or bottom nav for 3-5 items
- Breadcrumbs for deep hierarchies

### Feedback & Loading

- Optimistic UI for fast perceived performance
- Skeleton screens over spinners for content
- Progress bars for known duration
- Disable buttons during async operations

## Implementation Guidelines

### CSS Architecture

Prefer utility-first or component-scoped styles:

```css
/* Avoid deep specificity */
.card .header .title { } /* Bad */
.card-title { }          /* Good */
```

### Animation Principles

| Property | Duration | Easing |
|----------|----------|--------|
| Hover states | 150-200ms | ease-out |
| Modals/overlays | 200-300ms | ease-out |
| Page transitions | 300-500ms | ease-in-out |
| Micro-interactions | 100-150ms | ease-out |

Respect user preferences:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Color Usage

| Purpose | Guidance |
|---------|----------|
| Primary | Brand color, main CTAs |
| Secondary | Supporting actions |
| Neutral | Text, borders, backgrounds |
| Success | Confirmations, completion |
| Warning | Caution, non-blocking issues |
| Error | Failures, validation errors |

Always provide semantic meaning beyond color (icons, text).

### Typography Scale

Use a consistent scale (e.g., 1.25 ratio):

```
12px → 14px → 16px (base) → 20px → 24px → 30px → 36px
```

- Body: 16px minimum for readability
- Line height: 1.4-1.6 for body text
- Max line length: 60-80 characters

## Review Checklist

When reviewing UI implementations:

```
[ ] Visual hierarchy guides user attention
[ ] Interactive states all defined
[ ] Accessibility requirements met
[ ] Responsive behavior tested
[ ] Loading and error states handled
[ ] Animations respect reduced-motion
[ ] Consistent with existing design system
[ ] Touch targets appropriate for mobile
[ ] Forms validate helpfully
[ ] Color contrast sufficient
```

## Common Anti-patterns

- **Mystery meat navigation**: Icons without labels
- **Infinite scroll without position**: No way to return or share location
- **Disabled without explanation**: User doesn't know why
- **Modal overload**: Modals spawning modals
- **Carousel blindness**: Users ignore rotating content
- **Dark patterns**: Tricks that work against user intent
