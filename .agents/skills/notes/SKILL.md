---
name: notes
description: Use ONLY when explicitly invoked via /skill or when the user directly asks to document the current session as notes. Do not trigger automatically.
---

# Notes

Document the key points from the active session as an HTML file in `~/dev/notes/quick-notes/`. Capture everything important, but keep it simple and uncluttered.

Do not look at existing notes or other files as reference. Implement solely from the instructions below.

## HTML Structure

- Style it like an article/blog post
- Dark theme, smooth scroll
- Sticky sidebar with a content overview that highlights the current heading:
  - On scroll, via an IntersectionObserver
  - On click of a sidebar link

## Diagrams and Figures

Include diagrams or figures (e.g. Mermaid (using library from CDN)) only when they add real explanatory value. Skip them if they are purely decorative.
