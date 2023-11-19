`define true 1'b1
`define false 1'b0

`define FIND 1'b0
`define AUTHENTICATE 1'b1

`define WAITING               4'b0000
`define MENU                  4'b0010
`define BALANCE               4'b0011
`define WITHDRAW              4'b0100
`define WITHDRAW_SHOW_BALANCE 4'b0101
`define TRANSACTION           4'b0110
`define DEPOSIT               4'b0111


module authentication(
  input [11:0] accNumber,
  input [3:0] pin,
  input action,
  input deAuth,
  output reg  wasSuccessful,
  output reg [3:0] accIndex
);


  reg [11:0] acc_database [0:9];
  reg [3:0] pin_database [0:9];

  //initializing the database with arbitrary accounts
  initial begin
    acc_database[0] = 12'd2749; pin_database[0] = 4'b0000;
    acc_database[1] = 12'd2175; pin_database[1] = 4'b0001;
    acc_database[2] = 12'd2429; pin_database[2] = 4'b0010;
    acc_database[3] = 12'd2125; pin_database[3] = 4'b0011;
    acc_database[4] = 12'd2178; pin_database[4] = 4'b0100;
    acc_database[5] = 12'd2647; pin_database[5] = 4'b0101;
    acc_database[6] = 12'd2816; pin_database[6] = 4'b0110;
    acc_database[7] = 12'd2910; pin_database[7] = 4'b0111;
    acc_database[8] = 12'd2299; pin_database[8] = 4'b1000;
    acc_database[9] = 12'd2689; pin_database[9] = 4'b1001;
    end

  always @ (deAuth) begin
    if(deAuth == `true)
      wasSuccessful = 1'bx;
  end
  //looping through the database, trying to find a match for the given accNumber and pin
  // if action is set to find then it'll simply ry to find a match for the given accNumber and returns its index
  integer i;
  always @(accNumber or pin) begin
      wasSuccessful = `false;
      accIndex = 0;

      //loop through the data base
      for(i = 0; i < 10; i = i+1) begin

          //found a match for accNumber
          if(accNumber == acc_database[i]) begin
              
              if(action == `FIND) begin
                wasSuccessful = `true;
                accIndex = i;
              end

              if(action == `AUTHENTICATE) begin
                if(pin == pin_database[i]) begin
                  wasSuccessful = `true;
                  accIndex = i;

                end
              end
          end    
      end
  end

endmodule

//

module timer(clk, rst, en, timer_out);
  input clk, rst, en;
  output reg timer_out;
  reg [31:0] count;

  // This always block triggers on the positive edge of clk or rst
  always @(posedge clk or posedge rst)
  begin
    if (rst)  // If reset is active
    begin
      count <= 0;  // Reset the count to 0
    end
    else if (en)  // If the enable signal is active
      count <= count + 1;  // Increment the count
  end

  // This always block triggers on the positive edge of clk only
  always @(posedge clk)
  begin
    if (rst)  // If reset is active
      timer_out <= 0;  // Set timer_out to 0
    else if (en && (count == 6000000000))  // If enable signal is active and count reaches 60000000000 (60 Seconds)
      timer_out <= 1;  // Set timer_out to 1
    else
      timer_out <= 0;  // Otherwise, keep timer_out at 0
  end
endmodule

module ATM(
  input clk,
  input exit,
  input [1:0] lang,
  input [11:0] accNumber,
  input [3:0] pin,
  input [11:0] destinationAcc, 
  input [2:0]menuOption,
  input [10:0] amount, 
  output reg error,
  output reg [10:0] balance
  );

  //initializing the balance database with an arbitrary amount of money
  reg [15:0] balance_database [0:9];
  initial begin
    $display("Welcome to the ATM");
     balance_database[0] = 16'd500;
     balance_database[1] = 16'd500;
     balance_database[2] = 16'd500;
     balance_database[3] = 16'd500;
     balance_database[4] = 16'd500;
     balance_database[5] = 16'd500;
     balance_database[6] = 16'd500;
     balance_database[7] = 16'd500;
     balance_database[8] = 16'd500;
     balance_database[9] = 16'd500;

  end
  
  reg [3:0] currState = `WAITING;
  
  wire [3:0] accIndex;
  wire [3:0] destinationAccIndex;
  wire isAuthenticated;
  wire wasFound;
  reg choice=1'b1;
  reg deAuth = `false;

  authentication authAccNumberModule(accNumber, pin, `AUTHENTICATE, deAuth, isAuthenticated, accIndex);
  authentication findAccNumberModule(destinationAcc, 0, `FIND, deAuth, wasFound, destinationAccIndex);

  //main block of module with asynchronous exit
  always @(posedge clk or isAuthenticated or menuOption or exit) begin
    
    //restart the error
	  error = `false;
    if(exit == `true) begin
      //transition to the waiting state
      currState = `WAITING;
      //deathenticate the current user
      deAuth = `true;
      #20;      
    end
    
    reg timedOut, reset = 1, enable = 1;
    if(currState == `MENU) begin
      timer t1(clk, reset, enable, timedOut);
      //set the selected option as the current state
      if((menuOption >= 0) & (menuOption <= 7))begin 
        currState = menuOption;
      end else
        currState = menuOption;
    end
    

    //switch case for the menu options
    //the rest is pretty straight forward
      case (currState)


      `WAITING: begin
        if (isAuthenticated == `true) begin
          currState = `MENU;
          $display("Logged In.");
        end
        else if(isAuthenticated == `false) begin
          $display("Account number or password was incorrect");
          currState = `WAITING;
        end
      end


      `BALANCE: begin
        if (timedOut)begin
          $display("You Have Been Idle For 1 Minute\nGoing Back To Enter Your Pin Code Again...");
          #5 currState = `WAITING; deAuth = `false;
        end
        else begin
          balance = balance_database[accIndex];
          $display("Account %d has balance %d", accNumber, balance_database[accIndex]);
          currState = `MENU;
        end
      end


      `WITHDRAW: begin
        if (timedOut)begin
            $display("You Have Been Idle For 1 Minute\nGoing Back To Enter Your Pin Code Again...");
            #5 currState = `WAITING; deAuth = `false;
          end
        else begin
          if (amount <= balance_database[accIndex]) begin
            balance_database[accIndex] = balance_database[accIndex] - amount;
            balance = balance_database[accIndex];
            currState = `MENU;
            error = `false;
          end
          else begin
            currState = `MENU;
            error = `true;
          end
        end
      end


      `WITHDRAW_SHOW_BALANCE: begin
        if (timedOut)
          begin
            $display("You Have Been Idle For 1 Minute\nGoing Back To Enter Your Pin Code Again...");
            #5 currState = `WAITING; deAuth = `false;
          end
        else 
          begin
          if (amount <= balance_database[accIndex]) begin
            balance_database[accIndex] = balance_database[accIndex] - amount;
            balance = balance_database[accIndex];
            currState = `MENU;
            error = `false;
            $display("Account %d has balance %d after withdrawing %d", accNumber, balance_database[accIndex], amount);
          end
          else begin
            currState = `MENU;
            error = `true;
          end
        end
      end


      `TRANSACTION: begin
        if (timedOut)
          begin
            $display("You Have Been Idle For 1 Minute\nGoing Back To Enter Your Pin Code Again...");
            #5 currState = `WAITING; deAuth = `false;
          end
        else
          begin
          if ((amount <= balance_database[accIndex]) & (wasFound == `true) & (balance_database[accIndex] + amount < 2048)) begin
              currState = `MENU;
              error = `false;
              balance_database[destinationAccIndex] = balance_database[destinationAccIndex] + amount;
              balance_database[accIndex] = balance_database[accIndex] - amount;
              $display("Destination account %d after transaction has a total balance of %d", destinationAcc, balance_database[destinationAccIndex]);
          end
          else begin
              currState = `MENU;
              error = `true;
          end
        end
      end

      `DEPOSIT: begin : Deposit
        if((amount < 2048) && (balance_database[accIndex] + amount < 65535) )begin
              $display("The deposited amount is %d", amount);
              $display("Are you sure you want to deposit this amount? T/F");
              error = `false;
              case (choice)
                  1'b1: begin
                    balance_database[accIndex] = balance_database[accIndex] + amount;
                    balance = balance_database[accIndex];
                    $display("Account %d has balance %d after depositing %d", accNumber, balance_database[accIndex], amount);
                  end
                  default:begin 
                    balance_database[accIndex] = balance_database[accIndex];
                    balance = balance_database[accIndex];
                    $display("Operation cancelled. Your balance is %d",balance_database[accIndex]);
                  end
              endcase
            end
            else begin
              currState = `MENU;
              error = `true;
            end
        end
   endcase 

  end

endmodule