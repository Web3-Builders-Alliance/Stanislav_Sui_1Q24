"use client";

import { ConnectButton } from "@mysten/dapp-kit";
import logo from "./logo.svg";
import Image from "next/image";
import CreateAccountButton from "./CreateAccountButton";

export default function TopNav() {
  return (
    <nav>
      <Image src={logo} alt="logo" width={100} />
      <div className="flex">
        <ConnectButton />
        <CreateAccountButton />
      </div>
    </nav>
  );
}
