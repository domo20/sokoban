
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class Donnees {

  Future<Map<String, dynamic>> readJsonFile() async {
    // Read the JSON file
    String jsonData = await rootBundle.loadString('levels.json');

    // Parse the JSON data
    var data = jsonDecode(jsonData);

    // Access the data
    //print(data[0]);
    return data;
  }

  }
