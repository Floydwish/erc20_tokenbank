import { createConfig, http } from 'wagmi';
import { mainnet, sepolia } from 'wagmi/chains';
import { injected, metaMask } from 'wagmi/connectors';

// 自定义localhost链定义
const localhost = {
  id: 31337,
  name: 'Localhost',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: ['http://127.0.0.1:8545'] },
  },
  testnet: true,
};

// 导入合约ABI
import TokenBankABI from '/public/contracts/TokenBank.json';
import MyErc20ABI from '/public/contracts/MyErc20.json';

// 合约地址（从环境变量读取，如果不存在则使用默认值）
const TOKEN_BANK_ADDRESS = import.meta.env.VITE_TOKEN_BANK_ADDRESS || '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
const MY_ERC20_ADDRESS = import.meta.env.VITE_MY_ERC20_ADDRESS || '0x5FbDB2315678afecb367f032d93F642f64180aa3';

// Wagmi配置
export const config = createConfig({
  chains: [localhost, mainnet, sepolia],
  connectors: [injected(), metaMask()],
  transports: {
    [localhost.id]: http('http://127.0.0.1:8545'),
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
  ssr: false, // 禁用SSR以避免链ID检测问题
});

// 合约配置
export const contracts = {
  tokenBank: {
    address: TOKEN_BANK_ADDRESS,
    abi: TokenBankABI.abi,
  },
  myErc20: {
    address: MY_ERC20_ADDRESS,
    abi: MyErc20ABI.abi,
  },
};

// 链配置
export const chainConfig = {
  localhost: {
    id: 31337,
    name: 'Localhost',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: {
      default: { http: ['http://127.0.0.1:8545'] },
    },
  },
};