# Collaboration rules

- Be concise. Explain changes, verification, and blockers without filler.
- Work on one goalpost at a time. Necessary fixes and verification belong to it; wait for explicit confirmation and instruction before starting the next goalpost.
- Before editing, read this file, `Updated Roadmap.md`, relevant code, and available sync configuration. Record the branch and base commit.
- Define observable acceptance criteria before implementation.
- Distinguish implemented code from Studio-verified behavior. Never mark unrun tests as passed.
- Keep these rules and the Roadmap current alongside relevant changes.
- Validate remote inputs on the server: types, allowed values, membership, ownership, live state, and request limits.
- Preserve Studio structure. Built-in Script Sync mirrors service directories. Confirm mappings before moving or renaming scripts; clearly label manual Studio instance changes.
- Follow strict Luau, frozen and validated shared configuration, and centrally started services. Add dependencies only when needed for the current goalpost.
- Verify affected failure and multiplayer cases, including foreign ownership, destroyed units, invalid payloads, and repeated requests.
- Resolve routine details independently; ask when gameplay, architecture, ownership, or sync structure is materially ambiguous.
- Finish with a brief handoff and remaining checks, then wait for confirmation and instructions.
