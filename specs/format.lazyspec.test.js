// The married test. Every describe is a requirement in
// specs/format.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT, read } = require('./support.js');

const specs = () =>
  fs
    .readdirSync(path.join(ROOT, 'specs'))
    .filter((f) => f.endsWith('.lazyspec.md'))
    .map((f) => path.join('specs', f));

// The header is everything above the title, so a specification can be
// read from the top by something that has never heard of lazyspec.
const header = (rel) =>
  fs.readFileSync(path.join(ROOT, rel), 'utf8').split(/^# /m)[0];

describe('Every Specification Says It Is Locked', () => {
  it('opens every specification with a header naming /lazyspec', () => {
    const found = specs();
    assert.ok(found.length > 0, 'found no specifications to check');
    const silent = found.filter((rel) => !/\/lazyspec/.test(header(rel)));
    assert.deepEqual(silent, []);
  });

  it('binds agents and leaves people alone', () => {
    const vague = specs().filter((rel) => {
      const h = header(rel);
      return !/agents?/i.test(h) || !/humans?/i.test(h);
    });
    assert.deepEqual(vague, []);
  });

  it('says what a requirement is and how to find its test', () => {
    const silent = specs().filter((rel) => {
      const h = header(rel);
      return !/heading is one requirement/i.test(h) || !/search the tests/i.test(h);
    });
    assert.deepEqual(silent, []);
  });
});

// Every key any shipped `.lazyspec.yaml` may carry. A heading-level key
// appearing here would be the failure this test exists to catch.
const KEYS = ['sets', 'root', 'specs', 'covers'];

// Fenced yaml only. Prose and a skill's own frontmatter are not
// configuration, and a line of English can end in a colon.
const yamlKeys = (text) =>
  [...text.matchAll(/```yaml\n([\s\S]*?)```/g)]
    .flatMap((block) => block[1].split('\n'))
    .map((line) => /^\s*-?\s*([a-z][a-z_]*):(\s|$)/.exec(line))
    .filter(Boolean)
    .map((m) => m[1]);

describe('A Requirement Is A Level Two Heading', () => {
  it('marks a requirement in every project, with no setting to move it', () => {
    const shipped = [['.lazyspec.yaml', yamlKeys('```yaml\n' + read('.lazyspec.yaml') + '```')]]
      .concat(
        fs
          .readdirSync(path.join(ROOT, 'skills'))
          .map((d) => path.join('skills', d, 'SKILL.md'))
          .map((rel) => [rel, yamlKeys(read(rel))]),
      );
    const stray = shipped.flatMap(([rel, keys]) =>
      keys.filter((k) => !KEYS.includes(k)).map((k) => `${rel}: ${k}`),
    );
    assert.deepEqual(stray, []);
  });

  it('names ## in the standing instruction and in every header', () => {
    assert.match(read('INSTRUCTION.md'), /`## ` heading/);
    const silent = specs().filter((rel) => !/`##`/.test(header(rel)));
    assert.deepEqual(silent, []);
  });

  it('uses ## for nothing else, so every heading is repeated by a test', () => {
    const unmarried = specs().flatMap((rel) => {
      const married = read(rel.replace(/\.md$/, '.test.js'));
      return read(rel)
        .split('\n')
        .filter((l) => l.startsWith('## ') && !l.includes('no-test'))
        .map((l) => l.slice(3).trim())
        .filter((h) => !married.includes(h))
        .map((h) => `${rel}: ${h}`);
    });
    assert.deepEqual(unmarried, []);
  });
});
