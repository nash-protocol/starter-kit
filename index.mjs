import { loadStdlib } from "@reach-sh/stdlib";
import * as mainBackend from "./build/index.main.mjs";

const stdlib = loadStdlib(process.env);

const loadEvents = async (ctc, eventName) => {
  if (!(eventName in ctc.e)) return [];
  console.log("Loading events...");
  const evts = [];
  await Promise.race([ctc.e[eventName].next(), sleep(1000, "", "reject")])
    .then((x) => {
      evts.push(x);
    })
    .catch(() => {});
  return evts;
};

const showBalances = async (name, acc, tok) => {
  const netBalance = stdlib.formatCurrency(await acc.balanceOf());
  const tokBalance = stdlib.formatWithDecimals(await acc.balanceOf(tok), 0);
  console.log(`(${name}) Balance:`, netBalance);
  console.log(`${tok} Balance:`, tokBalance);
};

const Test = async (backend) => {
  console.log("Running Test...");

  const pc = stdlib.parseCurrency;
  const bn = stdlib.bigNumberify;
  const startingBalance = pc(100);

  const [accAlice, accBob] = await stdlib.newTestAccounts(2, startingBalance);

  const ctcAlice = accAlice.contract(backend);

  console.log(ctcAlice);

  console.log("Hello, Alice!");

  await stdlib.withDisconnect(() =>
    ctcAlice.p.Alice({
      ready: () => {
        console.log("Ready!");
        stdlib.disconnect(null); // causes withDisconnect to immediately return null
      },
    })
  );

  const ctcInfo = await ctcAlice.getInfo();

  const ctcBob = accBob.contract(backend, ctcInfo);

  console.log({ ctcInfo });
};

const main = async () => {
  console.log("Running main...");
  await Test(mainBackend);
};

main();