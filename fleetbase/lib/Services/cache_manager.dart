// lib/Services/cache_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../Model/Task.dart';
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  Future<SharedPreferences> get _prefs async => 
      await SharedPreferences.getInstance();

  // Generic save method
  Future<void> saveData(String key, dynamic data) async {
    final prefs = await _prefs;
    if (data is String) {
      await prefs.setString(key, data);
    } else {
      await prefs.setString(key, json.encode(data));
    }
  }

  // Generic load method
  Future<dynamic> loadData(String key) async {
    final prefs = await _prefs;
    final data = prefs.getString(key);
    return data != null ? json.decode(data) : null;
  }

  // Specific methods for your data types
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await saveData('user_session', userData);
  }

  Future<Map<String, dynamic>?> loadUserSession() async {
    return await loadData('user_session');
  }

  Future<void> saveDeliveries(List<dynamic> deliveries) async {
    await saveData('deliveries', deliveries);
  }

  Future<List<dynamic>?> loadDeliveries() async {
    return await loadData('deliveries');
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await saveData('tasks', tasks.map((task) => task.toJson()).toList());
  }

  Future<List<Task>?> loadTasks() async {
    final data = await loadData('tasks');
    return data != null 
        ? (data as List).map((e) => Task.fromJson(e)).toList()
        : null;
  }

  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}