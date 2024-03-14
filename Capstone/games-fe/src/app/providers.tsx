"use client";
import { SuiClientProvider, WalletProvider } from "@mysten/dapp-kit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { networkConfig } from "@/utils/networkConfig";
import { NextUIProvider } from "@nextui-org/react";
import { AccountProvider } from "@/context/account-context";

const queryClient = new QueryClient();

export interface ProvidersProps {
  children: React.ReactNode;
}

export function Providers({ children }: ProvidersProps) {
  return (
    <NextUIProvider>
      <QueryClientProvider client={queryClient}>
        <SuiClientProvider networks={networkConfig} defaultNetwork="devnet">
          <WalletProvider autoConnect>
            <AccountProvider>{children}</AccountProvider>
          </WalletProvider>
        </SuiClientProvider>
      </QueryClientProvider>
    </NextUIProvider>
  );
}
