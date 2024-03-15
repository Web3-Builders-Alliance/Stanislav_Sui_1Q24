"use client";

import { ConnectButton } from "@mysten/dapp-kit";
import logo from "./logo.svg";
import Image from "next/image";
import CreateAccountButton from "./CreateAccountButton";
import Link from "next/link";

export default function TopNav() {
  return (
    <nav>
      <Link href="/">
        <Image src={logo} alt="logo" width={100} />
      </Link>
      <div className="flex">
        <ConnectButton />
        <CreateAccountButton />
      </div>
    </nav>
  );
}
