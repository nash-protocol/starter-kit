'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Template
// Description: Reach App using Constructor
// Author: Nicholas Shellabarger
// Version: 0.0.1 - initial
// Requires Reach v0.1.8
// ----------------------------------------------
import { useConstructor } from 'util.rsh'
import {
  Particpants as AppParticpants,
  Views as AppViews,
  Api as AppApi,
  main as template
} from 'interface.rsh'
export const main = Reach.App(() => 
  template(useConstructor(AppParticpants, AppViews, AppApi)));
// ----------------------------------------------
