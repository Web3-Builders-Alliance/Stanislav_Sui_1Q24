import { useNetworkVariable } from "@/utils/networkConfig";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { SUI_TESTNET_CHAIN } from "@mysten/wallet-standard";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import {
  MIST_PER_SUI,
  SUI_CLOCK_OBJECT_ID,
  normalizeSuiAddress,
} from "@mysten/sui.js/utils";

import {
  Button,
  Input,
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  Radio,
  RadioGroup,
  useDisclosure,
} from "@nextui-org/react";
import { useContext, useState } from "react";
import { AccountContext } from "@/context/account-context";

export default function CreateGameButton({
  classname,
  onCreate,
}: {
  classname?: string;
  onCreate?: () => void;
}) {
  const currentAccount = useCurrentAccount();
  const hexPackageId = useNetworkVariable("hexgamePackageId");
  const tictactoePackageId = useNetworkVariable("tictactoePackageId");
  const gamesPackId = useNetworkVariable("gamespackId");
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const client = useSuiClient();

  const { isOpen, onOpen, onClose, onOpenChange } = useDisclosure();
  const [bet, setBet] = useState("0");
  const [gameType, setGameType] = useState("hex");

  const { accountId } = useContext(AccountContext);

  const [isCreating, setIsCreating] = useState(false);

  const createGame = async () => {
    if (!currentAccount) {
      return;
    }

    let packageId;
    if (gameType === "hex") {
      packageId = hexPackageId;
    } else if (gameType === "tictactoe") {
      packageId = tictactoePackageId;
    } else {
      return;
    }

    const betNum = parseFloat(bet);
    if (Number.isNaN(betNum) || betNum < 0) {
      return;
    }

    setIsCreating(true);

    const txb = new TransactionBlock();

    let [coin] = txb.splitCoins(txb.gas, [betNum * Number(MIST_PER_SUI)]);

    txb.moveCall({
      arguments: [
        txb.object(gamesPackId),
        txb.object(accountId),
        txb.pure(normalizeSuiAddress("0")),
        coin,
        txb.object(SUI_CLOCK_OBJECT_ID),
      ],
      target: `${packageId}::main::create_game`,
    });

    signAndExecute(
      {
        transactionBlock: txb,
        options: {
          showEffects: true,
          showObjectChanges: true,
        },
      },
      {
        onSuccess: (tx) => {
          client
            .waitForTransactionBlock({ digest: tx.digest })
            .then(() => {
              if (onCreate) onCreate();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {
              setIsCreating(false);
              onClose();
            });
        },
        onError: (error) => {
          console.log(error);

          setIsCreating(false);
        },
      }
    );
  };

  if (!currentAccount || currentAccount.chains[0] !== SUI_TESTNET_CHAIN) return;

  if (!accountId)
    return (
      <>
        <p>Please create account</p>
      </>
    );

  return (
    <>
      <Button onPress={onOpen} color="primary" className={classname}>
        Create Game
      </Button>
      <Modal isOpen={isOpen} onOpenChange={onOpenChange} placement="top">
        <ModalContent>
          <ModalHeader>Create Game</ModalHeader>
          <ModalBody>
            <RadioGroup
              label="Select game type"
              value={gameType}
              onValueChange={setGameType}
            >
              <Radio value="hex">Hex Board Game</Radio>
              <Radio value="tictactoe">Tic-Tac-Toe 5 In Row</Radio>
              <Radio value="" isDisabled>
                Another game
              </Radio>
            </RadioGroup>
            <Input
              autoFocus
              type="number"
              label="Bet"
              placeholder="0"
              variant="bordered"
              value={bet}
              endContent="Sui"
              onValueChange={setBet}
            />
          </ModalBody>
          <ModalFooter>
            <Button color="danger" onPress={onClose}>
              Cancel
            </Button>
            <Button color="primary" isLoading={isCreating} onPress={createGame}>
              Create
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}
