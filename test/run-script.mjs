// Runs one of the BTT "Run Real JavaScript" scripts from src/ outside BTT.
// BTT gives the script three functions; here they are stand-ins:
//   get_selection         -> returns the HTML we hand it
//   set_clipboard_content -> records what the script tried to copy
//   returnToBTT           -> records the script's final status
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

export async function runScript(file, selectionHtml) {
  const result = { clipboard: undefined, format: undefined, status: undefined };
  const context = vm.createContext({
    get_selection: async () => selectionHtml,
    set_clipboard_content: async ({ content, format }) => { result.clipboard = content; result.format = format; },
    returnToBTT: (s) => { result.status = s; },
  });
  vm.runInContext(readFileSync(file, 'utf8'), context);
  for (let i = 0; i < 50 && result.status === undefined; i++) await new Promise((r) => setTimeout(r, 5));
  return result;
}
