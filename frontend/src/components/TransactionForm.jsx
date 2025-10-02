import React, { useState } from 'react';
import { useAccount, useContractWrite, useContractRead, useWaitForTransactionReceipt, useChainId } from 'wagmi';
import { contracts } from '../config.js';

function TransactionForm({ onTransactionComplete }) {
  const [depositAmount, setDepositAmount] = useState('');
  const [withdrawAmount, setWithdrawAmount] = useState('');
  const { address } = useAccount();
  const chainId = useChainId();
  
  // 获取ERC20代币的symbol
  const { data: tokenSymbol } = useContractRead({
    address: contracts.myErc20.address,
    abi: contracts.myErc20.abi,
    functionName: 'symbol',
  });

  // 授权TokenBank使用用户的METK代币
  const { writeContract: approve, isPending: isApproveLoading } = useContractWrite({
    address: contracts.myErc20.address,
    abi: contracts.myErc20.abi,
    functionName: 'approve',
  });

  // 存款到TokenBank
  const { writeContract: deposit, isPending: isDepositLoading, data: depositHash } = useContractWrite({
    address: contracts.tokenBank.address,
    abi: contracts.tokenBank.abi,
    functionName: 'deposit',
  });

  // 等待存款交易确认
  const { isLoading: isDepositConfirming } = useWaitForTransactionReceipt({
    hash: depositHash,
  });

  // 取款从TokenBank
  const { writeContract: withdraw, isPending: isWithdrawLoading, data: withdrawHash } = useContractWrite({
    address: contracts.tokenBank.address,
    abi: contracts.tokenBank.abi,
    functionName: 'withdraw',
  });

  // 等待取款交易确认
  const { isLoading: isWithdrawConfirming } = useWaitForTransactionReceipt({
    hash: withdrawHash,
  });

  // 处理授权
  const handleApprove = () => {
    if (depositAmount && depositAmount > 0) {
      const approveAmount = BigInt(Number(depositAmount) * 1e18);
      approve({
        address: contracts.myErc20.address,
        abi: contracts.myErc20.abi,
        functionName: 'approve',
        args: [contracts.tokenBank.address, approveAmount],
      });
    }
  };

  // 处理存款
  const handleDeposit = (e) => {
    e.preventDefault();
    if (depositAmount && depositAmount > 0) {
      deposit({
        address: contracts.tokenBank.address,
        abi: contracts.tokenBank.abi,
        functionName: 'deposit',
        args: [BigInt(Number(depositAmount) * 1e18)],
      });
      setDepositAmount('');
    }
  };

  // 处理取款
  const handleWithdraw = (e) => {
    e.preventDefault();
    if (withdrawAmount && withdrawAmount > 0) {
      withdraw({
        address: contracts.tokenBank.address,
        abi: contracts.tokenBank.abi,
        functionName: 'withdraw',
        args: [BigInt(Number(withdrawAmount) * 1e18)],
      });
      setWithdrawAmount('');
    }
  };

  // 监听交易完成
  React.useEffect(() => {
    if (isDepositConfirming === false && depositHash) {
      onTransactionComplete();
    }
  }, [isDepositConfirming, depositHash, onTransactionComplete]);

  React.useEffect(() => {
    if (isWithdrawConfirming === false && withdrawHash) {
      onTransactionComplete();
    }
  }, [isWithdrawConfirming, withdrawHash, onTransactionComplete]);

  const inputStyle = {
    width: '100%',
    padding: '8px',
    margin: '6px 0',
    border: '1px solid #ddd',
    borderRadius: '4px'
  };

  const buttonStyle = {
    padding: '8px 16px',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    marginTop: '8px',
    marginRight: '8px'
  };

  const approveButtonStyle = {
    ...buttonStyle,
    backgroundColor: '#ffc107',
    color: '#000'
  };

  const depositButtonStyle = {
    ...buttonStyle,
    backgroundColor: '#28a745'
  };

  const withdrawButtonStyle = {
    ...buttonStyle,
    backgroundColor: '#dc3545'
  };

  // 检查网络是否正确
  const isCorrectNetwork = chainId === 11155111; // Sepolia

  return (
    <div>
      <h3>存款与取款</h3>
      
      {/* 存款部分 */}
      <div style={{ marginBottom: '15px' }}>
        <h4 style={{ margin: '0 0 8px 0', fontSize: '14px', color: '#333' }}>存款</h4>
        <form onSubmit={handleDeposit}>
          <input 
            type="number" 
            value={depositAmount}
            onChange={(e) => setDepositAmount(e.target.value)}
            placeholder={`输入存款金额(${tokenSymbol || 'TOKEN'})`} 
            step="0.01" 
            min="0"
            style={inputStyle}
          />
          <div style={{marginTop: '8px'}}>
            <button 
              type="button" 
              style={approveButtonStyle}
              onClick={handleApprove}
              disabled={!isCorrectNetwork || isApproveLoading || !depositAmount || depositAmount <= 0}
            >
              {isApproveLoading ? '授权中...' : '授权'}
            </button>
            <button 
              type="submit" 
              style={depositButtonStyle}
              disabled={!isCorrectNetwork || isDepositLoading || isDepositConfirming || !depositAmount || depositAmount <= 0}
            >
              {isDepositLoading ? '存款中...' : isDepositConfirming ? '确认中...' : '存款'}
            </button>
          </div>
        </form>
      </div>

      {/* 取款部分 */}
      <div>
        <h4 style={{ margin: '0 0 8px 0', fontSize: '14px', color: '#333' }}>取款</h4>
        <form onSubmit={handleWithdraw}>
          <input 
            type="number" 
            value={withdrawAmount}
            onChange={(e) => setWithdrawAmount(e.target.value)}
            placeholder={`输入取款金额(${tokenSymbol || 'TOKEN'})`} 
            step="0.01" 
            min="0"
            style={inputStyle}
          />
          <button 
            type="submit" 
            style={withdrawButtonStyle}
            disabled={!isCorrectNetwork || isWithdrawLoading || isWithdrawConfirming || !withdrawAmount || withdrawAmount <= 0}
          >
            {isWithdrawLoading ? '取款中...' : isWithdrawConfirming ? '确认中...' : '取款'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default TransactionForm;
