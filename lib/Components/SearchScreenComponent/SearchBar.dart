import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarForSearchScreen extends StatelessWidget {
  const SearchBarForSearchScreen({super.key,required this.searchController});
  final TextEditingController searchController;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: GoogleFonts.roboto(fontSize: 16),
        decoration: InputDecoration(
          hintText: "Search for crops to add...",
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.search, color: Colors.green[600], size: 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );;
  }
}
