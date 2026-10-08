enum UserRole { customer, trainer, advisor, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return "Customer";
      case UserRole.trainer:
        return "Trainer";
      case UserRole.advisor:
        return "Healthcare Advisor";
      case UserRole.admin:
        return "System Admin";
    }
  }
}
