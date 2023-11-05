# starter-kit

The NP starter kit describes how to launch a NP RApp in minutes. Quickstart assumes that the local development environment for Reach has been setup.

## quickstart

commands
```bash
clone_sk() {
git clone git@github.com:nash-protocol/starter-kit.git ${1} 
cd ${_} 
source np.sh 
np
}
```

output
```json
{"info":66944916}
```

## how does it work

NP provides a nonintrusive wrapper allowing apps to be configurable before deployment and created on the fly without incurring global storage.   
Connect to the constructor and receive an app id.   
Activate the app by paying for deployment and storage cost. 
After activation, your RApp takes control.

## how to activate my app

In your the frontend of your NPR included Contractee participation. Currently, a placeholder fee is required for activation. Later an appropriate fee amount will be used.

```js
ctc = acc.contract(backend, id)
backend.Contractee(ctc, {})
```

## templates

Templates improve the developer and user experience by pre-opting into assets before the first message by the contract manager.

Each template behaves more or less the same at this point with exception of earlier templates. The difference is the number of assets that are opted in before reaching the main program.

atom - 0 assets  
hydrogen - 1 asset
...

Simply update the .env file and index.rsh to switch templates.


### common

#### index

```
import { useConstructor } from '@nash-protocol/starter-kit#<tag>:util.rsh'
import { Participants as AppParticipants,Views, Api, App, Event } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(AppParticipants, Views, Api, Event)));
```

#### interface

```
export const Participants = () => [];
export const Views = () => [];
export const Api = () => [];
export const Event = () => [];
export const App = (_) => {
  Anybody.publish();
  commit();
  exit();
};
```

#### .env

```
export REACH_VERSION=<version number or hash>
API_ENDPOINT_TESTNET=<launcher endpoint>
TEMPLATE_NAME=<template name>
ZB_AUTH_TOKEN=<api key>
```

### main program head

The main program should look like this to get started

```
export const App = (map) => {
  const [
    { amt, ttl }, // activation cost, time to live
    [addr, _], // constructors
    [Manager, Relay], // your participants
    [v], // your views
    [a], // your apis
    [e], // your events
  ] = map;
```

If not using map then this works

```
export const App = (_) => {
```

The first participants message SHOULD receive payment in `amt` from Manager. `amt` SHOULD be transfered to `addr` to compensate the constuctor for deployment cost and associated min balance changes. Payment of activation fee ensures sustainable use of launcher service. 

```
  Manager.publish(max, tokenAmount)
    // checks
    .pay([amt])
    .timeout(relativeTime(ttl), () => {
      Anybody.publish();
      commit();
      exit();
    });
  transfer(amt).to(addr);
```
  

### atom

Template with no asset pre-optin

#### atom-v0.1.10r1

##### index

```
import { useConstructor } from '@nash-protocol/starter-kit#atom-v0.1.10r1:util.rsh'
import { Participants as AppParticipants,Views, Api, App } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(AppParticipants, Views, Api)));
```

##### .env

```
export REACH_VERSION=27cb9643 # v0.1.11-rc.7
API_ENDPOINT_TESTNET="https://launcher.testnet.zestbloom.com"
TEMPLATE_NAME="atom"
ZB_AUTH_TOKEN=
```

### hydrogen

Template with 1 asset pre-optin

### helium

Template with 2 asset pre-optin

### lithium

Template with 3 asset pre-optin

### carbon

Template with 6 asset pre-optin

## terms

- NP - Nash Protocol
- RAap - Reach App
- NPR - NP Reach App
- Activation - Hand off between constructor and contractee require fee to pay for deployment and storage cost incurred by constructor

## dependencies

- Reach development environment (reach compiler)
- sed - stream editor
- grep - pattern matching
- curl - request remote resource


