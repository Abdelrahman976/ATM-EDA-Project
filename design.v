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


module ATM(
  input clk,
  input exit,
  input [1:0] lang,
  input [11:0] accNumber,
  input [3:0] pin,
  input [11:0] destinationAcc, 
  input [2:0]menuOption,
  input [10:0] amount,
  input integer depAmount,
  output reg error,
  output reg [10:0] balance
  );


  //initializing the balance database with an arbitrary amount of money
  reg [15:0] balance_database [0:9];
  initial begin
    if( lang == 1'b1 )begin
      $display("أهلاً بك في جهاز الصراف الآلي");
    end
    else  begin
      $display("Welcome to the ATM");
    end
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
  
  reg [2:0] currState = `WAITING;
  wire [3:0] accIndex;
  wire [3:0] destinationAccIndex;
  wire isAuthenticated;
  wire wasFound;
  reg deAuth = `false;
  time timer = 0;
  time timeLimit = 100; // 1000 ns
  integer counter = 0;
  reg logout = `false;

  authentication authAccNumberModule(accNumber, pin, `AUTHENTICATE, deAuth, isAuthenticated, accIndex);
  authentication findAccNumberModule(destinationAcc, 0, `FIND, deAuth, wasFound, destinationAccIndex);

  // Timer Counter
   always @(posedge clk)begin
     if (counter <= timeLimit)begin
       counter <= counter + 1;
       logout = `false;
     end
     else begin
        if( lang == `arabic ) begin
          $display("تم تجاوز حد الوقت المسموح به. يرجى المحاولة مرة أخرى لاحقًا"); 
        end
        else begin
          $display("Timeout limit exceeded. Please try again later");
        end
        currState = `WAITING;
        deAuth = `true;
        logout = `true;
      end
   end

   always @(menuOption) begin
      counter = 0;
      balance = balance_database[accIndex];
      if((menuOption >= 0) & (menuOption <= 7))begin
        currState = menuOption;
      end else
        currState = menuOption;
      if(logout == `true)
        currState = `WAITING;
   end

   always @(isAuthenticated or exit) begin
    //restart the error
	  error = `false;
    if(exit == `true || logout == `true) begin
      //transition to the waiting state
      currState = `WAITING;
      //deathenticate the current user
      deAuth = `true;
      #20;
    end
   end

  //main block of module with asynchronous exit
  always @(posedge clk) begin

    //switch case for the menu options
    //the rest is pretty straight forward
    currState = menuOption;
      case (currState)

      `WAITING: begin
        if (isAuthenticated == `true && logout == `false) begin
          currState = `MENU;
          if( lang == `arabic ) begin
            $display(" تم نسجيل الدخول");
          end
          else begin
            $display("Logged In.");
          end
        end
        else if(isAuthenticated == `false || logout == `true) begin
          if( lang == `arabic ) begin
            if (logout == `true)
              $display("تم تسجيل الخروج");
            else
              $display(" رقم الحساب او كلمه المرور خطأ");
          end
          else begin
            if (logout == `true)
              $display("You Have Logged Out");
            else
          	  $display("Account number or password was incorrect");
          end
          currState = `WAITING;
        end
      end


      `BALANCE: begin
            balance = balance_database[accIndex];
            if( lang == `arabic ) begin
              $display(" الحساب %d به رصيد %d ", accNumber, balance_database[accIndex] ); 
            end
            else begin
              $display("Account %d has balance %d", accNumber, balance_database[accIndex]);
            end
            currState = `MENU;
      end


      `WITHDRAW: begin
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


      `WITHDRAW_SHOW_BALANCE: begin
            if (amount <= balance_database[accIndex]) begin
              balance_database[accIndex] = balance_database[accIndex] - amount;
              balance = balance_database[accIndex];
              currState = `MENU;
              error = `false;
              if( lang == `arabic )
                $display("الحساب رقم %d لديه رصيد %d بعد سحب مبلغ %d", accNumber, balance_database[accIndex], amount);
              else
                $display("Account %d has balance %d after withdrawing %d", accNumber, balance_database[accIndex], amount);
            end
            else begin
              currState = `MENU;
              error = `true;
            end
      end


      `TRANSACTION: begin
          if ((amount <= balance_database[accIndex]) & (wasFound == `true) & (balance_database[accIndex] + amount < 2048)) begin
              currState = `MENU;
              error = `false;
              balance_database[destinationAccIndex] = balance_database[destinationAccIndex] + amount;
              balance_database[accIndex] = balance_database[accIndex] - amount;
              $display("Destination account %d after transaction has a total balance of %d", destinationAcc, balance_database[destinationAccIndex]);
              if( lang == `arabic )
                $display("الحساب المستلم رقم %d بعد العملية لديه رصيد إجمالي قدره %d", destinationAcc, balance_database[destinationAccIndex]); 
              else
                $display("Destination account %d after transaction has a total balance of %d", destinationAcc, balance_database[destinationAccIndex]);
          end
          else begin
              currState = `MENU;
              error = `true;
          end
      end

      `DEPOSIT:
        begin : Deposit
            if((depAmount==amount) && (balance_database[accIndex] + amount < 65535))
              begin
                if( lang == `arabic ) begin
                    $display("المبلغ المودع هو %d", amount);
                    $display("هل أنت متأكد من رغبتك في إيداع هذا المبلغ؟ نعم/لا");
                  end
                else begin
                  $display("The deposited amount is %d", amount);
                  $display("Are you sure you want to deposit this amount? T/F");
                end
                error = `false;
                balance_database[accIndex] = balance_database[accIndex] + amount;
                balance = balance_database[accIndex];
                if( lang == `arabic ) begin
                  $display("الحساب %d لديه رصيد %d بعد إيداع مبلغ %d", accNumber, balance_database[accIndex], amount);
                  end
                else begin
                  $display("Account %d has balance %d after depositing %d", accNumber, balance_database[accIndex], amount);
                end
              end
            else begin
              currState = `MENU;
              error = `true;
            end
        end
      default: begin
        currState = `WAITING;
      end
   endcase 

  end

endmodule