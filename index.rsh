'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Template
// Description: Reach App using Constructor
// Author: Nicholas Shellabarger
// Version: 0.0.3 - use lite
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
import { useConstructor } from '@nash-protocol/starter-kit#lite-v0.1.7r0:util.rsh'
import { Participants as AppParticipants,Views, Api, App } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(AppParticipants, Views, Api)));
// ----------------------------------------------