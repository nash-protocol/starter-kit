"reach 0.1";
"use strict";
// -----------------------------------------------
export const minBal = 100000;

// Main - Placeholder reach app

export const Main = Reach.App(() => {
  const A = Participant("Alice", {
    ready: Fun([], Null),
  });
  const B = Participant("Bob", {});
  init();
  A.publish();
  commit();
  B.publish();
  commit();
  exit();
});

export const main = Main;
// ----------------------------------------------
