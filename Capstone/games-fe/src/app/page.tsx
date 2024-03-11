"use client";

import { useCurrentAccount } from "@mysten/dapp-kit";
import { SUI_DEVNET_CHAIN } from "@mysten/wallet-standard";

export default function Home() {
  const currentAccount = useCurrentAccount();

  return (
    <main>
      {!currentAccount && (
        <div>
          <p>Connect your wallet</p>
        </div>
      )}
      {currentAccount && currentAccount.chains[0] !== SUI_DEVNET_CHAIN && (
        <div>
          <p>Please connect to Sui Devnet</p>
        </div>
      )}
      {currentAccount && currentAccount.chains[0] === SUI_DEVNET_CHAIN && (
        <div>
          <p>Welcome to Sui Games</p>
        </div>
      )}
    </main>
  );
}
