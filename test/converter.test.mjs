import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runScript } from './run-script.mjs';

// A browser never puts <script> on the clipboard, so drop the fixture's self-select helper.
const fixture = readFileSync(new URL('./fixtures/selection.html', import.meta.url), 'utf8')
  .replace(/<script>[\s\S]*?<\/script>/, '');
const MD = new URL('../src/copy-as-markdown.js', import.meta.url).pathname;
const QUOTED = new URL('../src/copy-as-markdown-quoted.js', import.meta.url).pathname;

const expected = [
  '## Fixture Heading',
  '',
  'A paragraph with **bold text**, *italic text*, `inline_code` and a [link label](https://example.com/page).',
  '',
  '- first bullet',
  '- second bullet',
  '',
  '1. step one',
  '2. step two',
  '',
  '```',
  'const a = 1 < 2;',
  'console.log(a);',
  '```',
  '',
  '> quoted words',
].join('\n');

test('Markdown button script copies the selection as Markdown', async () => {
  const r = await runScript(MD, fixture);
  assert.equal(r.status, 'Done');
  assert.equal(r.clipboard, expected);
});

test('Quoted button script prefixes every line with "> "', async () => {
  const r = await runScript(QUOTED, fixture);
  assert.equal(r.status, 'Done');
  assert.equal(r.clipboard, expected.split('\n').map((l) => '> ' + l).join('\n'));
});

test('empty selection copies nothing and says so', async () => {
  const r = await runScript(MD, '   ');
  assert.equal(r.status, 'No selection');
  assert.equal(r.clipboard, undefined);
});

test('Claude desktop code block (bare <pre>, no <code>) keeps its fence', async () => {
  const r = await runScript(MD, '<p>Run:</p><pre>npm test\nnpm run build</pre>');
  assert.equal(r.clipboard, 'Run:\n\n```\nnpm test\nnpm run build\n```');
});

test('code fence keeps its language', { todo: 'known bug: the language-xxx class is never captured' }, async () => {
  const r = await runScript(MD, '<pre><code class="language-js">let x;</code></pre>');
  assert.equal(r.clipboard, '```js\nlet x;\n```');
});

for (const [name, file] of [['Markdown', MD], ['Quoted', QUOTED]]) {
  test(`${name} button script writes plain text to the clipboard`, async () => {
    // Without an explicit format BTT 6.726 leaves the clipboard with no plain text at all.
    const r = await runScript(file, fixture);
    assert.equal(r.format, 'NSPasteboardTypeString');
  });
}
