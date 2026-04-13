# Patterns

Reusable solutions discovered during implementation. Each pattern is a separate markdown file in this directory.

## What Goes Here

Patterns are recurring structural solutions specific to this project — not general design patterns, but concrete approaches that should be followed when building similar things. Examples:

- How API endpoints are structured in this project
- The standard way to add a new database model with migrations
- How background jobs are defined and registered
- The testing pattern for integration tests

## When to Add a Pattern

Add a pattern when you notice:
- You've solved the same structural problem more than once
- A new team member would need to ask "how do we do X here?"
- There's a non-obvious approach that deviates from framework defaults

## Pattern File Format

Create a new `.md` file in this directory:

```markdown
# [Pattern Name]
<!-- Added: YYYY-MM-DD -->

## When to Use
[Describe the situation where this pattern applies]

## Structure
[Show the file layout, class structure, or code skeleton]

## Example
[Reference an existing implementation: file path + brief explanation]

## Gotchas
[Common mistakes or non-obvious constraints]
```

## Current Patterns

*None yet. Use `/remember` to add patterns as you discover them, or run `/intel` to detect them from the codebase.*
