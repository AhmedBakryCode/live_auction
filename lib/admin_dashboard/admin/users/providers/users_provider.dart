import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repository/users_repository.dart';

class UsersProvider with ChangeNotifier {
  final UsersRepository _repository = UsersRepository();
  UsersResponse? _response;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected user for details screen
  UserModel? _selectedUser;
  bool _isLoadingDetails = false;
  String? _detailsErrorMessage;

  List<UserModel> get users => _response?.users ?? [];
  PaginationMetadata? get pagination => _response?.pagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserModel? get selectedUser => _selectedUser;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsErrorMessage => _detailsErrorMessage;



  // ─── Load Users List ───────────────────────────────────────────────────────
  Future<void> loadUsers({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _repository.fetchUsers(page: page);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // ─── Fetch Single User Details ─────────────────────────────────────────────
  Future<void> fetchUserDetails(int id) async {
    _isLoadingDetails = true;
    _detailsErrorMessage = null;
    _selectedUser = null;
    notifyListeners();

    try {
      _selectedUser = await _repository.fetchUserById(id);
    } catch (e) {
      _detailsErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void clearSelectedUser() {
    _selectedUser = null;
    _detailsErrorMessage = null;
    notifyListeners();
  }

  // ─── Create User ──────────────────────────────────────────────────────────
  Future<bool> createUser({
    required String fname,
    required String lname,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createUser(
        fname: fname,
        lname: lname,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        address: address,
        imagePath: imagePath,
      );

      // Reload from server to keep list in sync
      _isLoading = false;
      notifyListeners();
      await loadUsers(page: 1);

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Delete User ──────────────────────────────────────────────────────────
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.deleteUser(id);
      
      if (success) {
        // Remove locally if we have it in the list (quick UI update)
        if (_response != null) {
          _response!.users.removeWhere((user) => user.id == id);
        }
        // If it's the currently selected user, clear it
        if (_selectedUser?.id == id) {
          _selectedUser = null;
        }
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update User ──────────────────────────────────────────────────────────
  Future<bool> updateUser(
    int id, {
    String? fname,
    String? lname,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? phone,
    String? address,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateUser(
        id,
        fname: fname,
        lname: lname,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        address: address,
        imagePath: imagePath,
      );

      // Update in local list
      if (_response != null) {
        final index = _response!.users.indexWhere((u) => u.id == id);
        if (index != -1) {
          _response!.users[index] = updatedUser;
        }
      }

      // Update details view if needed
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

}
