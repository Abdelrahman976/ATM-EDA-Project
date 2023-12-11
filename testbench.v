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
  reg [2:0] temp;
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
    @(posedge clk);
     for(i=0;i<6;i=i+1)begin
      $display("%d, ------------------------------------------------------------------------------------", i);
        if (i != 0) begin
          lang = $random();
          amount = $random();
          depAmount = amount;
          temp = 0;
          temp = $random();
          while (!(temp > 2 && temp < 8)) begin
            temp = $random();
          end
          menuOption = temp;
          destinationAccNumber = 12'd2429;
        end
        else
          menuOption = `BALANCE;
        @(posedge clk);
     end
     #10;
    $stop();
   end
  //psl Deposit_Check: assert always((menuOption==`DEPOSIT && !error)->next(balance==( prev(balance) + prev(amount) ) ) ) @(negedge clk);
  //psl Withdraw_Check: assert always((menuOption==`WITHDRAW && !error)->next(balance==(prev(balance)-prev(amount)))) @(negedge clk);
  //psl Withdraw_Show_Balance_Check: assert always((menuOption==`WITHDRAW_SHOW_BALANCE && !error)->next(balance==(prev(balance)-prev(amount)))) @(negedge clk);
  //psl Balance_Check: assert always((menuOption==`BALANCE && !error)->next(balance==prev(balance))) @(negedge clk);
  //psl Transaction_Check: assert always((menuOption==`TRANSACTION && !error)->next(balance==prev(balance)-prev(amount))) @(negedge clk);
endmodule