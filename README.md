# sapphire-utils
[![CI](https://img.shields.io/github/actions/workflow/status/mark-marks/jecs-utils/ci.yml?style=for-the-badge&label=CI)](https://github.com/mark-marks/jecs-utils/actions/workflows/ci.yml)
[![Wally](https://img.shields.io/github/v/tag/mark-marks/jecs-utils?&style=for-the-badge)](https://wally.run/package/mark-marks/jecs-utils)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](https://github.com/Mark-Marks/jecs-utils/blob/main/LICENSE)

A set of utilities for [Jecs](https://github.com/ukendio/jecs)
<br/>

</div>

## Features

- [collect](/lib/collect.luau) - Collects all arguments fired through the given signal, and drains the collection on iteration.
- [handle](/lib/handle.luau) - Wrap `jecs.World` functions for faster (DX wise) operating on entities
- [replicator](/lib/replicator.luau) - Keep track of all entities with the passed components and calculate differences
- [ref](/lib/ref.luau) - Reference entities by key
- [command_buffer](/lib/command_buffer.luau) - Buffer commands to prevent iterator invalidation
