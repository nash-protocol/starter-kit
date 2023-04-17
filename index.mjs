import { loadStdlib } from "@reach-sh/stdlib";
import * as childBackend from "./build/index.Child.mjs";
import * as masterBackend from "./build/index.Master.mjs";

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

  const [accAlice] = await stdlib.newTestAccounts(1, startingBalance);

  const ctcAlice = accAlice.contract(backend);

  console.log("Hello, Alice!");

  [
    "new",
    "grant",
    "ready",
  ].forEach((el) => {
    ctcAlice.e[el].monitor((ej) => {
      console.log("...........................................");
      console.log(`${el} event!`);
      console.log(ej);
      console.log("...........................................");
    });
  });

  await stdlib.withDisconnect(() =>
    ctcAlice.p.Alice({
      ready: () => {
        console.log("Ready!");
        stdlib.disconnect(null); // causes withDisconnect to immediately return null
      },
    })
  );

  const ctcInfo = await ctcAlice.getInfo();

  console.log({ ctcInfo });

  const appCount = 10;

  const ctcs = [];
  for (let i = 0; i < appCount; i++) {
    console.log(`Deploying contract ${i}...`);
    const ctc = await ctcAlice.a.Master.new();
    console.log(ctc);
    console.log(stdlib.bigNumberToNumber(ctc));
    console.log("Contract deployed!");
    ctcs.push(ctc);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
  }

  for (let i = 0; i < appCount; i++) {
    const ctcInfo = ctcs[i];
    console.log(`Setting up contract ${i}...`);
    await ctcAlice.a.Master.setup(ctcInfo);
    console.log("Contract set up!");
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
  }

  for (let i = 0; i < appCount; i++) {
    const ctcInfo = ctcs[i];
    // do some work on child contract
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
  }
  console.log("Goodbye, Alice!");
};

const main = async () => {
  console.log("Running main...");
  await Test(masterBackend);
};

main();