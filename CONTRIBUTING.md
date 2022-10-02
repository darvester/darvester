# Contributing Guidelines

These guidelines will apply to all branches unless otherwise stated.

### Notices
- Currently, the `gen2` branch is in focus for development. All changes intended for `gen2` should be in a PR pointing to the `gen2` branch
- `main` branch should reflect latest releases only. Do not submit a PR targetting `main` unless on rare occasions (typos mainly)
- `dev` branch pertains to pending merges to `main` awaiting release

## How can I contribute?

### Gen2

> To contribute to Generation 2, a rewrite and repackaging of Darvester, clone this repo then checkout the `gen2` branch.
> ```
> git clone https://github.com/darvester/darvester/
> git checkout gen2
> ```

#### Layout
Gen2 is an Electron/React.js application, you will find a (mostly) conventional folder structure.  

`public/src/:`
> - This folder contains the Electron IPC API. providing config, process, and utility calls such as getConfigKey, createPythonVenv, and more.
> - `preload.js` exposes these IPC calls to the React.js renderer

`src/:`
> - The "root" of the React.js project
> - `common.js` exposes some basic utility functions like parsers, sorters, React.js conditional rendering, and more.
> - `config.js` and `constants.js` are not widely used and may be removed in favor of Electron IPC
> - `index.css` should be used for class styling. In other cases, inline styling is used for now until a project-wide refactor is initiated.

`src/components/:`
> - Holds common components for routes. Some may be utility related, some contain their own independent component logic for nested purposes.

`src/routes/:`
> - Landing pages for route assignments for react-router
