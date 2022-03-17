import { loadStdlib } from "@reach-sh/stdlib";
import assert from "assert";

const [, , infile] = process.argv;

(async () => {
  console.log("START");

  const backend = await import(`./build/${infile}.main.mjs`);
  const stdlib = await loadStdlib();
  const startingBalance = stdlib.parseCurrency(1000);

  const accAlice = await stdlib.newTestAccount(startingBalance);
  const accBob = await stdlib.newTestAccount(startingBalance);
  const accEve = await stdlib.newTestAccount(startingBalance);

  const accs = await Promise.all(
    Array.from({ length: 10 }).map(() => stdlib.newTestAccount(startingBalance))
  );

  const reset = async (accs) => {
    await Promise.all(accs.map(rebalance));
    await Promise.all(
      accs.map(async (el) =>
        console.log(`balance (acc): ${await getBalance(accAlice)}`)
      )
    );
  };

  const rebalance = async (acc) => {
    if ((await getBalance(acc)) > 1000) {
      await stdlib.transfer(
        acc,
        accEve?.networkAccount?.addr,
        stdlib.parseCurrency((await getBalance(acc)) - 1000)
      );
    } else {
      await stdlib.transfer(
        accEve,
        acc?.networkAccount?.addr,
        stdlib.parseCurrency(1000 - (await getBalance(acc)))
      );
    }
  };

  const zorkmid = await stdlib.launchToken(accAlice, "zorkmid", "ZMD");
  const gil = await stdlib.launchToken(accBob, "gil", "GIL");
  await accAlice.tokenAccept(gil.id);
  await accBob.tokenAccept(zorkmid.id);

  const getBalance = async (who) =>
    stdlib.formatCurrency(await stdlib.balanceOf(who), 4);

  const beforeAlice = await getBalance(accAlice);
  const beforeBob = await getBalance(accBob);

  const getParams = (addr) => ({
    addr,
    addr2: addr,
    addr3: addr,
    addr4: addr,
    addr5: addr,
    amt: stdlib.parseCurrency(1),
    tok: zorkmid.id,
    token_name: "",
    token_symbol: "",
    secs: 0,
    secs2: 0,
  });

  // (1) can be deleted before activation
  console.log("CAN DELETED INACTIVE");
  (async (acc) => {
    let addr = acc?.networkAccount?.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
      }),
      backend.Verifier(ctc, {}),
    ]).catch(console.dir);
    let appId = await ctc.getInfo();
  })(accAlice);
  await stdlib.wait(4);

  await reset([accAlice, accBob]);

  // (2) constructor receives payment on activation
  console.log("CAN ACTIVATE WITH PAYMENT");
  await (async (acc, acc2) => {
    let addr = acc?.networkAccount?.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
      }),
    ]);
    let appId = await ctc.getInfo();
    let ctc2 = acc2.contract(backend, appId);
    Promise.all([backend.Contractee(ctc2, {})]);
    await stdlib.wait(50);
  })(accAlice, accBob);
  await stdlib.wait(4);

  const afterAlice = await getBalance(accAlice);
  const afterBob = await getBalance(accBob);

  const diffAlice = Math.round(afterAlice - beforeAlice);
  const diffBob = Math.round(afterBob - beforeBob);

  console.log(
    `Alice went from ${beforeAlice} to ${afterAlice} (${diffAlice}).`
  );
  console.log(`Bob went from ${beforeBob} to ${afterBob} (${diffBob}).`);

  assert.equal(diffAlice, 1);
  assert.equal(diffBob, -1);

  await reset([accAlice, accBob]);

  process.exit();
})();
