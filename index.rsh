"reach 0.1";
"use strict";
// -----------------------------------------------
export const minBal = 100000;

const TokenType = Token;

// Child - Placeholder reach child app

export const Child = Reach.App(() => {
  setOptions({ connectors: [ALGO] });
  const Params = Object({
    token: TokenType,
  });
  const D = Participant("Deployer", {
    getParams: Fun([], Params),
  });
  /*
  const A = Participant("Alice", {
    getParams: Fun([], Params),
    ready: Fun([], Null),
  });
  */
  const a = {
    U0: API("U0", {
      foo: Fun([Address], Bool),
      foo2: Fun([Address], Bool),
      foo3: Fun([Address, Address], Bool),
      foo4: Fun([Address, Address], Bool),
      foo5: Fun([Address, Address], Bool),
    }),
    C: API("C", {
      grant: Fun([Address], Bool),
    }),
  };
  const State = Struct([
    ["constructor", Address],
    ["token", TokenType],
    ["tokenAmount", UInt],
  ]);
  const v = View({
    state: Fun([], State),
    clicks: Fun([Address], UInt),
    likes: Fun([Address, Address], UInt),
  });
  init();
  D.only(() => {
    const { token } = declassify(interact.getParams());
  });
  D.publish(token);
  const ctc = fromSome(Contract.fromAddress(D), getContract()) // impossible
  /*
  commit();
  A.only(() => {
    const { ctc, token } = declassify(interact.getParams());
  });
  A.publish(ctc, token);
  */
  const r = remote(ctc, {
    Child_ready: Fun([Contract, TokenType], Bool),
    Child_grant: Fun([Contract, TokenType, Address], Bool),
    Child_foo: Fun([Contract, TokenType, Address], Bool),
  });
  enforce(r.Child_ready(ctc, token), "Child app not announced as ready");
  const clickM = new Map(UInt);
  const likeM = new Map(Tuple(Address, Address), UInt);
  const initialState = {
    constructor: D,
    token,
    tokenAmount: 0,
  };
  const [s] = parallelReduce([initialState])
    .while(true)
    .invariant(balance() >= 0, "balance accurate")
    .invariant(balance(token) == 0, "token balance accurate")
    .define(() => {
      v.state.set(() => State.fromObject(s));
      v.clicks.set((addr) => fromSome(clickM[addr], 0));
      v.likes.set((addr1, addr2) => fromSome(likeM[[addr1, addr2]], 0));
    })
    .paySpec([token])
    .api_(a.U0.foo, (addr) => {
      return [
        (k) => {
          k(true);
          clickM[addr] = fromSome(clickM[addr], 0) + 1;
          enforce(r.Child_foo(ctc, token, addr), "Child app rejected grant");
          return [s];
        },
      ];
    })
    .api_(a.U0.foo2, (addr) => {
      return [
        (k) => {
          k(true);
          clickM[addr] = fromSome(clickM[addr], 0) + 1;
          return [s];
        },
      ];
    })
    .api_(a.U0.foo3, (addr1, addr2) => {
      return [
        (k) => {
          k(true);
          clickM[addr1] = fromSome(clickM[addr1], 0) + 1;
          clickM[addr2] = fromSome(clickM[addr2], 0) + 1;
          return [s];
        },
      ];
    })
    .api_(a.U0.foo4, (addr1, addr2) => {
      return [
        [1000000, [0, token]],
        (k) => {
          k(true);
          clickM[addr1] = fromSome(clickM[addr1], 0) + 1;
          clickM[addr2] = fromSome(clickM[addr2], 0) + 1;
          likeM[[addr1, addr2]] = fromSome(likeM[[addr1, addr2]], 0) + 1; // // "Error: Network request error. Received status 400: TransactionPool.Remember: transaction FLPXG4MGKITBQ44O23MG6JYTS4MQUI4QVXNBXXYEHM5NLMMLKA7Q: logic eval error: logic eval error: - would result negative. Details: pc=1500, opcodes=dup\nstore 0\n-\n. Details: pc=1264, opcodes=load 16\nitxn_field Applications\nitxn_submit\n
          return [s];
        },
      ];
    })
    .api_(a.U0.foo5, (addr1, addr2) => {
      return [
        (k) => {
          k(true);
          clickM[addr1] = fromSome(clickM[addr1], 0) + 1;
          clickM[addr2] = fromSome(clickM[addr2], 0) + 1;
          likeM[[addr1, addr2]] = fromSome(likeM[[addr1, addr2]], 0) + 1;
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
      launch: Fun([TokenType], Contract),
      //new: Fun([], Contract),
      //setup: Fun([Contract], Bool),
      foo2: Fun([Contract, Address], Bool),
      foo3: Fun([Contract, Address, Address], Bool),
      foo4: Fun([Contract, Address, Address], Bool),
    }),
    child: API("Child", {
      ready: Fun([Contract, TokenType], Bool),
      grant: Fun([Contract, TokenType, Address], Bool),
      foo: Fun([Contract, TokenType, Address], Bool),
    }),
  };
  const e = {
    child: Events({
      //new: [Contract],
      //setup: [Contract],
      ready: [Contract, TokenType],
      grant: [Contract, TokenType, Address],
      foo: [Contract, TokenType, Address],
    }),
  };
  init();
  A.publish();
  A.interact.ready();
  const [] = parallelReduce([])
    .invariant(balance() == 0, "balance accurate")
    .while(true)
    .api_(a.master.launch, (token) => {
      check(this == A, "Must be authorized");
      return [
        minBal,
        (k) => {
          const ctc = new Contract(Child)([0]);
          const { publish } = remote(ctc, {
            publish: Fun([Bytes(4), Tuple(UInt, TokenType)], Null),
          });
          publish.pay(minBal).ALGO({ rawCall: true })(
            Bytes.fromHex("0x5256fdac"), // sha512/256(_reachp_0((uint64,uint64))void)
            [0, token]
          );
          k(ctc);
          return [];
        },
      ];
    })
    /*
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
    .api_(a.master.setup, (x) => {
      check(this == A, "Must be authorized");
      return [
        minBal,
        (k) => {
          const { publish } = remote(ctc, {
            publish: Fun([Bytes(4), Tuple(UInt)], Null),
          });
          publish.pay(minBal).ALGO({ rawCall: true })(
            Bytes.fromHex("0xc194ad99"), // sha512/256(_reach_p0((uint64))void)
            [0],
          );
          e.child.setup(ctc);
          k(true);
          return [];
        },
      ];
    })
    */
    .api_(a.master.foo2, (ctc, addr) => {
      return [
        (k) => {
          k(true);
          const r = remote(ctc, {
            U0_foo2: Fun([Address], Bool),
          });
          k(
            r.U0_foo2.ALGO({
              fees: 1,
              apps: [ctc],
              boxes: [[ctc, 0, addr]],
            })(addr)
          );
          return [];
        },
      ];
    })
    .api_(a.master.foo3, (ctc, addr1, addr2) => {
      return [
        (k) => {
          k(true);
          const r = remote(ctc, {
            U0_foo3: Fun([Address, Address], Bool),
          });
          k(
            r.U0_foo3.ALGO({
              fees: 10,
              apps: [ctc],
              boxes: [
                [ctc, 0, addr1],
                [ctc, 0, addr2],
              ],
            })(addr1, addr2)
          );
          return [];
        },
      ];
    })
    .api_(a.master.foo4, (ctc, addr1, addr2) => {
      return [
        (k) => {
          k(true);
          const r = remote(ctc, {
            U0_foo4: Fun([Address, Address], Bool),
          });
          k(
            r.U0_foo4.ALGO({
              fees: 1,
              apps: [ctc],
              boxes: [
                [ctc, 0, addr1],
                [ctc, 0, addr2],
                [ctc, 1, [addr1, addr2]],
              ],
            })(addr1, addr2)
          );
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
    })
    .api_(a.child.foo, (ctc, token, addr) => {
      return [
        (k) => {
          k(true);
          e.child.foo(ctc, token, addr);
          return [];
        },
      ];
    });
  commit();
  exit();
});
export const main = Master;
// ----------------------------------------------
