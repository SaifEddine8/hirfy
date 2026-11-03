
class Utils {


  static bool checkEmail(String Email)
  {
    String pattern=r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(pattern).hasMatch(Email);
  }

  static bool checkPassword(String Password)
  {
    String pattern=r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s:])([^\s]){8,16}$';

    return RegExp(pattern).hasMatch(Password);
  }
  

  static bool checkUsername(String Username)
  {
    String pattern=r'^(?=.{3,20}$)(?![_.-])(?!.*[_.-]{2})[a-zA-Z0-9_-]+([^._-])$';
    return RegExp(pattern).hasMatch(Username);
  }


static bool checkPhone(String phone)
  {
    String pattern=r'(?:([+]\d{1,4})[-.\s]?)?(?:[(](\d{1,3})[)][-.\s]?)?(\d{1,4})[-.\s]?(\d{1,4})[-.\s]?(\d{1,9})';
    return RegExp(pattern).hasMatch(phone);
  }
}