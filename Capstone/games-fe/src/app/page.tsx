"use client";

import GamesList from "@/components/GamesList";
import { useCurrentAccount } from "@mysten/dapp-kit";
import { SUI_TESTNET_CHAIN } from "@mysten/wallet-standard";

export default function Home() {
  const currentAccount = useCurrentAccount();

  return (
    <main>
      {!currentAccount && (
        <>
          <p>Connect your wallet</p>
        </>
      )}
      {currentAccount && currentAccount.chains[0] !== SUI_TESTNET_CHAIN && (
        <>
          <p>Please connect to Sui Testnet</p>
        </>
      )}
      {currentAccount && currentAccount.chains[0] === SUI_TESTNET_CHAIN && (
        <>
          <p>Welcome to Sui Games</p>
          <GamesList />
        </>
      )}
    </main>
  );
}
