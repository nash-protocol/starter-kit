"reach 0.1";
"use strict";
// -----------------------------------------------
// Name: Utilities
// Author: Nicholas Shellabarger
// Version: 0.0.5 - returns p v a array
// Requires Reach v0.1.8
// -----------------------------------------------
export const max = (a, b) => (a > b ? a : b);
export const min = (a, b) => (a < b ? a : b);
const common = {
  ...hasConsoleLogger,
  close: Fun([], Null),
};
export const commonInteract = common;
export const constructorInteract = {
  ...common,
  getParams: Fun(
    [],
    Object({
      addr: Address, // contract addr
      amt: UInt, // activation params fee gate
      ttl: UInt, // relative time (block) to allow for verification
    })
  ),
};
export const construct = (Constructor) => {
  Constructor.only(() => {
    const { addr, amt, ttl } = declassify(interact.getParams());
    assume(true);
  });
  Constructor.publish(addr, amt, ttl);
  require(true);
  commit();
  return {
    addr,
    amt,
    ttl,
  };
};
export const binaryFork = (A, B, addr, amt, ttl) => {
  fork()
    .case(
      A,
      () => ({
        msg: 1,
        when: true,
      }),
      (_) => 0,
      (v) => {
        require(v == 1 && this == A /* verifier */);
        commit();
        exit();
      }
    )
    .case(
      B,
      () => ({
        msg: 2,
        when: true,
      }),
      (_) => amt,
      (v) => {
        require(v == 2);
        transfer(amt).to(addr);
        commit();
      }
    )
    .timeout(relativeTime(ttl), () => {
      Anybody.publish();
      commit();
      exit();
    });
};
export const DefaultParticipants = () => [
  Participant("Constructor", constructorInteract),
  Participant("Verifier", constructorInteract),
];
export const verify = (Constructor, Verifier, Contractee) => {
  const { addr, amt, ttl } = construct(Constructor, Verifier);
  binaryFork(Verifier, Contractee, addr, amt, ttl);
  return addr;
};
export const useConstructor = (
  particpantFunc = () => {},
  viewFunc = () => {},
  apiFunc = () => {},
  eventFunc = () => {}
) => {
  const [Constructor, _] = DefaultParticipants();
  const p = particpantFunc();
  const v = viewFunc();
  const a = apiFunc();
  const e = eventFunc();
  init();
  const { addr, amt, ttl } = construct(Constructor);
  return [{ amt, ttl }, [addr, Constructor], p, v, a, e];
};
// deposit tokens
export const depositTok7 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4, tok5, tok6));
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4, tok5, tok6);
  require(distinct(tok0, tok1, tok2, tok3, tok4, tok5, tok6));
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
    [1, tok6],
  ]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6] };
};
export const depositTok6 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4, tok5));
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4, tok5);
  require(distinct(tok0, tok1, tok2, tok3, tok4, tok5));
  commit();
  A.pay([0, [1, tok0], [1, tok1], [1, tok2], [1, tok3], [1, tok4], [1, tok5]]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3, tok4, tok5] };
};
export const depositTok5 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3, tok4],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4));
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4);
  require(distinct(tok0, tok1, tok2, tok3, tok4));
  commit();
  A.pay([0, [1, tok0], [1, tok1], [1, tok2], [1, tok3], [1, tok4]]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3, tok4] };
};
export const depositTok4 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3));
  });
  A.publish(amount, tok0, tok1, tok2, tok3);
  require(distinct(tok0, tok1, tok2, tok3));
  commit();
  A.pay([0, [1, tok0], [1, tok1], [1, tok2], [1, tok3]]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3] };
};
export const depositTok3 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2));
  });
  A.publish(amount, tok0, tok1, tok2);
  require(distinct(tok0, tok1, tok2));
  commit();
  A.pay([0, [1, tok0], [1, tok1], [1, tok2]]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2] };
};
export const depositTok2 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1));
  });
  A.publish(amount, tok0, tok1);
  require(distinct(tok0, tok1));
  commit();
  A.pay([0, [1, tok0], [1, tok1]]);
  commit();
  return { amount, tokens: [tok0, tok1] };
};
export const depositTok = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0],
    } = declassify(interact.getParams());
  });
  A.publish(amount, tok0);
  commit();
  A.pay([0, [1, tok0]]);
  commit();
  return { amount, tokens: [tok0] };
};
// require tokens
export const requireTok7 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4, tok5, tok6));
  });
  A.publish(tok0, tok1, tok2, tok3, tok4, tok5, tok6);
  require(distinct(tok0, tok1, tok2, tok3, tok4, tok5, tok6));
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6] };
};
export const requireTok6 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4, tok5));
  });
  A.publish(tok0, tok1, tok2, tok3, tok4, tok5);
  require(distinct(tok0, tok1, tok2, tok3, tok4, tok5));
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4, tok5] };
};
export const requireTok5 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3, tok4));
  });
  A.publish(tok0, tok1, tok2, tok3, tok4);
  require(distinct(tok0, tok1, tok2, tok3, tok4));
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4] };
};
export const requireTok4 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2, tok3));
  });
  require(distinct(tok0, tok1, tok2, tok3));
  commit();
  return { tokens: [tok0, tok1, tok2, tok3] };
};
export const requireTok3 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1, tok2));
  });
  A.publish(tok0, tok1, tok2);
  require(distinct(tok0, tok1, tok2));
  commit();
  return { tokens: [tok0, tok1, tok2] };
};
export const requireTok2 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1],
    } = declassify(interact.getParams());
    assume(distinct(tok0, tok1));
  });
  A.publish(tok0, tok1);
  require(distinct(tok0, tok1));
  commit();
  return { tokens: [tok0, tok1] };
};
export const requireTok = (A) => {
  A.only(() => {
    const {
      tokens: [tok0],
    } = declassify(interact.getParams());
  });
  A.publish(tok0);
  commit();
  return { tokens: [tok0] };
};
