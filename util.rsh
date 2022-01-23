'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Utilities
// Author: Nicholas Shellabarger
// Version: 0.0.1 - initial
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
      addr2: Address, // reserved addr
      addr3: Address, // reserved addr
      addr4: Address, // reserved addr
      addr5: Address, // reserved addr
      // activation params
      amt: UInt, // fee gate
      tok: Token, // token gate
      // token params
      token_name: Bytes(32), 
      token_symbol: Bytes(8)
      //token_url: Bytes(96)
      //token_metadata: Bytes(32),
      //token_supply: UInt,
      //token_decimals: UInt
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
      addr2, // reserved
      addr3, // reserved
      addr4, // reserved
      addr5, // reserved
      amt,
      tok,
      token_name,
      token_symbol
      //token_url
      //token_metadata,
      //token_supply,
      //token_decimals
    } = declassify(interact.getParams())
    assume(true)
  })
  Constructor
    .publish(
      addr,
      addr2, // reserved 
      addr3, // reserved
      addr4, // reserved
      addr5, // reserved
      amt,
      tok,
      token_name,
      token_symbol
      //token_url
      //token_metadata,
      //token_supply,
      //token_decimals
    )
  require(true)
  Verifier.set(addr)
  commit()
  Constructor.only(() => interact.signal());
  return {
      addr,
      addr2, // reserved
      addr3, // reserved
      addr4, // reserved
      addr5, // reserved
      amt,
      tok,
      token_name,
      token_symbol
      //token_url
      //token_metadata,
      //token_supply,
      //token_decimals
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
    addr2, 
    addr3, 
    addr4, 
    addr5, 
    amt, 
    tok,
    token_name,
    token_symbol
    //token_url
    //token_metadata,
    //token_supply,
    //token_decimals
  } = construct(Constructor, Verifier)
  binaryFork(Verifier, Contractee, addr, amt) 
  return [
    {
      addr: addr2,
      addr2: addr3,
      addr3: addr4,
      addr4: addr5
    },
    {
      tok,
      token_name,
      token_symbol
      //token_url
      //token_metadata,
      //token_supply,
      //token_decimals
    }
  ]
}
export const useConstructor = (particpantFunc = () => {}, viewFunc = () => {}, apiFunc = () => {}) => {
  const [Constructor, Verifier, Contractee] = DefaultParticipants()
  const particpants = particpantFunc()
  const views = viewFunc()
  const api = apiFunc()
  init()
  const [addrs, toks] = verify(Constructor, Verifier, Contractee)
  return [addrs, toks, particpants, views, api]
}
