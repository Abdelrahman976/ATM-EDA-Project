import random
from datetime import datetime
import time

LANGUAGES = {
    'en': {
        'welcome': "Welcome To The ATM",
        'invalid_login': "Invalid username or PIN. Please try again.",
        'log_in': "Logged in successfully.",
        'log_out': "Logged out successfully.",
        'balance': "Your current balance is: ",
        'deposit_done': "Account is Deposited Successfully",
        'deposit_entry': "Please Enter Your Cash: ",
        'insufficient_funds': "Insufficient funds",
        'account_not_found': "Account not found",
        'withdraw': "Please Collect Your Cash",
        'withdraw_with_balance': "Please Collect Your Cash\nYour current balance is: ",
        'invalid_choice': "Invalid choice. Please enter a number between 1 and 9.",
        'thank_you': "Thank you for using the ATM. Goodbye!"
    },
    'ar': {
        'welcome': "مرحبًا بك في جهاز الصراف الآلي",
        'invalid_login': "اسم مستخدم أو رقم تعريف شخصي غير صالح. يرجى المحاولة مرة أخرى.",
        'log_in': "تم تسجيل الدخول بنجاح.",
        'log_out': "تم تسجيل الخروج بنجاح.",
        'balance': "رصيدك الحالي هو: ",
        'deposit_done': "تم إيداع الحساب بنجاح",
        'deposit_entry': "يرجى إدخال مبلغ الإيداع الخاص بك: ",
        'insufficient_funds': "رصيد غير كافٍ",
        'account_not_found': "الحساب غير موجود",
        'withdraw': "يرجى استلام نقودك",
        'withdraw_with_balance': "يرجى استلام نقودك\nرصيدك الحالي هو: ",
        'invalid_choice': "خيار غير صالح. يرجى إدخال رقم بين 1 و 9.",
        'thank_you': "شكرًا لاستخدام جهاز الصراف الآلي. وداعاً!"
    }
}


class ATM:
    def __init__(self, balance=500, lang='en'):
        print(LANGUAGES[lang]['welcome'])
        self.balance = balance
        self.users = {
            '4023': {'pin': 0, 'balance': 500},
            '4000': {'pin': 1, 'balance': 500},
            '3993': {'pin': 2, 'balance': 500},
            '3467': {'pin': 3, 'balance': 500},
            '3100': {'pin': 4, 'balance': 500},
            '2937': {'pin': 5, 'balance': 500},
            '2816': {'pin': 6, 'balance': 500},
            '2429': {'pin': 7, 'balance': 500},
            '1697': {'pin': 8, 'balance': 500},
            '1392': {'pin': 9, 'balance': 500}
        }
        self.current_user = None
        self.lang = lang
        self.idle_timeout = 8  # 8 Seconds
        self.last_activity_time = time.time()

    def is_authentic(self, accountNum, pin):
        if accountNum in self.users and str(self.users[accountNum]['pin']) == pin:
            self.current_user = accountNum
            return True
        else:
            return False

    def login(self, accountNum, pin):
        global LANGUAGES
        if self.is_authentic(accountNum, pin):
            return LANGUAGES[self.lang]['log_in']
        else:
            return LANGUAGES[self.lang]['invalid_login']

    def logout(self):
        self.current_user = None
        return LANGUAGES[self.lang]['log_out']

    def check_balance(self):
        return str(LANGUAGES[self.lang]['balance']) + str(self.users[self.current_user]['balance'])

    def wasFound(self, dest):
        return self.users.get(str(dest)) is not None

    def deposit(self, amount):
        self.users[self.current_user]['balance'] += amount
        return LANGUAGES[self.lang]['deposit_done']

    def withdraw(self, amount):
        if amount > self.users[self.current_user]['balance']:
            return LANGUAGES[self.lang]['insufficient_funds']
        else:
            self.users[self.current_user]['balance'] -= amount
            return LANGUAGES[self.lang]['withdraw']

    def withdraw_with_balance(self, amount):
        if amount > self.users[self.current_user]['balance']:
            return LANGUAGES[self.lang]['insufficient_funds']
        else:
            self.users[self.current_user]['balance'] -= amount
            return LANGUAGES[self.lang]['withdraw_with_balance'] + str(self.users[self.current_user]['balance'])

    def transaction(self, amount, dest):
        if not self.wasFound(str(dest)):
            return LANGUAGES[self.lang]['account_not_found']
        elif amount > self.users[self.current_user]['balance']:
            return LANGUAGES[self.lang]['insufficient_funds']
        else:
            self.users[self.current_user]['balance'] -= amount
            self.users[str(dest)]['balance'] += amount
            return LANGUAGES[self.lang]['balance'] + str(self.users[self.current_user]['balance'])

    def check_idle_timeout(self):
        current_time = time.time()
        idle_time = current_time - self.last_activity_time
        if idle_time >= self.idle_timeout:
            if self.lang == "en":
                choice = str(input("You are Timedout, Do you want to continue? (Y/N)\n"))
                if choice.lower() == "n":
                    if self.current_user is not None:
                        self.logout()
                        print("Logout due to inactivity.")
            else:
                choice = str(input("تم انتهاء الوقت المحدد، هل ترغب في المتابعة؟ (نعم/لا)\n"))
                if choice == "لا":
                    if self.current_user is not None:
                        self.logout()
                        print("تسجيل الخروج بسبب عدم النشاط.")


