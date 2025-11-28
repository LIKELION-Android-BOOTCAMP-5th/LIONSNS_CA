import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/l10n/app_localizations.dart';
import 'package:lionsns/core/utils/result.dart';
import '../providers/providers.dart';
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNicknameInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = ref.read(profileEditViewModelProvider.notifier);
    viewModel.setNickname(_nicknameController.text);

    final result = await viewModel.saveProfile();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    result.when(
      success: (user) {
        ref.read(authViewModelProvider.notifier).refresh();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSaved)),
        );

        context.pop();
      },
      failure: (message, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileEditViewModelProvider);
    final viewModel = ref.read(profileEditViewModelProvider.notifier);

    if (!_isNicknameInitialized && mounted) {
      state.profileResult.when(
        success: (user) {
          if (user != null && user.name.isNotEmpty && _nicknameController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isNicknameInitialized) {
                _nicknameController.text = user.name;
                _isNicknameInitialized = true;
              }
            });
          }
        },
        failure: (_, __) {},
        pending: (_) {},
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileEdit),
          actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                l10n.save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    _buildProfileAvatar(
                      context,
                      selectedImage: state.selectedImage,
                      imageUrl: state.profileResult.when(
                        success: (user) => user?.profileImageUrl,
                        failure: (_, __) => null,
                        pending: (_) => null,
                      ),
                      radius: 60,
                      fallbackText: ((state.nickname?.isNotEmpty ?? false) ? state.nickname![0] : 'U').toUpperCase(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          onPressed: () => viewModel.pickImage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: l10n.nickname,
                  hintText: l10n.nicknameHint,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.nicknameErrorEmpty;
                  }
                  if (value.length > 20) {
                    return l10n.nicknameErrorLength;
                  }
                  return null;
                },
                onChanged: (value) {
                  viewModel.setNickname(value);
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: state.isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Text(l10n.save, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProfileAvatar(
    BuildContext context, {
    required File? selectedImage,
    required String? imageUrl,
    required double radius,
    required String fallbackText,
  }) {
    if (selectedImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        backgroundImage: FileImage(selectedImage),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Text(
          fallbackText,
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Icon(
                      Icons.person_outline,
                      size: radius * 1.2,
                      color: Colors.grey[400],
                    ),
                  ),
                  Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ],
              ),
            );
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  fallbackText,
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
