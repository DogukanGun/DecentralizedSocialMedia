package main

import (
	"context"
	"crypto/ecdsa"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"io/ioutil"
	"log"
	"math/big"
	"strings"
)

type NetworkListener struct {
	url                   string
	contractAddress       string
	crossChainUrl         string
	crossChainMessagePool string
}

func (c *NetworkListener) listenNetwork() {
	client, err := ethclient.Dial(c.url)
	if err != nil {
		log.Fatal(err)
	}

	contractAddress := common.HexToAddress(c.contractAddress)
	query := ethereum.FilterQuery{
		Addresses: []common.Address{contractAddress},
	}

	logs := make(chan types.Log)
	sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatal(err)
	}
	for {
		select {
		case err := <-sub.Err():
			log.Fatal(err)
		case vLog := <-logs:
			if vLog.Topics[0] == common.HexToHash("0x2d4b597935f3cd67fb2eebf1db4debc934cee5c7baa7153f980fdbeb2e74084e") {
				fmt.Println("Topic", vLog.Topics)
				fmt.Println("Data", vLog.Data)
				fmt.Println("Adresss", vLog.Address)
				abiFile, err := ioutil.ReadFile("MessageBridge.abi")
				contractAbi, err := abi.JSON(strings.NewReader(string(abiFile)))
				if err != nil {
					// Handle error
					fmt.Println(err)
				}
				event := struct {
					Sender  common.Address
					Message string
					ChainID *big.Int
				}{}
				err = contractAbi.UnpackIntoInterface(&event, "Deposit", vLog.Data)
				if err != nil {
					log.Fatal(err)
				}
				// 0=>Wallet Address 1=>Amount 2=>ChainId
				fmt.Println("Event", event)
				c.sendRequestToMessageProtocol(event.Sender, event.Message, event.ChainID)
			}
		}
	}
}

func (c *NetworkListener) sendRequestToMessageProtocol(walletAddress common.Address, message string, chainID *big.Int) {
	err, contractInstance, _, res := CreateFunctionRequirementsForMessagePool(c.crossChainUrl, c.crossChainMessagePool, "e2bd7c71439d0f43c1b305459cf64176825e8287a4a96f83d2a4ed993d4c34d5")
	if err != nil {
		// Handle error
		fmt.Println(err)
	}
	fmt.Println("Gas Price", res.GasPrice)
	result, err2 := contractInstance.SendMessage(res, walletAddress, message, chainID)
	if err2 != nil {
		// Handle error
		fmt.Println("err", err2)
	}

	fmt.Println("result", result)
}

func CreateFunctionRequirementsForMessagePool(clientUrl string, lendingPoolAddress string, privateKey string) (error, *Main, common.Address, *bind.TransactOpts) {
	err, client, _publicAddress, res := CreateFunctionRequirementsForControllers(
		clientUrl,
		"MessageRouter.abi",
		lendingPoolAddress,
		privateKey)

	address := common.HexToAddress(lendingPoolAddress)
	contractInstance, err := NewMain(address, client)
	return err, contractInstance, _publicAddress, res
}

func CreateFunctionRequirementsForControllers(clientUrl string, walletAbiName string, oracleAddress string, privateKey string) (error, *ethclient.Client, common.Address, *bind.TransactOpts) {
	client, err := ethclient.Dial(clientUrl)
	if err != nil {
		// Handle error
	}

	address := common.HexToAddress(oracleAddress)
	abiFile, err := ioutil.ReadFile(walletAbiName)
	_, err = abi.JSON(strings.NewReader(string(abiFile)))
	if err != nil {
		// Handle error
		fmt.Println(err)
	}

	fmt.Println(address)
	//fmt.Println(client)
	//fmt.Println(contractAbi)

	if err != nil {
		// Handle error
	}

	_privateKey, _, _publicAddress, _ := GenerateKeypairFromPrivateKeyHex(privateKey)
	res, _ := BuildTransactionOptions(client, _publicAddress, _privateKey, 300000)
	return err, client, _publicAddress, res
}

func BuildTransactionOptions(client *ethclient.Client, fromAddress common.Address, prvKey *ecdsa.PrivateKey, gasLimit uint64) (*bind.TransactOpts, error) {

	// Retrieve the chainID
	chainID, cIDErr := client.ChainID(context.Background())

	if cIDErr != nil {
		return nil, cIDErr
	}

	// Retrieve suggested gas price
	gasPrice, gErr := client.SuggestGasPrice(context.Background())

	if gErr != nil {
		return nil, gErr
	}

	// Create empty options object
	txOptions, txOptErr := bind.NewKeyedTransactorWithChainID(prvKey, chainID)

	if txOptErr != nil {
		return nil, txOptErr
	}

	txOptions.Value = big.NewInt(0) // in wei
	txOptions.GasLimit = gasLimit   // in units
	txOptions.GasPrice = gasPrice

	return txOptions, nil
}

func GenerateKeypairFromPrivateKeyHex(privateKeyHex string) (*ecdsa.PrivateKey, *ecdsa.PublicKey, common.Address, error) {

	log.Println("Generating the keypair...")

	// If hex string has "0x" at the start discard it
	if privateKeyHex[:2] == "0x" {
		privateKeyHex = privateKeyHex[2:]
	}

	// Convert hex key to a private key object
	privateKey, privateKeyErr := crypto.HexToECDSA(privateKeyHex)

	if privateKeyErr != nil {
		return nil, nil, common.Address{}, privateKeyErr
	}

	// Generate the public key using the private key
	publicKey := privateKey.Public()

	// Cast crypto.Publickey object to the ecdsa.PublicKey object
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)

	if !ok {
		return nil, nil, common.Address{}, errors.New("error casting public key to ECDSA")
	}

	// Convert publickey to a address
	pubkeyAsAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

	return privateKey, publicKeyECDSA, pubkeyAsAddress, nil
}
