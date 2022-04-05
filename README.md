# Points migrator

Welcome to the point migrators repo! 

## Context

On 11/03/2022 Argent X released a new version which contained [breaking changes](https://github.com/argentlabs/argent-x/blob/develop/docs/Upgrade_v3.md). It is now impossible to use your Argent X V2 account with Argent x V3. 

Argent provided a simple tool to migrate ERC20 tokens. However, the transfer function of our tutorials is disabled. So we had to think of a mechanism to enable people to migrate their points from their old wallet to a new one. 
And all that, without being able to farm points (for example completing only the first exercise on 10 accounts and have 20 points on 1 account in the end). 

To fit that purpos, we wrote the [Migrator smart-contract](contracts/Migrator.cairo).

Now people that want to migrate their points just have to interact with this smart-contract using their old wallet. Nice It's possible to use the older version of Argent X following [these](https://github.com/argentlabs/argent-x/blob/develop/docs/Upgrade_v3.md#what-does-it-mean-as-an-argent-x-user) steps. 

...Unfortunately starknet.js also had a breaking update which makes it impossible to use the Argent X V2 extension within voyager. 

Ok, no problem! We decided to host an older version of Voyager which was compatible with Argent X V2.
Nethermind kindly provided us a [docker image ](https://github.com/demerzelsolutions/voyager/pkgs/container/voyager) of an old version of voyager. But some more problems appeared:

* The sync would take ~2 weeks
* After some time running the container, an error appeared and the container goit stuck on it infinitely

We then decided to create a [small js script](https://github.com/starknet-edu/points-migrator/blob/main/scripts/migrate.js#L34-L50) to enable users using their old account so they would be able to migrate their points (and do anything else they'd like). That solved our problem!

## Smart-contract

The smart-contract is pretty simple, a user will call the `migrate_points` entrypoint providing the index of the tutorial and the address he wants to migrate the points to. The smart-contract check variouss things:

* the old account allowance which should be equal to the number of tokens held by this account
* the new account balance which should be 0

Once these checks are done, the point migrator will transfer the progression of the old account to the new account so the user cannot do the tutorial twice and hold too much tokens. This process is done recursively [here](contracts/util.cairo).

## Starknet.js

We used [starknet.js v2.5.1](https://github.com/0xs34n/starknet.js/blob/e72b4488638ebd77c2de13d62bb112e3d4d16550). The best documentation is always an example so take a look at the [tests](https://github.com/0xs34n/starknet.js/blob/e72b4488638ebd77c2de13d62bb112e3d4d16550/__tests__) if you want to see all the functionnalities of this version

## Tests

All the tests are done using hardhat alongside with the starknet devnet

## Usage

The blockchain ecosystem is merciless... never trust anyone always **READ THE [CODE]**(contracts/Migrator.cairo).

Seriously, don't run this code before reading it.

To use this script you have to install the dependencies:

```bash
npm i
```

Then copy paste your Argent X `backup.json` file in the `scripts` directory, fill your Argent X password, select the tutorial you want to migrate the points of (or create a loop to migrate them all) and then run the script with:

```bash
node scripts/migrate.js
```
