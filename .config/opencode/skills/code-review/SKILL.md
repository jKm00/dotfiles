---
name: code-review
description: Perform thorough code reviews focusing on correctness, security, performance, maintainability, and best practices
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: pull-request
---

## What I do

- Review code changes for bugs, logic errors, and edge cases
- Identify security vulnerabilities and unsafe patterns
- Assess performance implications and optimization opportunities
- Evaluate code readability and maintainability
- Check adherence to project conventions and best practices
- Suggest concrete improvements with example code

## When to use me

Use this skill when you need to:
- Review a pull request or code diff
- Audit existing code for issues
- Get feedback before committing changes
- Learn about potential improvements to your code
- Ensure code meets quality standards

## Review process

### 1. Understand context
- What is the purpose of this change?
- What problem does it solve?
- Are there related files or systems affected?

### 2. Check correctness
- Does the logic match the intended behavior?
- Are edge cases handled?
- Are error conditions properly managed?
- Do tests cover the changes adequately?

### 3. Assess security
- Input validation and sanitization
- Authentication and authorization checks
- Data exposure risks
- Injection vulnerabilities (SQL, XSS, command)
- Sensitive data handling

### 4. Evaluate performance
- Algorithm complexity (time and space)
- Database query efficiency
- Memory usage and potential leaks
- Unnecessary computations or allocations
- Caching opportunities

### 5. Review maintainability
- Code clarity and readability
- Function and variable naming
- Appropriate abstraction level
- Documentation and comments
- Test coverage and quality

### 6. Verify conventions
- Project coding style
- File and folder organization
- API design consistency
- Error handling patterns
- Logging standards

## Issue severity levels

| Level | Meaning | Action required |
|-------|---------|-----------------|
| Critical | Security flaw or data loss risk | Must fix before merge |
| High | Bug or significant issue | Should fix before merge |
| Medium | Code smell or minor bug | Fix recommended |
| Low | Style or minor improvement | Optional enhancement |
| Note | Observation or question | No action needed |

## Output format

I will provide:

1. **Summary**: Overall assessment and key findings
2. **Issues**: List of problems found with severity, location, and explanation
3. **Suggestions**: Recommended improvements with code examples
4. **Questions**: Clarifications needed to complete the review
5. **Verdict**: Approve, request changes, or needs discussion

## Review checklist

```
[ ] Logic is correct and handles edge cases
[ ] No security vulnerabilities introduced
[ ] Performance is acceptable for the use case
[ ] Code is readable and well-structured
[ ] Tests are adequate and passing
[ ] Documentation is updated if needed
[ ] No debugging code or temporary hacks
[ ] Dependencies are appropriate and updated
[ ] Error messages are helpful
[ ] Logging is appropriate (not excessive or missing)
```

## Tips for effective reviews

- Provide the full context of what the code should do
- Share relevant files (tests, related modules, interfaces)
- Mention any specific concerns you have
- Let me know the project's coding standards if non-standard
- Indicate if this is a draft or final review
