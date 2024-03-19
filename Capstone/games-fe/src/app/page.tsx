"use client";

import GamesList from "@/components/GamesList";
import { useCurrentAccount } from "@mysten/dapp-kit";
import { SUI_DEVNET_CHAIN } from "@mysten/wallet-standard";

export default function Home() {
  const currentAccount = useCurrentAccount();

  return (
    <main>
      {!currentAccount && (
        <>
          <p>Connect your wallet</p>
        </>
      )}
      {currentAccount && currentAccount.chains[0] !== SUI_DEVNET_CHAIN && (
        <>
          <p>Please connect to Sui Devnet</p>
        </>
      )}
      {currentAccount && currentAccount.chains[0] === SUI_DEVNET_CHAIN && (
        <>
          <p>Welcome to Sui Games</p>
          <GamesList />
        </>
      )}
    </main>
  );
}
