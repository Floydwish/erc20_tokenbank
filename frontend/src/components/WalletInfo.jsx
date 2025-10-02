import React from 'react';
import { useAccount, useBalance, useContractRead, useChainId, useDisconnect } from 'wagmi';
import { useConnect } from 'wagmi';
import { injected } from 'wagmi/connectors';
import { contracts } from '../config.js';

function WalletInfo({ refreshKey }) {
  const { address, isConnected, chainId } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { data: ethBalance } = useBalance({ address });

  // 获取ERC20代币的symbol
  const { data: tokenSymbol } = useContractRead({
    address: contracts.myErc20.address,
    abi: contracts.myErc20.abi,
    functionName: 'symbol',
  });

  // 获取用户钱包中的METK代币余额
  const { data: tokenBalance } = useContractRead({
    address: contracts.myErc20.address,
    abi: contracts.myErc20.abi,
    functionName: 'balanceOf',
    args: [address],
    enabled: !!address,
  });

  // 获取用户在TokenBank中的存款余额
  const { data: depositBalance } = useContractRead({
    address: contracts.tokenBank.address,
    abi: contracts.tokenBank.abi,
    functionName: 'getBalance',
    args: [address],
    enabled: !!address,
  });


  const walletInfoStyle = {
    padding: '8px',
    backgroundColor: '#e8f5e8',
    borderRadius: '4px'
  };

  const buttonStyle = {
    padding: '4px 8px',
    backgroundColor: '#007bff',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '11px',
    margin: '2px'
  };

  const warningStyle = {
    padding: '8px',
    backgroundColor: '#fff3cd',
    border: '1px solid #ffeaa7',
    borderRadius: '4px',
    color: '#856404',
    fontSize: '12px',
    margin: '8px 0'
  };

  const balanceItemStyle = {
    padding: '4px 0',
    borderBottom: '1px solid #eee'
  };

  if (!isConnected || !address) {
    return (
      <div style={walletInfoStyle}>
        <h3>连接钱包</h3>
        <button 
          style={buttonStyle}
          onClick={() => connect({ connector: injected() })}
        >
          连接钱包
        </button>
      </div>
    );
  }

  // 检查网络是否正确
  const isCorrectNetwork = chainId === 11155111; // Sepolia
  const networkName = chainId === 11155111 ? 'Sepolia' : chainId === 31337 ? 'Localhost' : `Chain ID ${chainId}`;

  return (
    <div style={walletInfoStyle}>
      <h3>钱包信息</h3>
      <div style={balanceItemStyle}>
        <span>地址: {address.slice(0, 6)}...{address.slice(-4)}</span>
      </div>
      <div style={balanceItemStyle}>
        <span>网络: {networkName}</span>
      </div>
      
      {/* 网络警告提示 */}
      {!isCorrectNetwork && (
        <div style={warningStyle}>
          ⚠️ 请切换到 Sepolia 网络 (Chain ID: 11155111) 以使用此应用
        </div>
      )}
      
      <h3 style={{marginTop: '15px', marginBottom: '8px'}}>余额信息</h3>
      <div style={balanceItemStyle}>
        <span>ETH 余额: {ethBalance ? (Number(ethBalance.value) / 1e18).toFixed(4) : '0'} ETH</span>
      </div>
      <div style={balanceItemStyle}>
        <span>钱包 {tokenSymbol || 'TOKEN'} 余额: {tokenBalance ? (Number(tokenBalance) / 1e18).toFixed(4) : '0'} {tokenSymbol || 'TOKEN'}</span>
      </div>
      <div style={balanceItemStyle}>
        <span>Marvin's TokenBank 存款: {depositBalance ? (Number(depositBalance) / 1e18).toFixed(4) : '0'} {tokenSymbol || 'TOKEN'}</span>
      </div>
      
      <div style={{ marginTop: '8px' }}>
        <button 
          style={{
            ...buttonStyle,
            backgroundColor: '#6c757d'
          }}
          onClick={() => disconnect()}
        >
          断开连接
        </button>
      </div>
    </div>
  );
}

export default WalletInfo;
