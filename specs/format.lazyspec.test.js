// The married test. Every describe is a requirement in
// specs/format.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT } = require('./support.js');

const specs = () =>
  fs
    .readdirSync(path.join(ROOT, 'specs'))
    .filter((f) => f.endsWith('.lazyspec.md'))
    .map((f) => path.join('specs', f));

const firstLine = (rel) =>
  fs.readFileSync(path.join(ROOT, rel), 'utf8').split('\n')[0];

describe('Every Specification Says It Is Locked', () => {
  it('opens every specification with a notice naming /lazyspec', () => {
    const found = specs();
    assert.ok(found.length > 0, 'found no specifications to check');
    const silent = found.filter((rel) => !/^<!-- lazyspec:.*\/lazyspec/.test(firstLine(rel)));
    assert.deepEqual(silent, []);
  });

  it('binds agents and leaves people alone', () => {
    const vague = specs().filter((rel) => {
      const line = firstLine(rel);
      return !/agents?/i.test(line) || !/humans?/i.test(line);
    });
    assert.deepEqual(vague, []);
  });
});
