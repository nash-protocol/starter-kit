import { loadStdlib } from "@reach-sh/stdlib";
import * as childBackend from "./build/index.Child.mjs";
import * as masterBackend from "./build/index.Master.mjs";

export const fromSome = (x, d) => {
  if (x.length !== 2 || x[0] === "None") {
    return d;
  } else {
    return x[1];
  }
};

const tokens = [
  {
    name: "v1",
    symbol: "V1",
    decimals: 0,
    supply: 1000,
  },
];

const stdlib = loadStdlib(process.env);

const showAccountInfo = async (name, acc) => {
  console.log("");
  console.log(`Account ${name}:`);
  console.log(`  Address: ${stdlib.formatAddress(acc.getAddress())}`);
  console.log(`  Balance: ${await acc.balanceOf()}`);
  console.log("");
};

const Test = async (backend) => {
  console.log("Running Test...");

  const pc = stdlib.parseCurrency;
  const bn = stdlib.bigNumberify;
  const startingBalance = pc(100);

  const [accAlice, accIssuer] = await stdlib.newTestAccounts(
    2,
    startingBalance
  );

  await stdlib.wait(1);

  await showAccountInfo("alice", accAlice);
  await showAccountInfo("issuer", accIssuer);

  console.log("===========================================");
  console.log("Minting tokens...");
  console.log("===========================================");
  const tokArr = await Promise.all(
    tokens.map((el) =>
      stdlib.launchToken(accIssuer, el.name, el.symbol, {
        decimals: el.decimals,
        supply: el.supply,
      })
    )
  );
  const tokObj = {};
  tokens.forEach((el, i) => (tokObj[el.name] = tokArr[i]));
  for (let i = 1; i < tokArr.length; i++) {
    await accAlice.tokenAccept(tokArr[i].id);
  }
  for (let i = 1; i < tokArr.length; i++) {
    await tokArr[i].mint(accAlice, 100);
  }
  console.log("Tokens minted!");

  console.log("Hello, Alice!");

  const ctcAlice = accAlice.contract(backend);

  // monitor events

  ["new", "setup", "grant", "ready", "foo"].forEach((el) => {
    ctcAlice.e[el].monitor((ej) => {
      console.log("...........................................");
      console.log(`${el} event!`);
      console.log(ej);
      console.log("...........................................");
    });
  });

  console.log("Deploying master contract...");

  await stdlib.withDisconnect(() =>
    ctcAlice.p.Alice({
      ready: () => {
        console.log("Ready!");
        stdlib.disconnect(null); // causes withDisconnect to immediately return null
      },
    })
  );

  await showAccountInfo("alice", accAlice);

  const ctcInfoMaster = await ctcAlice.getInfo();

  const ctcAddressMaster = stdlib.formatAddress(
    await ctcAlice.getContractAddress()
  );

  const accMaster = await stdlib.connectAccount({ addr: ctcAddressMaster });

  await showAccountInfo("ctc(master)", accMaster);

  console.log({ ctcInfoMaster });

  console.log({ ctcAddressMaster });

  const appCount = 1;

  const ctcs = [];

  const addrs = [];

  // New

  for (let i = 0; i < appCount; i++) {
    console.log(`Deploying contract ${i}...`);
    const ctc = await ctcAlice.a.Master.new();
    const ctc2 = accAlice.contract(childBackend, ctc);
    const addr = stdlib.formatAddress(await ctc2.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    ctcs.push(ctc);
    addrs.push(addr);
    console.log(ctc);
    console.log(stdlib.bigNumberToNumber(ctc));
    console.log(addr);
    console.log("Contract deployed!");
    await showAccountInfo("alice", accAlice);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
  }

  // Setup

  for (let i = 0; i < appCount; i++) {
    const ctcInfo = ctcs[i];
    const ctc2 = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc2.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    console.log(`Setting up contract ${i}...`);
    await ctcAlice.a.Master.setup(ctcInfo);
    console.log("Contract set up!");
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    await showAccountInfo("alice", accAlice);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
  }

  // Ready

  for (let i = 0; i < appCount; i++) {
    const ctcInfo = ctcs[i];
    const ctc = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    await stdlib.withDisconnect(() =>
      ctc.p.Alice({
        getParams: () => ({
          ctc: ctcInfoMaster,
          token: tokObj.v1.id,
        }),
        ready: () => {
          console.log("Ready!");
          stdlib.disconnect(null); // causes withDisconnect to immediately return null
        },
      })
    );
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc.v.state());
    await showAccountInfo("alice", accAlice);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
  }

  // Grant issuer

  do {
    const i = 0;
    const ctcInfo = ctcs[i];
    const ctc = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    await ctc.a.C.grant(accIssuer);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc.v.state());
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
  } while (0);

  // Call foo directly from child

  do {
    const i = 0;
    const ctcInfo = ctcs[i];
    const ctc = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    console.log(
      `issuer clicks: ${stdlib.bigNumberToNumber(
        fromSome(await ctc.v.clicks(accIssuer), stdlib.bigNumberify(0))
      )}`
    );
    console.log(
      `alice clicks: ${stdlib.bigNumberToNumber(
        fromSome(await ctc.v.clicks(accAlice), stdlib.bigNumberify(0))
      )}`
    );
    console.log("Issuer calling foo...");
    await ctc.a.U0.foo(accIssuer);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log("Alice calling foo...");
    await ctc.a.U0.foo(accAlice);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(
      `issuer clicks: ${stdlib.bigNumberToNumber(
        fromSome(await ctc.v.clicks(accIssuer), stdlib.bigNumberify(0))
      )}`
    );
    console.log(
      `alice clicks: ${stdlib.bigNumberToNumber(
        fromSome(await ctc.v.clicks(accAlice), stdlib.bigNumberify(0))
      )}`
    );
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc.v.state());
  } while (0);

  // Call foo2 remotely from master accessing 1 box

  do {
    const i = 0;
    const ctcInfo = ctcs[i];
    const ctc = accAlice.contract(masterBackend, ctcInfoMaster);
    const ctc2 = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc2.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    console.log("Alice calling foo2 (remote)...");
    await ctc.a.Master.foo2(ctcInfo, accIssuer);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log("Alice calling foo2 (remote)...");
    await ctc.a.Master.foo2(ctcInfo, accIssuer);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Alice calling foo3 (remote)...");
    await ctc.a.Master.foo3(ctcInfo, accIssuer, accAlice);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Alice calling foo4...");
    await ctc2.a.U0.foo4(accIssuer, accAlice);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Alice calling foo4 (remote)...");
    try {
      await ctc.a.Master.foo4(ctcInfo, accIssuer, accAlice); // "Error: Network request error. Received status 400: TransactionPool.Remember: transaction FLPXG4MGKITBQ44O23MG6JYTS4MQUI4QVXNBXXYEHM5NLMMLKA7Q: logic eval error: logic eval error: - would result negative. Details: pc=1500, opcodes=dup\nstore 0\n-\n. Details: pc=1264, opcodes=load 16\nitxn_field Applications\nitxn_submit\n
    } catch (e) {
      console.log(e);
    }
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Alice calling foo4...");
    await ctc2.a.U0.foo4(accIssuer, accAlice);
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Alice calling foo6 (remote)...");
    try {
      await ctc.a.Master.foo6(ctcInfo, accIssuer, accAlice);
    } catch (e) {
      console.log(e);
    }
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
  } while (0);

  do {
    const i = 0;
    const ctcInfo = ctcs[i];
    const ctc = accAlice.contract(masterBackend, ctcInfoMaster);
    const ctc2 = accAlice.contract(childBackend, ctcInfo);
    const addr = stdlib.formatAddress(await ctc2.getContractAddress());
    const acc = await stdlib.connectAccount({ addr });
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    console.log("Deleting boxes...");
    try {
      await ctc2.a.U0.foo5(accIssuer, accAlice);
      await ctc2.a.U0.foo5(accAlice, accIssuer);
    } catch (e) {
      console.log(e);
    }
    console.log(stdlib.bigNumberToNumber(await accAlice.balanceOf()));
    console.log(stdlib.formatCurrency(await accAlice.balanceOf()));
    console.log(await ctc2.v.state());
    console.log(await ctc2.v.clicks(accAlice));
    console.log(await ctc2.v.clicks(accIssuer));
    await showAccountInfo("alice", accAlice);
    await showAccountInfo("issuer", accIssuer);
    await showAccountInfo(`ctc(child${i})`, acc);
    await showAccountInfo("ctc(master)", accMaster);
  } while (0);

  console.log("Goodbye, Alice!");
};

const main = async () => {
  console.log("Running main...");
  await Test(masterBackend);
};

main();
