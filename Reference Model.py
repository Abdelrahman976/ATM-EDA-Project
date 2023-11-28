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
        'withdraw': "يرجى استلام نقودك",
        'withdraw_with_balance': "يرجى استلام نقودك\nرصيدك الحالي هو: ",
        'invalid_choice': "خيار غير صالح. يرجى إدخال رقم بين 1 و 9.",
        'thank_you': "شكرًا لاستخدام جهاز الصراف الآلي. وداعاً!"
    }
}


class ATM:
    def __init__(self, balance=0, lang='en'):
        print(LANGUAGES[lang]['welcome'])
        self.balance = balance
        self.users = {
            '2749': {'pin': 0, 'balance': 0},
            '2175': {'pin': 1, 'balance': 0},
            '2429': {'pin': 2, 'balance': 0},
            '2125': {'pin': 3, 'balance': 0},
            '2178': {'pin': 4, 'balance': 0},
            '2647': {'pin': 5, 'balance': 0},
            '2816': {'pin': 6, 'balance': 0},
            '2910': {'pin': 7, 'balance': 0},
            '2299': {'pin': 8, 'balance': 0},
            '2689': {'pin': 9, 'balance': 0}
        }
        self.current_user = None
        self.lang = lang
        self.idle_timeout = 60 # 1 minute
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
        while True:
            print("\n==== ATM Menu ====")
            print("1. Login")
            print("2. Logout")
            print("3. Check Balance")
            print("4. Withdraw With Balance")
            print("5. Withdraw")
            print("6. Deposit")
            print("7. Exit")

            print("")
            atm.last_activity_time = time.time()
            choice = input("Enter your choice (1-7): ")
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
                        print(atm.withdraw_with_balance(amount))
                    else:
                        print("Please login first.")

                case "5":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input("Enter the amount to withdraw: "))
                        print(atm.withdraw(amount))
                    else:
                        print("Please login first.")

                case "6":
                    atm.check_idle_timeout()
                    if atm.current_user:
                        amount = float(input(LANGUAGES[atm.lang]['deposit_entry']))
                        print(atm.deposit(amount))
                    else:
                        print("Please login first.")

                case "7":
                    print("Thank you for using the ATM. Goodbye!")
                    break

                case _:
                    print("Invalid choice. Please enter a number between 1 and 9.")
    elif lang == 1:
        while True:
            print("\n==== قائمة اختيارات الصرف الالي ====")
            print("1. تسجيل الدخول")
            print("2. تسجيل خروج")
            print("3. التأكد من الرصيد")
            print("4. سحب نقدي مع اظهار الرصيد")
            print("5. سحب نقدي")
            print("6. ايداع نقدي")
            print("7. الخروج")

            choice = input("برجاء ادخال رقم من (1-7): ")

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
                    if atm.current_user:
                        print(atm.check_balance())
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "4":
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد سحبه: "))
                        print(atm.withdraw_with_balance(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "5":
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد سحبه: "))
                        print(atm.withdraw(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "6":
                    if atm.current_user:
                        amount = float(input("ادخل المبلغ المراد ايداعه: "))
                        print(atm.deposit(amount))
                    else:
                        print("برجاء تسجيل الدخول اولا.")

                case "7":
                    print("شكرا لاستخدامكم خدمات الصرف الالي. مع السلامه!")
                    break
                case _:
                    print("اختيار خاطئ برجاء اختيار رقم من 1 الى 7: ")
    else:
        print("Invalid Input")


main()
