// The married test. Every describe is a requirement in
// specs/install.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT, read } = require('./support.js');

const MANIFESTS = ['.claude-plugin', '.cursor-plugin', '.codex-plugin'];
const json = (rel) => JSON.parse(read(rel));

// Everything an agent or a person could read the instruction out of.
const shipped = () =>
  ['lazyspec.instruction.md', 'AGENTS.md', 'README.md']
    .concat(fs.readdirSync(path.join(ROOT, 'skills')).map((d) => `skills/${d}/SKILL.md`));

describe('The Plugin Resolves To This Repository', () => {
  it('names the marketplace and the plugin the same, so lazyspec@lazyspec names it', () => {
    const m = json('.claude-plugin/marketplace.json');
    assert.equal(m.name, 'lazyspec');
    assert.deepEqual(m.plugins.map((p) => p.name), ['lazyspec']);
    assert.match(read('README.md'), /plugin install lazyspec@lazyspec/);
  });

  it('declares the same version in every manifest that ships', () => {
    const versions = MANIFESTS.map((d) => json(`${d}/plugin.json`).version);
    assert.equal(new Set(versions).size, 1, `versions differ: ${versions.join(', ')}`);
  });

  it('resolves the plugin root to the root of this repository', () => {
    // source is relative to the marketplace clone, so "./" is this repo.
    for (const d of MANIFESTS.filter((d) => fs.existsSync(path.join(ROOT, d, 'marketplace.json')))) {
      const src = json(`${d}/marketplace.json`).plugins[0].source;
      assert.equal(typeof src, 'string', `${d} uses a source shape we do not ship`);
      assert.ok(fs.existsSync(path.resolve(ROOT, src)), `${d}: ${src} resolves nowhere`);
    }
  });
});

describe('Installing Leaves The Instruction On Disk', () => {
  it('puts lazyspec.instruction.md where /lazyspec-setup looks for it first', () => {
    assert.ok(fs.existsSync(path.join(ROOT, 'lazyspec.instruction.md')));
    assert.match(read('skills/lazyspec-setup/SKILL.md'), /CLAUDE_PLUGIN_ROOT\}\/lazyspec\.instruction\.md/);
  });

  it('puts the three skills beside it', () => {
    const dirs = fs.readdirSync(path.join(ROOT, 'skills')).sort();
    assert.deepEqual(dirs, ['lazyspec', 'lazyspec-setup', 'lazyspec-validate']);
    const missing = dirs.filter((d) => !fs.existsSync(path.join(ROOT, 'skills', d, 'SKILL.md')));
    assert.deepEqual(missing, []);
  });

  it('fetches it over the network from nowhere', () => {
    const fetchers = shipped().filter((rel) => /https?:\/\/\S*lazyspec\.instruction\.md/.test(read(rel)));
    assert.deepEqual(fetchers, []);
  });
});

describe('The Paste Is Bounded By Named Markers', () => {
  const BEGIN = '<!-- lazyspec:begin -->';
  const END = '<!-- lazyspec:end -->';

  it('pastes the instruction between the two markers', () => {
    const setup = read('skills/lazyspec-setup/SKILL.md');
    assert.ok(setup.includes(BEGIN) && setup.includes(END));
  });

  it('spells both the same way in every shipped file naming that boundary', () => {
    const wrong = shipped().flatMap((rel) => {
      const text = read(rel);
      return [...text.matchAll(/<!--\s*lazyspec:(\w+)\s*-->/g)]
        .map((m) => m[0])
        .filter((m) => m !== BEGIN && m !== END)
        .map((m) => `${rel}: ${m}`);
    });
    assert.deepEqual(wrong, []);
  });
});
