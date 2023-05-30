// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract RentContract{
    using Counters for Counters.Counter;
    Counters.Counter private _idxRents;

    address owner;
    address propertyContractAddress;

    struct Rent{ // TODO: Adicionar mais clausulas necessarias
        uint256 rentID; // Identificador do aluguel
        uint256 propertyID; // Identificador da propriedade
        address locator; // Locador
        address renter; // Locatario
        address witness1; // Testemunha 1
        address witness2; // Testemunha 2
        uint256 rentPricePerMonth; // Preco do aluguel por mes
        uint256 dayOfRentPayment; // Dia do mes de pagamento do aluguel
        uint256 termInMonth; // Prazo do aluguel em meses
        // Multas em termos de mes de aluguel
        uint256 fineForDesocupationBeforeTerm; // Multa por desocupacao antes do prazo
        uint256 fineForNonDesocupationAfterTerm; // Multa por nao desocupacao depois do prazo
        uint256 fineForRescission; // Multa por recisao
        uint256 fineForNonPaymentOfExpenses; // Multa por nao pagamento das despesas da propriedade
        uint256 fineForNotReturnedItems; // Multa por nao retorno dos itens do imovel
        // Multas em termos de percentuais
        uint256 fineForArrearsInPercent; // Percentual de multa por atraso
        uint256 feeForArrearsInPercent; // Percentual de juros de mora por atraso
        bool statusFinished; // Status indicando se o aluguel terminou (true) ou nao (false)
    }

    mapping(uint256 => Rent) private listOfRents;

    event SignedRent(uint256 indexed rentID);
    event IsRentFinished(bool status);

    constructor(address propertyContract){
        owner = msg.sender;
        propertyContractAddress = propertyContract;
    }

    function rentProperty(
        uint256 tokenID,
        address locator,
        address renter,
        address witness1,
        address witness2,
        uint256 rentPricePerMonth,
        uint256 dayOfRentPayment,
        uint256 termInMonth,
        uint256 fineForDesocupationBeforeTerm,
        uint256 fineForNonDesocupationAfterTerm,
        uint256 fineForRescission,
        uint256 fineForNonPaymentOfExpenses,
        uint256 fineForNotReturnedItems,
        uint256 fineForArrearsInPercent,
        uint256 feeForArrearsInPercent) external onlyOwner{

        require(rentPricePerMonth > 0, "Rent price must be at least 1 wei!");
        // TODO: Adicionar outras validacoes
        
        _idxRents.increment();
        uint256 newRentID = _idxRents.current();

        listOfRents[newRentID] = Rent(
            newRentID,
            tokenID,
            locator,
            renter,
            witness1,
            witness2,
            rentPricePerMonth,
            dayOfRentPayment,
            termInMonth,
            fineForDesocupationBeforeTerm,
            fineForNonDesocupationAfterTerm,
            fineForRescission,
            fineForNonPaymentOfExpenses,
            fineForNotReturnedItems,
            fineForArrearsInPercent,
            feeForArrearsInPercent,
            false
        );

        IERC721(propertyContractAddress).transferFrom(
            address(locator),
            address(renter),
            tokenID
        );

        emit SignedRent(newRentID);
    }

    function finishRent(uint256 rentID) external onlyOwner{
        require(rentID > 0, "Only a valid ID is accepted!");

        Rent storage rent = listOfRents[rentID];
        require(!rent.statusFinished, "This rent is already finished!");

        
        (bool success, ) = (propertyContractAddress).call(
            abi.encodeWithSignature(
                "transferPropertyOwnerShip(address,address,uint256)",
                rent.renter,
                rent.locator,
                rent.propertyID
            )
        );
        require(success, "The property cannot be transfered back to owner!");
        rent.statusFinished = true;

        emit IsRentFinished(success);
    }

    // Funcao para consultar os alugueis
    function getRents() public view returns (Item[] memory) {
        return listOfRents;
    }

    function getRent(uint256 rentID) public view returns (Item memory) {
        return listOfRents[rentID];
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this method!");
        _;
    }
}