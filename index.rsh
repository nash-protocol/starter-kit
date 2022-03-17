'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Template
// Description: Reach App using Constructor
// Author: Nicholas Shellabarger
// Version: 0.1.0 - update version
// Requires Reach v0.1.9-rc.2 (402c3faa)
// ----------------------------------------------
import { useConstructor } from '@nash-protocol/starter-kit#lite-v0.1.9r1:util.rsh'
import { Participants as AppParticipants,Views, Api, App } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(AppParticipants, Views, Api)));
// ----------------------------------------------
