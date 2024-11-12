enum AccountType { manager, contractor, customer }

class UserAccount {
  final String uid;
  final String email;
  final String name; // New field for the user's name
  final AccountType accountType;

  UserAccount({
    required this.uid,
    required this.email,
    required this.name,
    required this.accountType,
  });

  // Convert account type to string for Firestore
  String get accountTypeString {
    switch (accountType) {
      case AccountType.manager:
        return 'manager';
      case AccountType.contractor:
        return 'contractor';
      case AccountType.customer:
        return 'customer';
      default:
        return 'customer';
    }
  }

  // Factory method to create a UserAccount from Firestore data
  factory UserAccount.fromFirestore(Map<String, dynamic> data, String uid) {
    AccountType accountType;
    switch (data['accountType']) {
      case 'manager':
        accountType = AccountType.manager;
        break;
      case 'contractor':
        accountType = AccountType.contractor;
        break;
      case 'customer':
      default:
        accountType = AccountType.customer;
    }

    return UserAccount(
      uid: uid,
      email: data['email'],
      name: data['name'], // Get the name from Firestore
      accountType: accountType,
    );
  }

  // Convert UserAccount to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name, // Save the name to Firestore
      'accountType': accountTypeString,
    };
  }
}
