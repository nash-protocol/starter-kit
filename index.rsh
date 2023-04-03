'reach 0.1';
'use strict'
// -----------------------------------------------
export const main = Reach.App(() => {
  setOptions({});
  const Alice = Participant('Alice', {});
  init();
  Alice.publish();
  commit();
  exit();
});
// ----------------------------------------------
