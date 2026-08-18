// Shared plumbing for the married tests. Not a test file: the runner
// takes *.lazyspec.test.js only.
const fs = require('node:fs');
const path = require('node:path');

const ROOT = path.resolve(__dirname, '..');

const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf8');

module.exports = { ROOT, read };
