// The married test. Every describe is a requirement in
// specs/lazyspec-guard.lazyspec.md, word for word.
const assert = require('node:assert');
const { describe, it } = require('node:test');
const { tmp, write, guard, edit, bash, writeCall, notebookCall } = require('./support.js');

describe('A Write To A Specification Is Refused Outside The Window', () => {
  it('exits 2 when a writing tool is aimed at a locked path', () => {
    assert.equal(guard(edit('specs/billing.lazyspec.md')).status, 2);
  });

  it('names /lazyspec as the way in', () => {
    assert.match(guard(edit('specs/billing.lazyspec.md')).stderr, /Run \/lazyspec/);
  });
});

describe('A Specification Is Locked Wherever It Lives', () => {
  it('locks a .lazyspec.md in any directory', () => {
    for (const file of [
      'specs/billing.lazyspec.md',
      'packages/ledger/specs/ledger.lazyspec.md',
      'apps/web/docs/deep/checkout.lazyspec.md',
      '/absolute/elsewhere/billing.lazyspec.md',
    ]) {
      assert.equal(guard(edit(file)).status, 2, file);
    }
  });

  it("leaves somebody else's SPEC.md alone", () => {
    for (const file of [
      'node_modules/ws/SPEC.md',
      'vendor/protocol/SPEC.md',
      'docs/api/thing.SPEC.md',
    ]) {
      assert.equal(guard(edit(file)).status, 0, file);
    }
  });

  it('leaves the married test alone', () => {
    assert.equal(guard(edit('specs/billing.lazyspec.test.ts')).status, 0);
  });
});

describe('The Unlock File Opens The Window', () => {
  it('allows a locked write while .lazyspec-unlock exists', () => {
    const cwd = tmp();
    write(cwd, '.lazyspec-unlock', '');
    assert.equal(guard(edit('specs/billing.lazyspec.md'), { cwd }).status, 0);
  });
});

describe('A Structured Tool Is Judged By The Path It Writes To', () => {
  it('allows a write whose content names a specification', () => {
    const content = 'See specs/billing.lazyspec.md for the requirement.';
    assert.equal(guard(writeCall('README.md', content)).status, 0);
    assert.equal(guard(writeCall('src/refunds.js', `// ${content}`)).status, 0);
  });

  it('still refuses a write whose path is locked', () => {
    assert.equal(guard(writeCall('specs/billing.lazyspec.md', 'anything')).status, 2);
  });

  it('reads notebook_path', () => {
    assert.equal(guard(notebookCall('notes.ipynb', 'x.lazyspec.md')).status, 0);
    assert.equal(guard(notebookCall('specs/billing.lazyspec.md', 'x')).status, 2);
  });

  it('judges a call naming no path by its whole payload', () => {
    const shapeless = {
      tool_name: 'SomeOtherEditor',
      tool_input: { old_string: 'specs/billing.lazyspec.md' },
    };
    assert.equal(guard(shapeless).status, 2);
  });
});

describe('A Shell Command That Writes To A Specification Is Refused', () => {
  it('refuses a redirect into a specification', () => {
    assert.equal(guard(bash('cat > specs/billing.lazyspec.md <<EOF')).status, 2);
    assert.equal(guard(bash('echo x >> specs/billing.lazyspec.md')).status, 2);
  });

  it('refuses an in-place edit', () => {
    assert.equal(guard(bash("sed -i '' 's/a/b/' specs/billing.lazyspec.md")).status, 2);
  });

  it('refuses a deletion', () => {
    assert.equal(guard(bash('rm -f specs/billing.lazyspec.md')).status, 2);
  });
});

describe('Reading A Specification Is Never Refused', () => {
  it('allows a shell call that only reads', () => {
    assert.equal(guard(bash('cat specs/billing.lazyspec.md')).status, 0);
    assert.equal(guard(bash("grep '## ' specs/billing.lazyspec.md")).status, 0);
  });
});

describe('A Call That Names No Locked Path Is Left Alone', () => {
  it('exits 0 and says nothing', () => {
    const r = guard(edit('src/refunds.js'));
    assert.equal(r.status, 0);
    assert.equal(r.stdout + r.stderr, '');
  });
});
