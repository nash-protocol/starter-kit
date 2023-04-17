"reach 0.1";
"use strict";
// -----------------------------------------------
export const minBal = 100000;

// Child - Placeholder reach child app

export const Child = Reach.App(() => {
  setOptions({ connectors: [ALGO] });
  const D = Participant("Deployer", {});
  const Params = Object({
    ctc: Contract,
    token: Token,
  });
  const A = Participant("Alice", {
    getParams: Fun([], Params),
    ready: Fun([], Null),
  });
  const a = {
    U0: API("U0", {
      foo: Fun([], Bool),
    }),
    C: API("C", {
      grant: Fun([Address], Bool),
    }),
  };
  const State = Struct([
    ["constructor", Address],
    ["token", Token],
    ["tokenAmount", UInt],
  ]);
  const v = View({
    state: Fun([], State),
  });
  init();
  D.publish();
  commit();
  A.only(() => {
    const { ctc, token } = declassify(interact.getParams());
  });
  A.publish(ctc, token);
  A.interact.ready();
  const r = remote(ctc, {
    Child_ready: Fun([Contract, Token], Bool),
    Child_grant: Fun([Contract, Token, Address], Bool),
  });
  enforce(
    r.Child_ready(getContract(), token),
    "Child app not announced as ready"
  );
  const safeM = new Map(UInt);
  const initialState = {
    constructor: A,
    token,
    tokenAmount: 0,
  };
  const [s] = parallelReduce([initialState])
    .while(true)
    .invariant(balance() == 0, "balance accurate")
    .invariant(balance(token) == safeM.sum())
    .define(() => {
      v.state.set(() => State.fromObject(s));
    })
    .paySpec([token])
    .api_(a.U0.foo, () => {
      return [
        (k) => {
          k(true);
          return [s];
        },
      ];
    })
    .api_(a.C.grant, (addr) => {
      check(this == s.constructor, "Only constructor can grant");
      return [
        (k) => {
          enforce(r.Child_grant(ctc, token, addr), "Child app rejected grant");
          k(true);
          return [
            {
              ...s,
              constructor: addr,
            },
          ];
        },
      ];
    });
  commit();
  exit();
});

// Master - Placeholder reach master app

export const Master = Reach.App(() => {
  setOptions({ connectors: [ALGO] });
  const A = Participant("Alice", {
    ready: Fun([], Null),
  });
  const a = {
    master: API("Master", {
      new: Fun([], Contract),
      setup: Fun([Contract], Bool),
    }),
    child: API("Child", {
      ready: Fun([Contract, Token], Bool),
      grant: Fun([Contract, Token, Address], Bool),
    }),
  };
  const e = {
    child: Events({
      new: [Contract],
      setup: [Contract],
      ready: [Contract, Token],
      grant: [Contract, Token, Address],
    }),
  };
  init();
  A.publish();
  A.interact.ready();
  const [] = parallelReduce([])
    .invariant(balance() == 0, "balance accurate")
    .while(true)
    .api_(a.master.new, () => {
      check(this == A, "Must be authorized");
      return [
        (k) => {
          const ctc = new Contract(Child)([0]);
          e.child.new(ctc);
          k(ctc);
          return [];
        },
      ];
    })
    .api_(a.master.setup, (ctc) => {
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
          e.child.setup(ctc);
          k(true);
          return [];
        },
      ];
    })
    .api_(a.child.ready, (ctc, tok) => {
      return [
        (k) => {
          k(true);
          e.child.ready(ctc, tok);
          return [];
        },
      ];
    })
    .api_(a.child.grant, (ctc, token, addr) => {
      return [
        (k) => {
          k(true);
          e.child.grant(ctc, token, addr);
          return [];
        },
      ];
    });
  commit();
  exit();
});
export const main = Master;
// ----------------------------------------------
