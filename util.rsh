'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Utilities
// Author: Nicholas Shellabarger
// Version: 0.0.5 - returns p v a array
// Requires Reach v0.1.8
// -----------------------------------------------
export const max = ((a, b) => a > b ? a : b)
export const min = (a, b) => a < b ? a : b
export const common = {
    ...hasConsoleLogger,
    close: Fun([], Null)
}
export const hasSignal = {
  signal: Fun([], Null)
}
export const constructorInteract = ({
    ...common,
    ...hasSignal,
    getParams: Fun([], Object({
      addr: Address, // contract addr
      // activation params
      amt: UInt, // fee gate
    })),
    signal: Fun([], Null)
  })
export const relayInteract = {
  ...common
}
export const construct = (Constructor, Verifier) => {
  Constructor.only(() => {
    const {
      addr,
      amt,
    } = declassify(interact.getParams())
    assume(true)
  })
  Constructor
    .publish(
      addr,
      amt
    )
  require(true)
  Verifier.set(addr)
  commit()
  Constructor.only(() => interact.signal());
  return {
      addr,
      amt,
  }
}
export const binaryFork = (A, B, addr, amt) => {
  fork()
  .case(
    A, 
    (() => ({
      msg: 1,
      when: true
    })),
    ((_) => 0),
    (v) => {
      require(v == 1 && this == addr)
      commit()
      exit()
    })
  .case(
    B, 
    (() => ({
      msg: 2,
      when: true
    })),
    ((_) => amt),
    (v) => {
      require(v == 2)
      transfer(amt).to(addr)
      commit()
    })
  .timeout(false)
}
export const DefaultParticipants = () => [
  Participant('Constructor', constructorInteract),
  Participant('Verifier', relayInteract),
  Participant('Contractee', relayInteract) 
]
export const verify = (Constructor, Verifier, Contractee) => {
  const { 
    addr, 
    amt, 
  } = construct(Constructor, Verifier)
  binaryFork(Verifier, Contractee, addr, amt) 
}
export const useConstructor = (particpantFunc = () => {}, viewFunc = () => {}, apiFunc = () => {}) => {
  const [Constructor, Verifier, Contractee] = DefaultParticipants()
  const p = particpantFunc()
  const v = viewFunc()
  const a = apiFunc()
  init()
  verify(Constructor, Verifier, Contractee)
  return [p, v, a];
}
export const depositTok7 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
    assume(tok0 != tok5);
    assume(tok0 != tok6);
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4, tok5, tok6);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  require(tok0 != tok5);
  require(tok0 != tok6);
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
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
    assume(tok0 != tok5);
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4, tok5);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  require(tok0 != tok5);
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
  ]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3, tok4, tok5] };
};
export const depositTok5 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3, tok4],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
  });
  A.publish(amount, tok0, tok1, tok2, tok3, tok4);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
  ]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3, tok4] };
};
export const depositTok4 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2, tok3],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
  });
  A.publish(amount, tok0, tok1, tok2, tok3);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
  ]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2, tok3] };
};
export const depositTok3 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1, tok2],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
  });
  A.publish(amount, tok0, tok1, tok2);
  require(tok0 != tok1);
  require(tok0 != tok2);
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
  ]);
  commit();
  return { amount, tokens: [tok0, tok1, tok2] };
};
export const depositTok2 = (A) => {
  A.only(() => {
    const {
      amount,
      tokens: [tok0, tok1],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
  });
  A.publish(amount, tok0, tok1);
  require(tok0 != tok1);
  commit();
  A.pay([
    0,
    [1, tok0],
    [1, tok1],
  ]);
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
  A.pay([
    0,
    [1, tok0]
  ]);
  commit();
  return { amount, tokens: [tok0] };
};
export const requireTok7 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
    assume(tok0 != tok5);
    assume(tok0 != tok6);
  });
  A.publish(tok0, tok1, tok2, tok3, tok4, tok5, tok6);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  require(tok0 != tok5);
  require(tok0 != tok6);
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6] };
};
export const requireTok6 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
    assume(tok0 != tok5);
  });
  A.publish(tok0, tok1, tok2, tok3, tok4, tok5);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  require(tok0 != tok5);
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4, tok5] };
};
export const requireTok5 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3, tok4],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
    assume(tok0 != tok4);
  });
  A.publish(tok0, tok1, tok2, tok3, tok4);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  require(tok0 != tok4);
  commit();
  return { tokens: [tok0, tok1, tok2, tok3, tok4] };
};
export const requireTok4 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2, tok3],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
    assume(tok0 != tok3);
  });
  A.publish(tok0, tok1, tok2, tok3);
  require(tok0 != tok1);
  require(tok0 != tok2);
  require(tok0 != tok3);
  commit();
  return { tokens: [tok0, tok1, tok2, tok3] };
};
export const requireTok3 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1, tok2],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
    assume(tok0 != tok2);
  });
  A.publish(tok0, tok1, tok2);
  require(tok0 != tok1);
  require(tok0 != tok2);
  commit();
  return { tokens: [tok0, tok1, tok2] };
};
export const requireTok2 = (A) => {
  A.only(() => {
    const {
      tokens: [tok0, tok1],
    } = declassify(interact.getParams());
    assume(tok0 != tok1);
  });
  A.publish(tok0, tok1);
  require(tok0 != tok1);
  commit();
  return { tokens: [tok0, tok1] };
};
export const requireTok = (A) => {
  A.only(() => {
    const {
      tokens: [tok0]
    } = declassify(interact.getParams());
  });
  A.publish(tok0);
  commit();
  return { tokens: [tok0] };
};