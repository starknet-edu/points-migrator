const ethers = require("ethers");
const fs = require("fs");
const starknet = require("starknet");

const MIGRATOR_ADDRESS =
  "0x0135ad3e5755dfa3321a7ef58231577d0d932322acd4d2e39714b6fe83a54d30";

const params = {
  cairo101: {
    tutoIndex: 1,
    tutokenAddress:
      "0x074002c7df47096f490a1a89b086b8a468f2e7c686e04a024d93b7c59f934f83",
  },
  erc20: {
    tutoIndex: 2,
    tutokenAddress:
      "0x037b0ca3995eb2d79626b6a0eac40fe4ba19ddf73d81423626b44755614b9cee",
  },
  erc721: {
    tutoIndex: 3,
    tutokenAddress:
      "0x0272abeb08a98ce2024b96dc522fdcf71e91bd333b228ad62ca664920881bc52",
  },
  L1L2Msg: {
    tutoIndex: 4,
    tutokenAddress:
      "0x01c1a868018f540bc456d2ba4859d20b06a8542fa447cd499f7372d9fd1c1bf9",
  },
};

async function migratePoints(password, tutoParams) {
  // read your argent backup file
  const backup = fs.readFileSync("scripts/mockBackup.json", "utf-8");

  // decode the backup file
  const wallet = await ethers.Wallet.fromEncryptedJson(backup, password);

  // generate stark keypair from the ethereum private key
  const keyPair = starknet.ec.getKeyPair(wallet.privateKey);

  // replace directly by the address or replace wallet[0] by the index of the address you'd like to use
  const accountAddress = JSON.parse(backup).wallets[0].address;

  // create a new signer that points to the specified account address
  const signer = new starknet.Signer(
    starknet.defaultProvider,
    accountAddress,
    keyPair
  );

  // approve the migrator contract
  const tx1 = await signer.addTransaction({
    type: "INVOKE_FUNCTION",
    contract_address: tutoParams.tutokenAddress,
    entry_point_selector: starknet.stark.getSelectorFromName("approve"),
    calldata: [MIGRATOR_ADDRESS, "1000000000000000000000", 0],
  });
  console.log(tx1);
  await starknet.defaultProvider.waitForTx(tx1.transaction_hash);

  // safely migrates points
  const tx2 = await signer.addTransaction({
    type: "INVOKE_FUNCTION",
    contract_address: MIGRATOR_ADDRESS,
    entry_point_selector: starknet.stark.getSelectorFromName(
      "safely_migrate_points"
    ),
    calldata: [tutoParams.tutoIndex, SENDER_POINTS_TO],
  });
  console.log(tx2);
  await starknet.defaultProvider.waitForTx(tx2.transaction_hash);
}
// replace with the address you want to migrate your points
const SENDER_POINTS_TO = "";

// replace with your argent x password so the backup file can be decoded
const password = "";

// replace with the tuto you want to migrate points
migratePoints(password, params.cairo101);
