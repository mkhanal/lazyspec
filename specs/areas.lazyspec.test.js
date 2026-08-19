// The married test. Every describe is a requirement in
// specs/areas.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT, read } = require('./support.js');

// What a bullet naming an area looks like: `- **name** — \`glob\`.`
const areas = (text) =>
  text.split('\n').filter((l) => /^- \*\*.+\*\*/.test(l));

// The shapes the file it replaced used. Any of them reappearing means
// somebody started building a schema again.
const SCHEMA = /^\s*-?\s*(sets|root|specs|covers)\s*:/m;

describe('Where Requirements Live Is Written In Prose', () => {
  it('names one area per bullet, and a glob only where it is not the default', () => {
    const ours = areas(read('lazyspec.md'));
    assert.ok(ours.length >= 1, 'lazyspec.md names no area');
    const unnamed = ours.filter((l) => !/`[^`]+`/.test(l));
    assert.deepEqual(unnamed, [], 'an area bullet names no glob or path');
  });

  it('carries no schema, so there is nothing to learn beyond markdown', () => {
    const withKeys = ['lazyspec.md', 'lazyspec.example.md']
      .filter((rel) => SCHEMA.test(read(rel)));
    assert.deepEqual(withKeys, []);
  });

  it('is read conditionally, because the file is optional', () => {
    // "if there is one" is the whole claim: an agent must not stall when
    // a repository never wrote it.
    assert.match(read('lazyspec.instruction.md'), /`lazyspec\.md`[^.]*if there is/);
    const insists = fs
      .readdirSync(path.join(ROOT, 'skills'))
      .map((d) => `skills/${d}/SKILL.md`)
      .filter((rel) => !/optional/.test(read(rel)) && /lazyspec\.md/.test(read(rel)));
    assert.deepEqual(insists, [], 'a skill names the file without saying it is optional');
  });

  it('ships an example showing more than one layout', () => {
    const globs = new Set(
      [...read('lazyspec.example.md').matchAll(/`([^`]*\*[^`]*)`/g)].map((m) => m[1]),
    );
    assert.ok(globs.size > 1, `example shows ${globs.size} layout(s), wanted more than one`);
  });
});
