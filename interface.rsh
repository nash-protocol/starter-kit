"reach 0.1";
"use strict";
// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
const SERIAL_VER = 0;
export const Event = () => [];
export const Participants = () => [
  Participant("Alice", {
    getParams: Fun(
      [],
      Object({
        foo: UInt,
      })
    ),
  }),
  ParticipantClass("Relay", {}),
];
export const Views = () => [];
export const Api = () => [];
export const App = (map) => {
  const [{ amt, ttl }, [addr, _], [Alice, Relay], _, _, _] = map;
  Alice.only(() => {
    const { foo } = declassify(interact.getParams());
  });
  Alice.publish(foo).pay(amt+foo+SERIAL_VER)
  .timeout(relativeTime(ttl), () => {
    Anybody.publish()
    transfer(balance()).to(addr)
    commit();
    exit();
  })
  transfer(amt).to(addr);
  commit();
  Relay.publish();
  transfer(balance()).to(addr)
  commit();
  exit();
};
// ----------------------------------------------
