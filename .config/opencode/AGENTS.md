# Package manager

- Default to `pnpm` for all commands (install, run scripts, add/remove deps).
- If a project already declares another package manager, follow that instead. Detect it from:
  - `packageManager` field in `package.json`
  - Lockfile present: `package-lock.json` → npm, `yarn.lock` → yarn, `bun.lock` or `bun.lockb` → bun, `pnpm-lock.yaml` → pnpm
- Only fall back to `pnpm` when no existing tooling is detectable (e.g. a brand-new project or empty directory).
- When scaffolding a new project, initialize it with `pnpm`.
