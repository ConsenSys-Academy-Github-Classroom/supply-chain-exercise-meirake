// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner = msg.sender;

  uint public skuCount;

  mapping (uint => Item) public items;

  enum State {ForSale, Sold, Shipped, Received}

  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
    }
  
  /* 
   * Events
   */

  event LogForSale(uint sku);

  event LogSold(uint sku);

  event LogShipped(uint sku);

  event LogReceived(uint sku);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    // uint _price = items[_sku].price;
    // uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
  }

  modifier forSale(uint _sku) {
    require(items[_sku].seller != address(0));
    require(items[_sku].state == State.ForSale);
    _;
  }
  modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold);
    _;
  }
  modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped);
    _;
  }
  // modifier received(uint _sku) 

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true

    // hint:
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0)
    });
    
    skuCount += 1;
    emit LogForSale(skuCount);
    return true;
  }

  // 5. this function should use 3 modifiers to check 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  function buyItem(uint sku) public payable 
  forSale(sku)
  paidEnough(items[sku].price)
  {
    items[sku].buyer = msg.sender;
    items[sku].seller.transfer(items[sku].price);
    items[sku].state = State.Sold;
    emit LogSold(sku);
  }

  function shipItem(uint sku) public 
  sold(sku)
  verifyCaller(items[sku].seller)
  {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  function receiveItem(uint sku) public 
  shipped(sku)
  verifyCaller(items[sku].buyer)
  {
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  function fetchItem(uint _sku) public view 
    returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  { 
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}
