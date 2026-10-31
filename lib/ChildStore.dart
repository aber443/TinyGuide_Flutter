import 'package:flutter/foundation.dart';

class ChildModel {
  final int? id;
  final String localId;

  String firstName;
  String middleName;
  String lastName;
  String gender;
  DateTime birthDate;
  String? imagePath;
  String diabetesType;
  DateTime? diagnosisDate;
  String allergy;
  String notes;

  ChildModel({
    this.id,
    required this.localId,
    required this.firstName,
    this.middleName = '',
    this.lastName = '',
    required this.gender,
    required this.birthDate,
    this.imagePath,
    this.diabetesType = '',
    this.diagnosisDate,
    this.allergy = '',
    this.notes = '',
  });

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((name) => name.trim().isNotEmpty).join(' ');

  String get _identityKey => [
    firstName.trim().toLowerCase(),
    middleName.trim().toLowerCase(),
    lastName.trim().toLowerCase(),
    gender.trim(),
    '${birthDate.year}-${birthDate.month}-${birthDate.day}',
  ].join('|');

  factory ChildModel.fromMap(Map<String, dynamic> data) {
    return ChildModel(
      id: data['id'] as int?,
      localId: data['localId']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      firstName: (data['firstName'] ?? '').toString(),
      middleName: (data['middleName'] ?? '').toString(),
      lastName: (data['lastName'] ?? '').toString(),
      gender: (data['gender'] ?? '').toString(),
      birthDate: data['birthDate'] is DateTime
          ? data['birthDate'] as DateTime
          : DateTime.parse(data['birthDate'].toString()),
      imagePath: data['imagePath']?.toString(),
      diabetesType: (data['diabetesType'] ?? '').toString(),
      diagnosisDate: data['diagnosisDate'] is DateTime
          ? data['diagnosisDate'] as DateTime
          : data['diagnosisDate'] == null
          ? null
          : DateTime.parse(data['diagnosisDate'].toString()),
      allergy: (data['allergy'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
    );
  }
}

class ChildStore extends ChangeNotifier {
  ChildStore._();

  static final ChildStore instance = ChildStore._();

  final List<ChildModel> _children = [];
  ChildModel? _selectedChild;

  List<ChildModel> get children => List.unmodifiable(_children);
  ChildModel? get selectedChild => _selectedChild;

  void deduplicateChildren() {
    final selectedId = _selectedChild?.localId;
    final uniqueChildren = <ChildModel>[];
    final seen = <String>{};

    for (final child in _children) {
      if (seen.add(child._identityKey)) {
        uniqueChildren.add(child);
      }
    }

    _children
      ..clear()
      ..addAll(uniqueChildren);

    _selectedChild = _children.cast<ChildModel?>().firstWhere(
          (child) => child?.localId == selectedId,
      orElse: () => _children.isEmpty ? null : _children.first,
    );

    notifyListeners();
  }

  void addChild(ChildModel child) {
    final localIndex = _children.indexWhere(
          (item) => item.localId == child.localId,
    );

    if (localIndex != -1) {
      _children[localIndex] = child;
      _selectedChild = child;
      notifyListeners();
      return;
    }

    final duplicateIndex = _children.indexWhere(
          (item) => item._identityKey == child._identityKey,
    );

    if (duplicateIndex != -1) {
      _selectedChild = _children[duplicateIndex];
      notifyListeners();
      return;
    }

    _children.add(child);
    _selectedChild = child;
    notifyListeners();
  }

  void updateChild(ChildModel child) {
    final index = _children.indexWhere(
          (item) => item.localId == child.localId,
    );

    if (index == -1) return;

    _children[index] = child;

    if (_selectedChild?.localId == child.localId) {
      _selectedChild = child;
    }

    deduplicateChildren();
  }

  void selectChild(String localId) {
    final index = _children.indexWhere(
          (child) => child.localId == localId,
    );

    if (index == -1) return;

    if (_selectedChild?.localId == localId) return;

    _selectedChild = _children[index];
    notifyListeners();
  }

  void clear() {
    _children.clear();
    _selectedChild = null;
    notifyListeners();
  }
}