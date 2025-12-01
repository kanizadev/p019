import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/theme.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAddress;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialAddress,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static final RegExp _emailRegExp =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
  static final RegExp _phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{7,}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final List<TextEditingController> _controllers;

  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _addressFocus;

  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
    _controllers = [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
    ];
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();

    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasChanges =
        _nameController.text.trim() != widget.initialName.trim() ||
            _emailController.text.trim() != widget.initialEmail.trim() ||
            _phoneController.text.trim() != widget.initialPhone.trim() ||
            _addressController.text.trim() != widget.initialAddress.trim();

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<bool> _handleWillPop() async {
    if (!_hasChanges || _isSaving) {
      return true;
    }
    return _confirmDiscardChanges();
  }

  Future<bool> _confirmDiscardChanges() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved updates. Leaving now will discard them.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
    return shouldDiscard ?? false;
  }

  Future<void> _handleCancel() async {
    if (_isSaving) return;
    final shouldLeave = !_hasChanges || await _confirmDiscardChanges();
    if (!mounted) return;
    if (shouldLeave) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
    }
  }

  Future<void> _resetToInitialValues() async {
    FocusScope.of(context).unfocus();
    _nameController.text = widget.initialName;
    _emailController.text = widget.initialEmail;
    _phoneController.text = widget.initialPhone;
    _addressController.text = widget.initialAddress;
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final updated = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    await prefs.setString('userName', updated['name']!);
    await prefs.setString('userEmail', updated['email']!);
    await prefs.setString('userPhone', updated['phone']!);
    await prefs.setString('userAddress', updated['address']!);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: !_hasChanges || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _handleWillPop();
        if (!context.mounted) return;
        if (shouldPop) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: (!_hasChanges || _isSaving) ? null : _saveProfile,
                style: ButtonStyle(
                  foregroundColor:
                      WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.white60;
                    }
                    return Colors.white;
                  }),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSaving
                          ? SizedBox(
                              key: const ValueKey('spinner'),
                              width: 16,
                              height: 16,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                              key: ValueKey('check'),
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: _isSaving
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                )
              : null,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surface,
                AppTheme.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSummary(colorScheme, textTheme),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          context,
                          'Contact details',
                          Icons.contacts_outlined,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.textDark.withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildField(
                                label: 'Full name',
                                hint: 'e.g. Sarah Johnson',
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length < 2) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                icon: Icons.person_outline,
                                focusNode: _nameFocus,
                                nextFocus: _emailFocus,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                autofillHints: const [AutofillHints.name],
                              ),
                              const SizedBox(height: 18),
                              _buildField(
                                label: 'Email address',
                                hint: 'you@example.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!_emailRegExp.hasMatch(trimmed)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                icon: Icons.alternate_email,
                                focusNode: _emailFocus,
                                nextFocus: _phoneFocus,
                                inputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 18),
                              _buildField(
                                label: 'Phone number',
                                hint: '+1 555 555 5555',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (!_phoneRegExp.hasMatch(trimmed)) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                                icon: Icons.phone_outlined,
                                focusNode: _phoneFocus,
                                nextFocus: _addressFocus,
                                inputAction: TextInputAction.next,
                                helperText:
                                    'Include country code for seamless delivery updates.',
                                autofillHints: const [AutofillHints.telephoneNumber],
                              ),
                              const SizedBox(height: 18),
                              _buildField(
                                label: 'Delivery address',
                                hint: 'Street, city, ZIP / postal code',
                                controller: _addressController,
                                keyboardType: TextInputType.streetAddress,
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  if (trimmed.length < 8) {
                                    return 'Address looks too short';
                                  }
                                  return null;
                                },
                                icon: Icons.location_on_outlined,
                                focusNode: _addressFocus,
                                inputAction: TextInputAction.done,
                                maxLines: 3,
                                minLines: 2,
                                capitalization: TextCapitalization.sentences,
                                helperText:
                                    'Add apartment or suite details to avoid delivery delays.',
                                autofillHints: const [
                                  AutofillHints.streetAddressLine1,
                                  AutofillHints.streetAddressLine2,
                                  AutofillHints.postalCode,
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _hasChanges
                              ? Container(
                                  key: const ValueKey('unsaved-tip'),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.surface.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: colorScheme.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'You have unsaved changes. Tap Save in the top right when you\'re ready.',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textDark
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('no-unsaved-tip'),
                                ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed:
                              (!_hasChanges || _isSaving) ? null : _resetToInitialValues,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset to saved info'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _handleCancel,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textDark,
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, nameValue, _) {
        final displayName =
            nameValue.text.trim().isEmpty ? 'Your name' : nameValue.text.trim();
        final initials = _initials(displayName);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textDark.withValues(alpha: 0.05),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
                child: Text(
                  initials,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _emailController,
                  builder: (context, emailValue, __) {
                    final email = emailValue.text.trim().isEmpty
                        ? 'Add an email address'
                        : emailValue.text.trim();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(colorScheme, textTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme, TextTheme textTheme) {
    final label = _hasChanges ? 'Unsaved changes' : 'All up to date';
    final badgeColor = _hasChanges
        ? colorScheme.primary.withValues(alpha: 0.16)
        : AppTheme.surface.withValues(alpha: 0.9);
    final borderColor = _hasChanges
        ? colorScheme.primary.withValues(alpha: 0.4)
        : AppTheme.surface.withValues(alpha: 0.6);
    final textColor = _hasChanges
        ? colorScheme.primary
        : AppTheme.textDark.withValues(alpha: 0.6);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? inputAction,
    Iterable<String>? autofillHints,
    IconData? icon,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
    int? minLines,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction:
          inputAction ?? (maxLines > 1 ? TextInputAction.newline : TextInputAction.done),
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      autofillHints: autofillHints,
      maxLines: maxLines,
      minLines: minLines,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      validator: validator,
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    final firstChar = first.isNotEmpty ? first[0] : '';
    final secondChar = last.isNotEmpty ? last[0] : '';
    final initials = (firstChar + secondChar).toUpperCase();
    return initials.isEmpty ? firstChar.toUpperCase() : initials;
  }
}
