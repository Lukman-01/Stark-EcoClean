import React from 'react';
import { useConnect, useDisconnect, useAccount } from '@starknet-react/core';
import { WalletIcon, LogOutIcon } from 'lucide-react';

const WalletBar = () => {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address } = useAccount();

  return (
    <div className="fixed top-4 right-4 z-50">
      {!address ? (
        <div className="relative group">
          <button
            className="flex items-center gap-2 bg-white shadow-lg rounded-lg px-4 py-2 hover:bg-gray-50 transition-all duration-200"
          >
            <WalletIcon size={18} />
            <span className="font-medium">Connect Wallet</span>
          </button>
          
          <div className="absolute right-0 mt-2 invisible group-hover:visible opacity-0 group-hover:opacity-100 transition-all duration-200">
            <div className="bg-white rounded-lg shadow-xl p-2 min-w-[200px]">
              {connectors.map((connector) => (
                <button
                  key={connector.id}
                  onClick={() => connect({ connector })}
                  className="w-full flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-md transition-colors duration-200"
                >
                  <WalletIcon size={16} />
                  <span>{connector.id}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      ) : (
        <div className="flex items-center gap-2 bg-white shadow-lg rounded-lg p-2">
          <div className="px-3 py-1 bg-gray-50 rounded-md text-sm font-medium">
            {address.slice(0, 6)}...{address.slice(-4)}
          </div>
          <button
            onClick={() => disconnect()}
            className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-md transition-colors duration-200"
            title="Disconnect"
          >
            <LogOutIcon size={18} />
          </button>
        </div>
      )}
    </div>
  );
};

export default WalletBar;