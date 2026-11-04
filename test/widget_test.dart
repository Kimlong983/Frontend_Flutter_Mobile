import 'package:demo_access_refresh_token_app/models/auth/login_response.dart';
import 'package:demo_access_refresh_token_app/models/employee/employee_model.dart';
import 'package:demo_access_refresh_token_app/models/product/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JwtRes parses tokens and user', () {
    final res = LoginResponse.fromJson({
      'accessToken': 'a',
      'refreshToken': 'r',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': {
        'id': 1,
        'username': 'admin',
        'email': 'a@b.com',
        'roles': ['ROLE_ADMIN'],
      },
    });
    expect(res.accessToken, 'a');
    expect(res.refreshToken, 'r');
    expect(res.user!.username, 'admin');
    expect(res.user!.roles, ['ROLE_ADMIN']);
  });

  test('Product parses nested category and numbers', () {
    final p = ProductModel.fromJson({
      'id': 3,
      'name': 'Mouse',
      'productCode': 'P003',
      'category': {'id': 2, 'name': 'Accessories'},
      'price': 12,
      'stockQuantity': 5.0,
    });
    expect(p.categoryName, 'Accessories');
    expect(p.formattedPrice, '\$12.00');
    expect(p.isLowStock, isTrue);
  });

  test('Employee round-trips to EmployeeReq', () {
    final e = EmployeeModel.fromJson({
      'id': 7,
      'employeeCode': 'EMP007',
      'firstName': 'Sok',
      'lastName': 'Dara',
      'gender': 'MALE',
      'dateOfBirth': '1999-04-05',
      'email': 'dara@example.com',
      'phoneNumber': '+855 12345678',
      'position': '',
      'salary': 1500,
      'hireDate': '2024-01-15',
      'status': 'INA',
    });
    final json = e.toRequestJson();

    expect(json.containsKey('id'), isFalse);
    expect(json['dateOfBirth'], '1999-04-05');
    expect(json['hireDate'], '2024-01-15');
    expect(json['salary'], 1500.0);
    expect(json['position'], isNull, reason: 'empty strings are sent as null');
    expect(json['status'], 'INA');
    expect(e.isActive, isFalse);
    expect(e.initials, 'SD');
  });
}
