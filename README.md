# starter-kit

The NP starter kit describes how to launch a NP RApp in minutes. Quickstart assumes that the local development environment for Reach has been setup.

## quickstart

commands
```bash
git clone git@github.com:nash-protocol/starter-kit.git 
cd starter-kit 
source np.sh 
np
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
export REACH_VERSION=0.1.12 # v0.1.12
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


