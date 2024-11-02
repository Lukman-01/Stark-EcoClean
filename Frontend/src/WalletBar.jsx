import React from 'react';
import { useConnect, useDisconnect, useAccount } from '@starknet-react/core';
import { WalletIcon, LogOutIcon, Copy, Check } from 'lucide-react';
import { useState } from 'react';

const WalletBar = () => {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address } = useAccount();
  const [copied, setCopied] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState({ title: '', description: '' });

  const showNotification = (title, description) => {
    setToastMessage({ title, description });
    setShowToast(true);
    setTimeout(() => setShowToast(false), 3000);
  };

  const copyToClipboard = async () => {
    if (!address) return;
    try {
      await navigator.clipboard.writeText(address);
      setCopied(true);
      showNotification("Address copied!", "Wallet address has been copied to clipboard");
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      showNotification("Failed to copy", "Please try again");
    }
  };

  const handleDisconnect = () => {
    disconnect();
    showNotification("Wallet disconnected", "You've been successfully disconnected from your wallet");
  };

  const truncateAddress = (addr) => {
    if (!addr) return "";
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  };

  return (
    <>
      <div className="fixed top-4 right-4 z-50">
        {!address ? (
          <div className="relative">
            <button
              className="flex items-center gap-2 bg-white hover:bg-gray-50 text-gray-800 font-medium py-2 px-4 rounded-lg shadow-lg transition-colors duration-200"
              onClick={() => setShowDropdown(!showDropdown)}
            >
              <WalletIcon size={18} />
              <span>Connect Wallet</span>
            </button>
            
            {showDropdown && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl p-1">
                {connectors.map((connector) => (
                  <button
                    key={connector.id}
                    onClick={() => {
                      connect({ connector });
                      setShowDropdown(false);
                      showNotification("Connecting wallet", `Connecting to ${connector.id}...`);
                    }}
                    className="w-full flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-md transition-colors duration-200"
                  >
                    <WalletIcon size={16} />
                    <span className="capitalize">{connector.id}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div className="flex items-center gap-2 bg-white shadow-lg rounded-lg p-2">
            <button
              onClick={copyToClipboard}
              className="flex items-center gap-2 px-3 py-1 hover:bg-gray-50 rounded-md transition-colors duration-200 font-mono"
              title="Click to copy address"
            >
              <span>{truncateAddress(address)}</span>
              {copied ? (
                <Check size={16} className="text-green-500" />
              ) : (
                <Copy size={16} className="text-gray-500" />
              )}
            </button>
            
            <button
              onClick={handleDisconnect}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-md transition-colors duration-200"
              title="Disconnect wallet"
            >
              <LogOutIcon size={18} />
            </button>
          </div>
        )}
      </div>

      {/* Simple Toast Notification */}
      {showToast && (
        <div className="fixed bottom-4 right-4 z-50 bg-white shadow-lg rounded-lg p-4 max-w-sm animate-slide-up">
          <h4 className="font-medium text-gray-800">{toastMessage.title}</h4>
          <p className="text-gray-600 text-sm mt-1">{toastMessage.description}</p>
        </div>
      )}
    </>
  );
};

export default WalletBar;