// `timescale 1ns/1ns
`define true 1'b1
`define false 1'b0

`define FIND 1'b0
`define AUTHENTICATE 1'b1

`define WAITING               4'b0000
`define GET_PIN               4'b0001
`define MENU                  4'b0010
`define BALANCE               4'b0011
`define WITHDRAW              4'b0100
`define WITHDRAW_SHOW_BALANCE 4'b0101
`define TRANSACTION           4'b0110
`define DEPOSIT               4'b0111
`define DONE                  4'b1000


module atm_tb();
  
  reg clk, exit;
  reg [11:0] accNumber;
  reg [3:0] pin;
  reg [11:0] destinationAccNumber;
  reg [2:0] menuOption;
  reg [10:0] amount;
  integer depAmount;
  wire error;
  wire [10:0] balance;
  
  ATM atmModule(clk, exit, 0, accNumber, pin, destinationAccNumber, menuOption, amount, depAmount, error, balance);
  
  
  initial begin
    clk = 1'b0;
  end
  
   always @(error) begin
      if(error == `true)
        $display("Error!, action causes an invalid operation.");
   end
  
  initial begin
	

    //incorrect PIN
    accNumber = 12'd2278;
    pin = 4'b0100;
    
    #30

    //valid credentials
    accNumber = 12'd2178;
    pin = 4'b0100;
    
    #30
    
    //withdraw some money and then show the balance
    amount = 100;
	  menuOption = `WITHDRAW_SHOW_BALANCE;
    clk = ~clk;#5clk = ~clk;
    #30

    //show the balance
	  menuOption = `BALANCE;
    clk = ~clk;#5clk = ~clk;
    #30
    
    //withdraw too much money, resulting in an error
    amount = 2500;
	  menuOption = `WITHDRAW;
    clk = ~clk;#5clk = ~clk;
    #30

    //the balance wont change because an error happened during withdrawal
	  menuOption = `BALANCE;
    clk = ~clk;#5clk = ~clk;
    #30


    //transfer some money to the destination account with number 2816
    amount = 50;
    destinationAccNumber = 2816;
	  menuOption = `TRANSACTION;
    clk = ~clk;#5clk = ~clk;
    #30

    //transfer too much money to the destination account with number 2816 which exceeds 2047 and cuases an error
    amount = 2550;
    destinationAccNumber = 2816;
	  menuOption = `TRANSACTION;
    clk = ~clk;#5clk = ~clk;
    #30
    //Deposit some money to the account
      depAmount=500;
      amount=500;
      menuOption=`DEPOSIT;
      clk = ~clk;#5clk = ~clk;
      #30
    //Deposit too much money to the account which exceeds 2047 and cuases an error
      depAmount=2550;
      amount=2550;
      menuOption=`DEPOSIT;
      clk = ~clk;#5clk = ~clk;
      #30
      //Deposit too much money to the account which exceeds 65535 and cuases an error
      depAmount=65535;
      amount=65535;
      menuOption=`DEPOSIT;
      clk = ~clk;#5clk = ~clk;
      #30
    //exit the system 
    exit = 1;
    #30
    exit = 0;
    #30
    
    //log in using the account with number 2816
    accNumber = 12'd2816;
    pin = 4'b0110;
    #30

    //you'll see that the balance is more than the default value because we had trasnsferred some money to this account a while ago
    menuOption = `BALANCE;
    clk = ~clk;#5clk = ~clk;
    #30;
    
  end
  
endmodule
