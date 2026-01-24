---
name: markdown-docs
description: Creates and updates markdown documentation including README files, API docs, guides, changelogs, and architecture documentation. Load when writing or improving .md files or project documentation.
---

# Markdown Documentation

Create clear, well-structured markdown documentation for projects and features.

## Document Types

| Type | Purpose |
|------|---------|
| README.md | Project overview, installation, quick start |
| API docs | Endpoint/function documentation with examples |
| Guides | Step-by-step instructions for tasks |
| Architecture | System design, components, data flow |
| CHANGELOG.md | Version history, breaking changes, migrations |
| CONTRIBUTING.md | Contribution guidelines, dev setup |

## Structure Guidelines

### Heading Hierarchy

Use proper nesting—never skip levels:

```markdown
# Project Name (H1 - only one per doc)

## Installation (H2 - major sections)

### Prerequisites (H3 - subsections)

#### Optional: Docker Setup (H4 - nested details)
```

### Table of Contents

Include for documents with 4+ sections:

```markdown
## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Contributing](#contributing)
```

## README Template

```markdown
# Project Name

Brief description of what this project does and why it exists.

## Installation

\`\`\`bash
npm install project-name
\`\`\`

## Quick Start

\`\`\`javascript
import { thing } from 'project-name';

const result = thing.doSomething();
\`\`\`

## Documentation

- [Full API Reference](./docs/api.md)
- [Configuration Guide](./docs/configuration.md)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT
```

## Style Rules

- **Active voice**: "Run the command" not "The command should be run"
- **Second person**: "You can configure..." not "One can configure..."
- **Present tense**: "Returns the user" not "Will return the user"
- **Code blocks**: Always specify language for syntax highlighting

## Code Examples

Always include language identifier:

````markdown
```javascript
const config = { debug: true };
```

```bash
npm run build
```

```json
{
  "name": "example"
}
```
````

## API Documentation Pattern

```markdown
## `functionName(param1, param2)`

Brief description of what the function does.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| param1 | string | Yes | Description of param1 |
| param2 | object | No | Description of param2 |

### Returns

`Promise<Result>` - Description of return value

### Example

\`\`\`javascript
const result = await functionName('value', { option: true });
console.log(result);
// Output: { success: true }
\`\`\`

### Errors

- `ValidationError` - When param1 is empty
- `NetworkError` - When the API is unreachable
```

## CHANGELOG Pattern

Follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [1.2.0] - 2025-01-25

### Added
- New feature X for doing Y

### Changed
- Improved performance of Z by 50%

### Fixed
- Bug where A would cause B

### Deprecated
- Old method `foo()` - use `bar()` instead

### Removed
- Support for Node.js 14

### Security
- Fixed XSS vulnerability in input handling
```

## Formatting Tips

- Use **bold** for UI elements and key terms
- Use `code` for file names, commands, and values
- Use > blockquotes for important notes or warnings
- Use tables for structured data comparison
- Add alt text to images: `![Alt description](image.png)`

## Checklist

Before completing markdown documentation:

- [ ] Heading hierarchy is correct (no skipped levels)
- [ ] Code blocks have language identifiers
- [ ] Links are working and use relative paths where possible
- [ ] Table of contents matches actual sections (if present)
- [ ] Examples are complete and can be copy-pasted
- [ ] No orphaned sections or incomplete content
