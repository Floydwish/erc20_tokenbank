import React, { useState } from 'react';
import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { config } from './config.js';
import WalletInfo from './components/WalletInfo.jsx';
import TransactionForm from './components/TransactionForm.jsx';

const queryClient = new QueryClient();

function App() {
  const [refreshKey, setRefreshKey] = useState(0);

  const containerStyle = {
    maxWidth: '600px',
    margin: '10px auto',
    padding: '15px',
    fontFamily: 'Arial, sans-serif'
  };

  const cardStyle = {
    border: '1px solid #ddd',
    borderRadius: '6px',
    padding: '12px',
    margin: '8px 0',
    backgroundColor: '#f9f9f9'
  };

  const handleTransactionComplete = () => {
    setRefreshKey(prev => prev + 1);
  };

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <div style={containerStyle}>
          <h1>🏦 Marvin's TokenBank</h1>
          <div style={cardStyle}>
            <WalletInfo refreshKey={refreshKey} />
          </div>
          <div style={cardStyle}>
            <TransactionForm onTransactionComplete={handleTransactionComplete} />
          </div>
        </div>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
