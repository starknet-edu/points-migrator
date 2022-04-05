import { starknet } from "hardhat";
import {
  StarknetContract,
  StarknetContractFactory,
  Account,
} from "hardhat/types/runtime";

const TUTOKEN1_CAIRO =
  "0x074002c7df47096f490a1a89b086b8a468f2e7c686e04a024d93b7c59f934f83";
const TUTOKEN2_ERC20 =
  "0x037b0ca3995eb2d79626b6a0eac40fe4ba19ddf73d81423626b44755614b9cee";
const TUTOKEN3_ERC721 =
  "0x0272abeb08a98ce2024b96dc522fdcf71e91bd333b228ad62ca664920881bc52";
const TUTOKEN4_MSG =
  "0x01c1a868018f540bc456d2ba4859d20b06a8542fa447cd499f7372d9fd1c1bf9";

const PLAYER_REGISTRY1_CAIRO =
  "0x3991cf84dea67dda6456876c710f8afd021df235100324618df8ba0fcceb66e";
const PLAYER_REGISTRY2_ERC20 =
  "0x5af2ba86ed7df13ee2b7557a7e6db163e04c5238980c6e9fdeb4bcc040a48bb";
const PLAYER_REGISTRY3_ERC721 =
  "0x3991cf84dea67dda6456876c710f8afd021df235100324618df8ba0fcceb66e";
const PLAYER_REGISTRY4_MSG =
  "0x4f857652d367b49d2a7de4c8486743f84d53544bc258bfa4de649a24d88b942";

const EXERCISES1_CAIRO = [13, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
const EXERCISES2_ERC20 = [
  0, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1,
];
const EXERCISES3_ERC721 = [2, 0, 7, 6, 52, 51, 4, 3, 1];
const EXERCISES4_MSG = [4, 3, 2, 1, 0];
const tutokenAddresses = [
  TUTOKEN4_MSG,
  TUTOKEN3_ERC721,
  TUTOKEN2_ERC20,
  TUTOKEN1_CAIRO,
];

const playerResgistryAddresses = [
  PLAYER_REGISTRY4_MSG,
  PLAYER_REGISTRY3_ERC721,
  PLAYER_REGISTRY2_ERC20,
  PLAYER_REGISTRY1_CAIRO,
];
const main = async () => {
  let migratorFactory: StarknetContractFactory =
    await starknet.getContractFactory("Migrator");
  let migrator: StarknetContract = await migratorFactory.deploy({
    _players_registry_add: playerResgistryAddresses,
    tutoken_add: tutokenAddresses,
  });

  console.log("Migrator deployed at : ", migrator.address);

  await migrator.invoke("fill_exercise_list", {
    exercise_list: EXERCISES1_CAIRO,
    tuto_nb: 1,
  });
  console.log("exercises set for tuto ", 1);

  await migrator.invoke("fill_exercise_list", {
    exercise_list: EXERCISES2_ERC20,
    tuto_nb: 2,
  });
  console.log("exercises set for tuto ", 2);

  await migrator.invoke("fill_exercise_list", {
    exercise_list: EXERCISES3_ERC721,
    tuto_nb: 3,
  });
  console.log("exercises set for tuto ", 3);

  await migrator.invoke("fill_exercise_list", {
    exercise_list: EXERCISES4_MSG,
    tuto_nb: 4,
  });
  console.log("exercises set for tuto ", 4);

  await migrator.invoke("disable_set_exercise");
  console.log("finished deployment");
};

main();
