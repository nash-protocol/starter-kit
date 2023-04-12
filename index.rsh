"reach 0.1";
"use strict";
// -----------------------------------------------
export const minBal = 100000;

// Child - Placeholder reach child app

export const Child = Reach.App(() => {
  const D = Participant("Deployer", {});
  const Params = Object({
    a: UInt,
  });
  const A = Participant("Alice", {
    getParams: Fun([], Params),
  });
  init();
  D.publish();
  commit();
  A.only(() => {
    const { a } = declassify(interact.getParams());
  });
  A.publish(a);
  commit();
  exit();
});

// Master - Placeholder reach master app

export const Master = Reach.App(() => {
  const A = Participant("Alice", {
    ready: Fun([], Null),
  });
  const a = API("Child", {
    new: Fun([], Contract),
    setup: Fun([Contract], Bool),
  });
  const e = Events({
    appReady: [Contract],
    appPrelaunch: [Contract],
  });
  init();
  A.publish();
  A.interact.ready();
  const [] = parallelReduce([])
    .invariant(balance() == 0, "balance accurate")
    .while(true)
    .api_(a.new, () => {
      check(this == A, "Must be authorized");
      return [
        (k) => {
          const ctc = new Contract(Child)([0]);
          e.appReady(ctc);
          k(ctc);
          return [];
        },
      ];
    })
    .api_(a.setup, (ctc) => {
      check(this == A, "Must be authorized");
      return [
        minBal,
        (k) => {
          const { publish } = remote(ctc, {
            publish: Fun([Bytes(4), Tuple(UInt)], Null),
          });
          publish.pay(minBal).ALGO({ rawCall: true })( 
            Bytes.fromHex("0xc194ad99"), // sha256(_reach_p0((uint64))void)
            [0]
          );
          e.appPrelaunch(ctc);
          k(true);
          return [];
        },
      ];
    });
  commit();
  exit();
});
export const main = Master;
// ----------------------------------------------
