'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Utilities
// Author: Nicholas Shellabarger
// Version: 0.0.3 - fix syntax error
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
  const particpants = particpantFunc()
  const views = viewFunc()
  const api = apiFunc()
  init()
  verify(Constructor, Verifier, Contractee)
  return {
    particpants,
    views,
    api
  }
}
