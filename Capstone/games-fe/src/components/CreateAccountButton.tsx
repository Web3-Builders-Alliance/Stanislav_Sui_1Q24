import { useNetworkVariable } from "@/utils/networkConfig";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { SUI_DEVNET_CHAIN } from "@mysten/wallet-standard";
import { bcs } from "@mysten/sui.js/bcs";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";

import {
  Button,
  Modal,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalFooter,
  useDisclosure,
  Input,
} from "@nextui-org/react";
import { useContext, useState } from "react";
import UserAccount from "./UserAccount";
import { AccountContext } from "@/context/account-context";

export default function CreateAccountButton() {
  const currentAccount = useCurrentAccount();
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const client = useSuiClient();

  const { accountId, refetch } = useContext(AccountContext);

  const { isOpen, onOpen, onClose, onOpenChange } = useDisclosure();
  const [name, setName] = useState("");
  const [isCreating, setIsCreating] = useState(false);

  const createAccount = async () => {
    if (!currentAccount) {
      return;
    }

    setIsCreating(true);

    const txb = new TransactionBlock();
    const username = new Uint8Array(Buffer.from(name));
    let serialized_username = txb.pure(
      bcs.vector(bcs.u8()).serialize(username)
    );
    let [account] = txb.moveCall({
      arguments: [serialized_username, txb.object(SUI_CLOCK_OBJECT_ID)],
      target: `${suigamesPackageId}::account::create_account`,
    });

    txb.transferObjects([account], currentAccount.address);

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
              onClose();
              refetch();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {
              setIsCreating(false);
            });
        },
        onError: (error) => {
          console.log(error);

          setIsCreating(false);
        },
      }
    );
  };

  if (!currentAccount || currentAccount.chains[0] !== SUI_DEVNET_CHAIN) return;

  if (!accountId) {
    return (
      <>
        <Button
          onPress={onOpen}
          color="primary"
          className="ml-2 h-auto drop-shadow-lg"
        >
          Create Account
        </Button>
        <Modal isOpen={isOpen} onOpenChange={onOpenChange} placement="top">
          <ModalContent>
            <ModalHeader>Create Account</ModalHeader>
            <ModalBody>
              <Input
                autoFocus
                label="User name"
                placeholder="Enter your name"
                variant="bordered"
                onChange={(e) => {
                  setName(e.target.value);
                }}
              />
            </ModalBody>
            <ModalFooter>
              <Button color="danger" onPress={onClose}>
                Cancel
              </Button>
              <Button
                color="primary"
                isLoading={isCreating}
                onPress={createAccount}
              >
                Create
              </Button>
            </ModalFooter>
          </ModalContent>
        </Modal>
      </>
    );
  }

  return (
    <>
      <UserAccount id={accountId} className="ml-2" />
    </>
  );
}
