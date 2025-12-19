import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../widgets/glass_widget.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _categoryController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _instructionControllers;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe?.title ?? '');
    _descriptionController = TextEditingController(
      text: recipe?.description ?? '',
    );
    _prepTimeController = TextEditingController(
      text: recipe?.prepTime.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: recipe?.cookTime.toString() ?? '',
    );
    _servingsController = TextEditingController(
      text: recipe?.servings.toString() ?? '',
    );
    _categoryController = TextEditingController(text: recipe?.category ?? '');
    _ingredientControllers = (recipe?.ingredients ?? [''])
        .map((ing) => TextEditingController(text: ing))
        .toList();
    _instructionControllers = (recipe?.instructions ?? [''])
        .map((inst) => TextEditingController(text: inst))
        .toList();

    // Load existing image if editing and it's a local file
    if (!kIsWeb &&
        recipe != null &&
        recipe.imageUrl != null &&
        recipe.imageUrl!.isNotEmpty &&
        !recipe.imageUrl!.startsWith('http')) {
      try {
        final file = File(recipe.imageUrl!);
        if (file.existsSync()) {
          _selectedImage = file;
        }
      } catch (e) {
        // File doesn't exist or error reading it
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _categoryController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(pickedFile.path);
          }
          // On web, image_picker handles images differently
          // _selectedImage is not used on web since we show placeholder
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text('Error: $e'),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 0,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9CAF88).withValues(alpha: 0.7),
                  const Color(0xFF87A96B).withValues(alpha: 0.65),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF87A96B).withValues(alpha: 0.5),
                          const Color(0xFF6B8E5A).withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Select Image Source',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ImageSourceOption(
                        icon: Icons.camera_alt,
                        color: Colors.white,
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      _ImageSourceOption(
                        icon: Icons.photo_library,
                        color: Colors.white,
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      final ingredients = _ingredientControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      final instructions = _instructionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF87A96B).withValues(alpha: 0.8),
                        const Color(0xFF6B8E5A).withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Text('Add ingredient'),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 0,
          ),
        );
        return;
      }

      if (instructions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF87A96B).withValues(alpha: 0.8),
                        const Color(0xFF6B8E5A).withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Text('Add instruction'),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 0,
          ),
        );
        return;
      }

      final recipe = Recipe(
        id:
            widget.recipe?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: ingredients,
        instructions: instructions,
        prepTime: int.parse(_prepTimeController.text),
        cookTime: int.parse(_cookTimeController.text),
        servings: int.parse(_servingsController.text),
        category: _categoryController.text.trim(),
        imageUrl: _selectedImage != null
            ? _selectedImage!.path
            : widget.recipe?.imageUrl,
      );

      Navigator.pop(context, recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: IconButton(
                  onPressed: _saveRecipe,
                  icon: const Icon(Icons.check_outlined, size: 24),
                  color: Colors.white,
                  tooltip: 'Save',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9CAF88), // Sage green light
              const Color(0xFF87A96B), // Sage green
              const Color(0xFF6B8E5A), // Dark sage green
              const Color(0xFF5A7A4A), // Deeper sage
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            children: [
              // Recipe Image Upload Section
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.5),
                                  const Color(
                                    0xFF9CAF88,
                                  ).withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child:
                                _selectedImage != null ||
                                    (widget.recipe != null &&
                                        widget.recipe!.imageUrl != null &&
                                        widget.recipe!.imageUrl!.isNotEmpty &&
                                        !widget.recipe!.imageUrl!.startsWith(
                                          'http',
                                        ))
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      kIsWeb
                                          ? _buildPlaceholderImage()
                                          : Image.file(
                                              _selectedImage ??
                                                  File(
                                                    widget.recipe!.imageUrl!,
                                                  ),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return _buildPlaceholderImage();
                                                  },
                                            ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: _showImageSourceDialog,
                                          ),
                                        ),
                                      ),
                                      if (_selectedImage != null)
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red.withValues(
                                                    alpha: 0.9,
                                                  ),
                                                  Colors.red.withValues(
                                                    alpha: 0.7,
                                                  ),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedImage = null;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : _buildPlaceholderImage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Recipe title',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF87A96B),
                          width: 2.5,
                        ),
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF87A96B).withValues(alpha: 0.2),
                              const Color(0xFF6B8E5A).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF87A96B,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.title_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(
                        0xFF9CAF88,
                      ).withValues(alpha: 0.15),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Description
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Description',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF87A96B),
                          width: 2.5,
                        ),
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF87A96B).withValues(alpha: 0.2),
                              const Color(0xFF6B8E5A).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF87A96B,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(
                        0xFF9CAF88,
                      ).withValues(alpha: 0.15),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextFormField(
                    controller: _categoryController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Category',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF87A96B),
                          width: 2.5,
                        ),
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF87A96B).withValues(alpha: 0.2),
                              const Color(0xFF6B8E5A).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF87A96B,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.category_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(
                        0xFF9CAF88,
                      ).withValues(alpha: 0.15),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Time and Servings Row
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          controller: _prepTimeController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Prep',
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: 'min',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF87A96B),
                                width: 2.5,
                              ),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF87A96B,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF6B8E5A,
                                    ).withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.access_time_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFF9CAF88,
                            ).withValues(alpha: 0.15),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          controller: _cookTimeController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Cook',
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: 'min',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF87A96B),
                                width: 2.5,
                              ),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF87A96B,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF6B8E5A,
                                    ).withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.timer_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFF9CAF88,
                            ).withValues(alpha: 0.15),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          controller: _servingsController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Servings',
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: 'Servings',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF87A96B),
                                width: 2.5,
                              ),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF87A96B,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF6B8E5A,
                                    ).withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.people_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFF9CAF88,
                            ).withValues(alpha: 0.15),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) < 1) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Enhanced Ingredients Section
              GlassWidget(
                padding: const EdgeInsets.all(16),
                opacity: 0.35,
                color: const Color(0xFF9CAF88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF87A96B),
                                const Color(0xFF6B8E5A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF87A96B).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF87A96B),
                                const Color(0xFF6B8E5A),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF87A96B).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _addIngredientField,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._ingredientControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: TextFormField(
                                    controller: controller,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '${index + 1}',
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      hintText: 'Ingredient',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF87A96B),
                                          width: 2.5,
                                        ),
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF87A96B,
                                              ).withValues(alpha: 0.2),
                                              const Color(
                                                0xFF6B8E5A,
                                              ).withValues(alpha: 0.15),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF87A96B,
                                            ).withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: const Color(
                                        0xFF9CAF88,
                                      ).withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_ingredientControllers.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withValues(alpha: 0.3),
                                            Colors.red.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _removeIngredientField(index),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Enhanced Instructions Section
              GlassWidget(
                padding: const EdgeInsets.all(16),
                opacity: 0.35,
                color: const Color(0xFF9CAF88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6B8E5A),
                                const Color(0xFF95B77A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6B8E5A).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.list_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6B8E5A),
                                const Color(0xFF95B77A),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6B8E5A).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _addInstructionField,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._instructionControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF87A96B), // Sage green
                                      const Color(0xFF6B8E5A), // Dark sage
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF87A96B,
                                      ).withValues(alpha: 0.3), // Sage green
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: TextFormField(
                                    controller: controller,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '${index + 1}',
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      hintText: 'Step',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF87A96B),
                                          width: 2.5,
                                        ),
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF87A96B,
                                              ).withValues(alpha: 0.2),
                                              const Color(
                                                0xFF6B8E5A,
                                              ).withValues(alpha: 0.15),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF87A96B,
                                            ).withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: const Color(
                                        0xFF9CAF88,
                                      ).withValues(alpha: 0.15),
                                    ),
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                            ),
                            if (_instructionControllers.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withValues(alpha: 0.3),
                                            Colors.red.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _removeInstructionField(index),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Enhanced Save Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF87A96B),
                      const Color(0xFF6B8E5A),
                    ], // Sage green gradient
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                        0xFF87A96B,
                      ).withValues(alpha: 0.4), // Sage green
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9CAF88).withValues(alpha: 0.2),
            const Color(0xFF87A96B).withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF87A96B).withValues(alpha: 0.3),
                  const Color(0xFF6B8E5A).withValues(alpha: 0.25),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF87A96B).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