def main():
    atm = ATM()
    lang = int(input("Please Choose Your Language: (English: 0), (اللغة العربية: 1): "))
    if lang == 0:
        atm.lang = 'en'
        while True:
            print("\n==== ATM Menu ====")
            print("1. Login")
            print("2. Logout")
            print("3. Check Balance")
            print("4. Withdraw")
            print("5. Withdraw With Balance")
            print("6. Transaction")
            print("7. Deposit")
            print("8. Exit")

            choice = input("Enter your choice (1-8): ")

            match choice:
                case "1":
                    if atm.current_user:
                        print("Already logged in. Logout first.")
                    else:
                        accountNum = input("Enter your accountNum: ")
                        pin = input("Enter your PIN: ")
                        print(atm.login(accountNum, pin))

                case "2":
                    print(atm.logout())

                case "3":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        print(atm.check_balance())
                    else:
                        print("Please login first.")

                case "4":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("Enter the amount to withdraw: "))
                        print(atm.withdraw(amount))
                    else:
                        print("Please login first.")

                case "5":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("Enter the amount to withdraw: "))
                        print(atm.withdraw_with_balance(amount))
                    else:
                        print("Please login first.")

                case "6":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("Enter transfer amount: "))
                        dest = int(input("Enter destination account number: "))
                        print(atm.transaction(amount, dest))
                    else:
                        print("Please login first.")

                case "7":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input(LANGUAGES[atm.lang]['deposit_entry']))
                        print(atm.deposit(amount))
                    else:
                        print("Please login first.")

                case "8":
                    print("Thank you for using the ATM. Goodbye!")
                    break

                case _:
                    print("Invalid choice. Please enter a number between 1 and 8.")
            atm.last_activity_time = time.time()
    elif lang == 1:
        atm.lang = 'ar'
        while True:
            print("\n==== قائمة اختيارات الصرف الالي ====")
            print("1. تسجيل الدخول")
            print("2. تسجيل خروج")
            print("3. التأكد من الرصيد")
            print("4. سحب نقدي")
            print("5. سحب نقدي مع اظهار الرصيد")
            print("6. تحويل رصيد")
            print("7. ايداع نقدي")
            print("8. الخروج")

            choice = input("برجاء ادخال رقم من (1-8): ")

            match choice:
                case "1":
                    if atm.current_user:
                        print("لقد تم تسجيل الدخول لهذا الحساب من قبل, برجاء تسجيل الخروج اولا.")
                    else:
                        accountNum = input("برجاء ادخال رقم الحساب: ")
                        pin = input("برجاء ادخال الرقم السري: ")
                        print(atm.login(accountNum, pin))
                case "2":
                    print(atm.logout())
                case "3":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        print(atm.check_balance())
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "4":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد سحبه: "))
                        print(atm.withdraw(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "5":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد سحبه: "))
                        print(atm.withdraw_with_balance(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "6":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد تحويله: "))
                        dest = int(input("ادخل رقم الحساب المراد التحويل اليه: "))
                        print(atm.transaction(amount, dest))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "7":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد ايداعه: "))
                        print(atm.deposit(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "8":
                    print("شكرا لاستخدامكم خدمات الصرف الالي. مع السلامه!")
                    break
                case _:
                    print("اختيار خاطئ برجاء اختيار رقم من 1 الى 8.")
            atm.last_activity_time = time.time()
    else:
        print("Invalid Input")


main()
