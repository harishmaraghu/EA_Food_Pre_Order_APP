import 'dart:ui';
import 'package:flutter/material.dart';

class RoleModel {
  final String name;
  final String description;
  final String businessRole;
  final IconData icon;
  final Color color;
  final List<String> capabilities;
  final List<String> orderExamples;
  final String orderType;
  final String businessImpact;

  RoleModel({
    required this.name,
    required this.description,
    required this.businessRole,
    required this.icon,
    required this.color,
    required this.capabilities,
    required this.orderExamples,
    required this.orderType,
    required this.businessImpact,
  });
}
