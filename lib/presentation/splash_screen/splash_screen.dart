import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitializing = true;
  double _initializationProgress = 0.0;
  String _currentTask = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Loading progress animation
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Start loading animation
      _loadingAnimationController.repeat();

      // Task 1: Load user preferences
      await _updateProgress(0.2, 'Loading preferences...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Task 2: Initialize weather API connections
      await _updateProgress(0.4, 'Connecting to weather services...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Task 3: Prepare cached conversion data
      await _updateProgress(0.6, 'Preparing conversion data...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Task 4: Detect IP-based location
      await _updateProgress(0.8, 'Detecting location...');
      await Future.delayed(const Duration(milliseconds: 700));

      // Task 5: Final setup
      await _updateProgress(1.0, 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Stop loading animation
      _loadingAnimationController.stop();

      // Navigate to home dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home-dashboard');
      }
    } catch (e) {
      // Handle initialization errors gracefully
      _handleInitializationError();
    }
  }

  Future<void> _updateProgress(double progress, String task) async {
    if (mounted) {
      setState(() {
        _initializationProgress = progress;
        _currentTask = task;
      });
    }
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _currentTask = 'Connection timeout. Tap to retry.';
      });
      _loadingAnimationController.stop();
    }
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _initializationProgress = 0.0;
      _currentTask = 'Retrying...';
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.surface,
              AppTheme.accentColor.withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // Logo section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: _buildLogo(),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // Loading section
              _buildLoadingSection(),

              // Spacer to balance layout
              const Spacer(flex: 3),

              // Footer section
              _buildFooter(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // App icon/logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'schedule',
              color: Colors.white,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App name
        Text(
          'Chronox',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.primaryColor,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 1.h),

        // App tagline
        Text(
          'Your Ultimate Utility Companion',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Loading indicator
        SizedBox(
          width: 60.w,
          height: 0.8.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1.h),
            child: LinearProgressIndicator(
              value: _isInitializing ? _initializationProgress : null,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.primaryColor,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Loading text
        GestureDetector(
          onTap: !_isInitializing ? _retryInitialization : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInitializing) ...[
                  SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: AnimatedBuilder(
                      animation: _loadingAnimationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle:
                              _loadingAnimationController.value * 2 * 3.14159,
                          child: CustomIconWidget(
                            iconName: 'refresh',
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 4.w,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                ] else ...[
                  CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.accentColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                ],
                Flexible(
                  child: Text(
                    _currentTask,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          !_isInitializing
                              ? AppTheme.accentColor
                              : AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                      fontWeight:
                          !_isInitializing ? FontWeight.w500 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Version info
        Text(
          'Version 1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.6,
            ),
            fontSize: 10.sp,
          ),
        ),

        SizedBox(height: 1.h),

        // Copyright
        Text(
          '© 2025 Chronox. All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.5,
            ),
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
