# Points migrator

Welcome to the point migrators repo! The blockchain ecosystem is merciless never trust anyone always read the [code](contracts/Migrator.cairo)

## Context

On 11/03/2022 Argent X released a new version which contained breaking changes so it's now impossible to use the old Argent X account with Argent x V3. Since the transfer function is disabled we had to think of a mechanism to enable people to migrate their points from their old wallet to a new one without being able to farm points (for example completing only the first exercise on 10 accounts and have 20 points on 1 account in the end). We then wrote the [Migrator smart-contract](contracts/Migrator.cairo).
Now people that want to migrate their points just have to interact with this smart-contract using their old wallet. It's possible to use the older version of Argent X following [these](https://github.com/argentlabs/argent-x/blob/develop/docs/Upgrade_v3.md#what-does-it-mean-as-an-argent-x-user) steps. Unfortunately starknet.js also had a breaking update which means that it's now impossible to use the old Argent X extension within voyager. So we decided to host an older version of voyager which was compatible with the old version of Argent X.
Nethermind kindly provided us a docker image of an old version of voyager though some more problems appeared:

* The sync would take ~2 weeks
* after some time running the container has an error and gets stuck on it infinitely

We then decided to create a small js script to enable users using their old account so they would be able to migrate their points (and do anything else they'd like)

## Smart-contract

The smart-contract is pretty simple, a user will call the `migrate_points` entrypoint providing the index of the tutorial and the address he wants to migrate the points to. The smart-contract check various things:

* the old account allowance which should be equal to the number of tokens held by this account
* the new account balance which should be 0

Once these checks are done, the point migrator will transfer the progression of the old account to the new account so the user cannot do the tutorial twice and hold too much tokens. This process is done recursively [here](contracts/util.cairo).

## Starknet.js

We used [starknet.js v2.5.1](https://github.com/0xs34n/starknet.js/blob/e72b4488638ebd77c2de13d62bb112e3d4d16550). The best documentation is always an example so take a look at the [tests](https://github.com/0xs34n/starknet.js/blob/e72b4488638ebd77c2de13d62bb112e3d4d16550/__tests__) if you want to see all the functionnalities of this version

## Tests

All the tests are done using hardhat alongside with the starknet devnet

## Usage

To use this script you have to **READ THE CODE** and install the dependencies:

```bash
npm i
```

Then copy paste your Argent X `backup.json` file in the `scripts` directory, fill your Argent X password, select the tutorial you want to migrate the points of (or create a loop to migrate them all) and then run the script with:

```bash
node scripts/migrate.js
```
