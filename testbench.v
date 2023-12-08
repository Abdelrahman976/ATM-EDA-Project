`timescale 1ns/1ns
`define true 1'b1
`define false 1'b0

`define FIND 1'b0
`define AUTHENTICATE 1'b1

`define arabic 1'b1
`define english 1'b0

`define WAITING               3'b000
`define MENU                  3'b010
`define BALANCE               3'b011
`define WITHDRAW              3'b100
`define WITHDRAW_SHOW_BALANCE 3'b101
`define TRANSACTION           3'b110
`define DEPOSIT               3'b111


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
  reg lang;
  integer i;

  ATM atmModule(clk, exit, lang, accNumber, pin, destinationAccNumber, menuOption, amount, depAmount, error, balance);

  initial begin
    clk = 1'b0;
    lang = `english;
  end
  
   always @(error) begin
      if(error == `true)
        $display("Error!, action causes an invalid operation.");
   end
  
  initial begin
    clk=0;
    forever begin
      #5 clk=~clk;
    end
  end
  initial begin
    
    accNumber = 12'd2178;
    pin = 4'b0100;
    $display("------------------------------------------------------------------------------------");
    @(negedge clk);
     for(i=0;i<5;i=i+1)begin
        amount = $random();
        depAmount = amount;
        menuOption = $random();
        destinationAccNumber = 12'd2429;
        $display("Your Menu Option is: %d", menuOption);
        $display("Your Amount is: %d", amount);
        #5;
        $display("Your Balance is: %d", balance);
        $display("------------------------------------------------------------------------------------");
        @(posedge clk);
     end
    $stop();
   end
  //psl Deposit_Check: assert always((menuOption==`DEPOSIT && error == 1'b0)->next(balance==( prev(balance) + prev(amount) ) ) ) @(posedge clk);
  //psl Withdraw_Check: assert always((menuOption==`WITHDRAW && error == 1'b0)->next(balance==(prev(balance)-prev(amount)))) @(posedge clk);
  //psl Withdraw_Show_Balance_Check: assert always((menuOption==`WITHDRAW_SHOW_BALANCE && error == 1'b0)->next(balance==(prev(balance)-prev(amount)))) @(posedge clk);
  //psl Balance_Check: assert always((menuOption==`BALANCE && error == 1'b0)->next(balance==prev(balance))) @(posedge clk);
  //psl Transaction_Check: assert always((menuOption==`TRANSACTION && error == 1'b0)->next(balance==prev(balance)-prev(amount))) @(posedge clk);
endmodule