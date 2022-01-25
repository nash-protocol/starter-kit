'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Template
// Description: Reach App using Constructor
// Author: Nicholas Shellabarger
// Version: 0.0.1 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
import { useConstructor } from 'util.rsh'
import { Particpants, Views, Api, App } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(Particpants, Views, Api)));
// ----------------------------------------------
