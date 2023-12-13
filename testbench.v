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
  
  reg clk;
  reg [11:0] accNumber;
  reg [3:0] pin;
  reg [11:0] destinationAccNumber;
  reg [2:0] menuOption;
  reg [10:0] amount;
  wire [10:0] balance;
  wire [10:0] initial_balance;
  wire [10:0] final_balance;
  reg lang;
  reg [2:0] temp = 0;
  reg [3:0] w;
  reg [9:0] i;

  ATM atmModule(clk, lang, accNumber, pin, destinationAccNumber, menuOption, amount, balance, initial_balance, final_balance);

  initial begin
    clk = 1'b0;
    lang = `english;
  end
  
  initial begin
    clk=0;
    forever begin
      #5 clk=~clk;
    end
  end
  initial begin
    // Direct Test Cases Verification
    amount = 0;
    accNumber = 12'd6134;
    pin = 4'b1001;
    @(negedge clk);
    accNumber = 12'd2816;
    pin = 4'b0110;
    menuOption = `WAITING;
    lang = `english;

    for(w = 3; w < 8; w = w + 1)begin
      menuOption = w;
      if (w == 3)begin
        @(negedge clk);
      end
      else if (w == 4 || w == 5) begin
        amount = 50;
        @(negedge clk);
        amount = 62;
        @(negedge clk);
        amount = 505;
        @(negedge clk);
      end
      else if (w == 6) begin
        lang = ~lang;
        destinationAccNumber = 12'd4634; amount = 29;
        @(negedge clk);
        destinationAccNumber = 12'd3467; amount = 99;
        @(negedge clk);
        amount = 73;
        @(negedge clk);
        amount = 503;
        @(negedge clk);
      end
      else if (w == 7) begin
        lang = ~lang;
        amount = 429;
        @(negedge clk);
        amount = 430;
        @(negedge clk);
      end
    end
    amount = 0;
    // For Testing Timer
    #1020;
    //////////////////////////////
    accNumber = 12'd3467;
    pin = 4'b0011;
    menuOption = 3;
    @(negedge clk);
    /* #10; */
    // Constrained Random Verification
    /* menuOption = `WAITING;
    accNumber = 12'd3467;
    pin = 4'b1000;

    @(negedge clk);
    for(i = 0; i < 1000;i = i + 1)begin
      if (i != 0) begin
        lang = $random();
        amount = $random();
        temp = $random();
        // To Generate Menu Option in Range (3, 7) Inclusive
        while (!(temp > 2 && temp < 8)) begin
          temp = $random();
        end
        menuOption = temp;
        destinationAccNumber = 12'd2429;
      end
      else
        menuOption = `BALANCE;
      @(negedge clk);
    end */
    #20 $stop();
   end
  //psl Deposit_Check: assert always((menuOption==`DEPOSIT)->next(balance==( prev(balance) + prev(amount) ) ) ) @(posedge clk);
  //psl Withdraw_Check: assert always((menuOption==`WITHDRAW)->next(balance==(prev(balance)-prev(amount)))) @(posedge clk);
  //psl Withdraw_Show_Balance_Check: assert always((menuOption==`WITHDRAW_SHOW_BALANCE)->next(balance==(prev(balance)-prev(amount)))) @(posedge clk);
  //psl Transaction_Check: assert always((menuOption==`TRANSACTION)->next(balance==prev(balance)-prev(amount) && final_balance==initial_balance+prev(amount))) @(posedge clk);
endmodule