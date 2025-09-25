import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/features/auth/services/notification_service.dart';
import 'package:chronic_illness_app/features/profile/screens/widgets/profile_widgets.dart';
import 'package:chronic_illness_app/features/profile/screens/widgets/profile_dialogs.dart';
import 'package:flutter/material.dart' hide showAboutDialog;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chronic_illness_app/config/routes.dart';
import 'package:chronic_illness_app/features/help/screens/help_center_screen.dart';
import 'package:chronic_illness_app/features/help/screens/feedback_screen.dart';
import 'package:chronic_illness_app/features/payment/screens/payment_screen.dart';
import 'package:chronic_illness_app/features/payment/services/mpesa_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:async';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  Future<List<Map<String, dynamic>>?>? _transactionFuture;
  String? _profileImageUrl;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.profileImageUrl != null) {
      _profileImageUrl = authProvider.user!.profileImageUrl;
    }
    _refreshTransactions();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshTransactions();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isRefreshing) {
        _refreshTransactions(silent: true);
      }
    });
  }

  void _refreshTransactions({bool silent = false}) {
    if (_isRefreshing && silent) return;

    setState(() {
      _isRefreshing = true;
      _transactionFuture = MpesaService.getAllTransactions();
    });

    Provider.of<AuthProvider>(context, listen: false).loadCurrentUser().then((
      _,
    ) {
      // Update profile image URL after user data is refreshed
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (mounted) {
        setState(() {
          _profileImageUrl = authProvider.user?.profileImageUrl;
        });
      }
    });

    if (!silent) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    } else {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF4CAF50),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await picker.pickImage(source: ImageSource.gallery),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF4CAF50),
                ),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await picker.pickImage(source: ImageSource.camera),
                  );
                },
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remove Image',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context, null);
                    _removeProfileImage();
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        String newImageUrl = await _uploadImageToServer(pickedFile);
        print('New image URL: $newImageUrl'); // Debug URL
        setState(() {
          _profileImageUrl = newImageUrl;
          imageCache.clear(); // Clear cache
          imageCache.clearLiveImages();
        });
        await authProvider.updateProfile(
          authProvider.user!.username,
          authProvider.user!.notificationsEnabled,
          profileImageUrl: newImageUrl,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile image updated'),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error uploading image: $e'); // Debug error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to update profile image'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  Future<String> _uploadImageToServer(XFile pickedFile) async {
    final cloudinary = CloudinaryPublic('dkatmm1c6', 'flutter_chronic', cache: false);
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(pickedFile.path,
            resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  void _removeProfileImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _profileImageUrl = null;
    });
    await authProvider.updateProfile(
      authProvider.user!.username,
      authProvider.user!.notificationsEnabled,
      profileImageUrl: null,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Profile image removed'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Update profile image URL when auth provider changes
        if (authProvider.user?.profileImageUrl != _profileImageUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _profileImageUrl = authProvider.user?.profileImageUrl;
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FFFE),
          body: authProvider.user == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 3,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _refreshTransactions();
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: const Color(0xFF4CAF50),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        elevation: 0,
                        actions: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditingProfile = !_isEditingProfile;
                              });
                            },
                            icon: Icon(
                              _isEditingProfile ? Icons.close : Icons.edit,
                              color: Colors.white,
                            ),
                            tooltip: _isEditingProfile
                                ? 'Cancel Edit'
                                : 'Edit Profile',
                          ),
                        ],
                        flexibleSpace: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: FlexibleSpaceBar(
                            centerTitle: true,
                            title: const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            background: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF81C784),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 40),
                                    Hero(
                                      tag: 'profile_avatar',
                                      child: buildAvatar(
                                        context,
                                        _profileImageUrl,
                                        _pickProfileImage,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      authProvider.user!.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                authProvider.user!.role ==
                                                    'premium'
                                                ? Colors.amber.withOpacity(0.2)
                                                : Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                authProvider.user!.role ==
                                                        'premium'
                                                    ? Icons.star
                                                    : Icons.person,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                authProvider.user!.role ==
                                                        'premium'
                                                    ? 'Premium User'
                                                    : 'Free User',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              buildProfileCard(
                                context,
                                title: 'Profile Information',
                                icon: Icons.person_outline,
                                child: _isEditingProfile
                                    ? buildEditProfileForm(
                                        context,
                                        authProvider,
                                        _isEditingProfile,
                                        () {
                                          setState(() {
                                            _isEditingProfile = false;
                                          });
                                        },
                                      )
                                    : buildProfileInfo(
                                        context,
                                        authProvider,
                                        () {
                                          setState(() {
                                            _isEditingProfile = true;
                                          });
                                        },
                                      ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileCard(
                                context,
                                title: 'Membership',
                                icon: Icons.star_outline,
                                child: Column(
                                  children: [
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.star,
                                      title:
                                          authProvider.user!.role == 'premium'
                                          ? 'Renew Premium'
                                          : 'Upgrade to Premium',
                                      subtitle:
                                          authProvider.user!.role == 'premium'
                                          ? 'Extend your premium access for another 30 days'
                                          : 'Unlock unlimited readings and reports for 30 days',
                                      onTap: () async {
                                        final result =
                                            await Navigator.pushNamed(
                                              context,
                                              PaymentScreen.routeName,
                                              arguments:
                                                  ProfileScreen.routeName,
                                            );
                                        if (result != null) {
                                          _refreshTransactions();
                                        }
                                      },
                                      trailing:
                                          authProvider.user!.role == 'premium'
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Active',
                                                    style: TextStyle(
                                                      color: Colors.amber,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileCard(
                                context,
                                title: 'Account Settings',
                                icon: Icons.settings_outlined,
                                child: Column(
                                  children: [
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.lock_outline,
                                      title: 'Change Password',
                                      subtitle:
                                          'Update your password for security',
                                      onTap: () => showChangePasswordDialog(
                                        context,
                                        authProvider,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.email_outlined,
                                      title: 'Email Address',
                                      subtitle:
                                          authProvider.user!.email ?? 'Not set',
                                      onTap: null,
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Verified',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.notifications_outlined,
                                      title: 'Notifications',
                                      subtitle:
                                          authProvider
                                              .user!
                                              .notificationsEnabled
                                          ? 'Enabled'
                                          : 'Disabled',
                                      onTap: () => showNotificationSettings(
                                        context,
                                        authProvider,
                                      ),
                                      trailing: Switch(
                                        value: authProvider
                                            .user!
                                            .notificationsEnabled,
                                        onChanged: (value) async {
                                          await authProvider.updateProfile(
                                            authProvider.user!.username,
                                            value,
                                          );
                                        },
                                        activeColor: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileCard(
                                context,
                                title: 'Payment History',
                                icon: Icons.payment_outlined,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Recent Transactions',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (_isRefreshing)
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFF4CAF50),
                                                    ),
                                              )
                                            else
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.refresh,
                                                  color: Color(0xFF4CAF50),
                                                ),
                                                onPressed: () =>
                                                    _refreshTransactions(),
                                                tooltip: 'Refresh transactions',
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Map<String, dynamic>>?>(
                                      future: _transactionFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF4CAF50),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Expanded(
                                                  child: Text(
                                                    'Error loading payment history',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      _refreshTransactions(),
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.receipt_long_outlined,
                                                  color: Colors.grey[400],
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'No payment history available',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Your transactions will appear here after making a payment',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        final transactions = snapshot.data!;
                                        transactions.sort((a, b) {
                                          final dateA =
                                              DateTime.tryParse(
                                                a['transactionDate'] ?? '',
                                              ) ??
                                              DateTime(1970);
                                          final dateB =
                                              DateTime.tryParse(
                                                b['transactionDate'] ?? '',
                                              ) ??
                                              DateTime(1970);
                                          return dateB.compareTo(dateA);
                                        });

                                        return Column(
                                          children: transactions.take(5).map((
                                            tx,
                                          ) {
                                            final date =
                                                tx['transactionDate'] != null
                                                ? DateFormat(
                                                    'MMM dd, yyyy HH:mm',
                                                  ).format(
                                                    DateTime.parse(
                                                      tx['transactionDate'],
                                                    ),
                                                  )
                                                : 'N/A';
                                            final amount =
                                                tx['amount']?.toString() ??
                                                'N/A';
                                            final status =
                                                tx['status']
                                                    ?.toString()
                                                    .toUpperCase() ??
                                                'PENDING';
                                            final isSuccess =
                                                status == 'COMPLETED' ||
                                                status == 'SUCCESS' ||
                                                status == 'CONFIRMED' ||
                                                status == 'SUCCESSFUL';
                                            final isPending =
                                                status == 'PENDING' ||
                                                status == 'PROCESSING' ||
                                                status == 'INITIATED';
                                            final receipt =
                                                tx['mpesaReceiptNumber']
                                                    ?.toString();

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: buildTransactionTile(
                                                context,
                                                amount: amount,
                                                date: date,
                                                status: status,
                                                isSuccess: isSuccess,
                                                isPending: isPending,
                                                receipt: receipt,
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileCard(
                                context,
                                title: 'Support & Help',
                                icon: Icons.help_outline,
                                child: Column(
                                  children: [
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.question_answer_outlined,
                                      title: 'Help Center',
                                      subtitle:
                                          'Get answers to common questions',
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          HelpCenterScreen.routeName,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.feedback_outlined,
                                      title: 'Send Feedback',
                                      subtitle: 'Help us improve the app',
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          FeedbackScreen.routeName,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    buildSettingsTile(
                                      context,
                                      icon: Icons.info_outline,
                                      title: 'About',
                                      subtitle: 'Version 1.0.0',
                                      onTap: () => showAboutDialog(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red[400]!,
                                      Colors.red[600]!,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () =>
                                        showLogoutDialog(context, authProvider),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout_outlined,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

extension LetExtension<T> on T {
  R let<R>(R Function(T) operation) => operation(this);
}