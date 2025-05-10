import 'package:flutter/material.dart';

const double _singleLineVerticalPadding = 14.0;
const Duration _snackBarTransitionDuration = Duration(milliseconds: 250);
const Duration _snackBarDisplayDuration = Duration(hours: 1);
const Curve _snackBarHeightCurve = Curves.fastOutSlowIn;
const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;

const Curve _snackBarFadeInCurve = Interval(0.4, 1.0);
const Curve _snackBarM3FadeInCurve = Interval(
  0.4,
  0.6,
  curve: Curves.easeInCirc,
);
const Curve _snackBarFadeOutCurve = Interval(
  0.72,
  1.0,
  curve: Curves.fastOutSlowIn,
);

class GlueSnackBarWidget extends SnackBar {
  const GlueSnackBarWidget({
    required super.key,
    required super.content,
    super.backgroundColor,
    super.elevation,
    super.margin,
    super.padding,
    super.width,
    super.shape,
    super.hitTestBehavior,
    super.behavior,
    super.action,
    super.actionOverflowThreshold,
    super.showCloseIcon,
    super.closeIconColor,
    super.duration = _snackBarDisplayDuration,
    super.animation,
    super.onVisible,
    super.dismissDirection,
    super.clipBehavior = Clip.hardEdge,
    required this.hideCallback,
    this.dismissOnBack = false,
    this.dismissOnTapOutside = false,
  });

  final VoidCallback hideCallback;

  final bool dismissOnBack;
  final bool dismissOnTapOutside;

  static AnimationController createAnimationController({
    required TickerProvider vsync,
    Duration? duration,
    Duration? reverseDuration,
  }) {
    return AnimationController(
      duration: duration ?? _snackBarTransitionDuration,
      reverseDuration: reverseDuration,
      debugLabel: 'SnackBar',
      vsync: vsync,
    );
  }

  @override
  GlueSnackBarWidget withAnimation(
    Animation<double> newAnimation, {
    Key? fallbackKey,
  }) {
    return GlueSnackBarWidget(
      key: key ?? fallbackKey,
      content: content,
      hideCallback: hideCallback,
      backgroundColor: backgroundColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      width: width,
      shape: shape,
      hitTestBehavior: hitTestBehavior,
      behavior: behavior,
      action: action,
      actionOverflowThreshold: actionOverflowThreshold,
      showCloseIcon: showCloseIcon,
      closeIconColor: closeIconColor,
      animation: newAnimation,
      onVisible: onVisible,
      dismissDirection: dismissDirection,
      clipBehavior: clipBehavior,
      dismissOnBack: dismissOnBack,
      dismissOnTapOutside: dismissOnTapOutside,
    );
  }

  @override
  State<GlueSnackBarWidget> createState() => _GlueSnackBarWidgetState();
}

class _GlueSnackBarWidgetState extends State<GlueSnackBarWidget> {
  bool _wasVisible = false;

  CurvedAnimation? _heightAnimation;
  CurvedAnimation? _fadeInAnimation;
  CurvedAnimation? _fadeInM3Animation;
  CurvedAnimation? _fadeOutAnimation;
  CurvedAnimation? _heightM3Animation;

  @override
  void initState() {
    super.initState();
    widget.animation!.addStatusListener(_onAnimationStatusChanged);
    _setAnimations();
  }

  @override
  void didUpdateWidget(GlueSnackBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation!.removeStatusListener(_onAnimationStatusChanged);
      widget.animation!.addStatusListener(_onAnimationStatusChanged);
      _disposeAnimations();
      _setAnimations();
    }
  }

  void _setAnimations() {
    assert(widget.animation != null);
    _heightAnimation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarHeightCurve,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarFadeInCurve,
    );
    _fadeInM3Animation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarM3FadeInCurve,
    );
    _fadeOutAnimation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarFadeOutCurve,
      reverseCurve: const Threshold(0.0),
    );
    _heightM3Animation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarM3HeightCurve,
      reverseCurve: const Threshold(0.0),
    );
  }

  void _disposeAnimations() {
    _heightAnimation?.dispose();
    _fadeInAnimation?.dispose();
    _fadeInM3Animation?.dispose();
    _fadeOutAnimation?.dispose();
    _heightM3Animation?.dispose();
    _heightAnimation = null;
    _fadeInAnimation = null;
    _fadeInM3Animation = null;
    _fadeOutAnimation = null;
    _heightM3Animation = null;
  }

  @override
  void dispose() {
    widget.animation!.removeStatusListener(_onAnimationStatusChanged);
    _disposeAnimations();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus animationStatus) {
    if (animationStatus.isCompleted) {
      if (widget.onVisible != null && !_wasVisible) {
        widget.onVisible!();
      }
      _wasVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool accessibleNavigation = MediaQuery.accessibleNavigationOf(
      context,
    );
    assert(widget.animation != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    final bool isThemeDark = theme.brightness == Brightness.dark;
    final Color buttonColor =
        isThemeDark ? colorScheme.primary : colorScheme.secondary;
    final SnackBarThemeData defaults =
        theme.useMaterial3
            ? _SnackBarDefaultsM3(context)
            : _SnackBarDefaultsM2(context);

    final Brightness brightness =
        isThemeDark ? Brightness.light : Brightness.dark;

    final ThemeData effectiveTheme =
        theme.useMaterial3
            ? theme
            : theme.copyWith(
              colorScheme: ColorScheme(
                primary: colorScheme.onPrimary,
                secondary: buttonColor,
                surface: colorScheme.onSurface,
                error: colorScheme.onError,
                onPrimary: colorScheme.primary,
                onSecondary: colorScheme.secondary,
                onSurface: colorScheme.surface,
                onError: colorScheme.error,
                brightness: brightness,
              ),
            );

    final TextStyle? contentTextStyle =
        snackBarTheme.contentTextStyle ?? defaults.contentTextStyle;
    final SnackBarBehavior snackBarBehavior =
        widget.behavior ?? snackBarTheme.behavior ?? defaults.behavior!;
    final double? width = widget.width ?? snackBarTheme.width;

    final bool showCloseIcon =
        widget.showCloseIcon ??
        snackBarTheme.showCloseIcon ??
        defaults.showCloseIcon!;

    final bool isFloatingSnackBar =
        snackBarBehavior == SnackBarBehavior.floating;
    final double horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    final EdgeInsetsGeometry padding =
        widget.padding ??
        EdgeInsetsDirectional.only(
          start: horizontalPadding,
          end: widget.action != null || showCloseIcon ? 0 : horizontalPadding,
        );

    final double actionHorizontalMargin =
        (widget.padding?.resolve(TextDirection.ltr).right ??
            horizontalPadding) /
        2;
    final double iconHorizontalMargin =
        (widget.padding?.resolve(TextDirection.ltr).right ??
            horizontalPadding) /
        12.0;

    final IconButton? iconButton =
        showCloseIcon
            ? IconButton(
              key: StandardComponentType.closeButton.key,
              icon: const Icon(Icons.close),
              iconSize: 24.0,
              color:
                  widget.closeIconColor ??
                  snackBarTheme.closeIconColor ??
                  defaults.closeIconColor,
              onPressed:
                  () => ScaffoldMessenger.of(
                    context,
                  ).hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            )
            : null;

    final TextPainter actionTextPainter = TextPainter(
      text: TextSpan(
        text: widget.action?.label ?? '',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final double actionAndIconWidth =
        actionTextPainter.size.width +
        (widget.action != null ? actionHorizontalMargin : 0) +
        (showCloseIcon
            ? (iconButton?.iconSize ?? 0 + iconHorizontalMargin)
            : 0);
    actionTextPainter.dispose();

    final EdgeInsets margin =
        widget.margin?.resolve(TextDirection.ltr) ??
        snackBarTheme.insetPadding ??
        defaults.insetPadding!;

    final double snackBarWidth =
        widget.width ??
        MediaQuery.sizeOf(context).width - (margin.left + margin.right);
    final double actionOverflowThreshold =
        widget.actionOverflowThreshold ??
        snackBarTheme.actionOverflowThreshold ??
        defaults.actionOverflowThreshold!;

    final bool willOverflowAction =
        actionAndIconWidth / snackBarWidth > actionOverflowThreshold;

    final List<Widget> maybeActionAndIcon = <Widget>[
      if (widget.action != null)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: actionHorizontalMargin),
          child: TextButtonTheme(
            data: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: buttonColor,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              ),
            ),
            child: widget.action!,
          ),
        ),
      if (showCloseIcon)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: iconHorizontalMargin),
          child: iconButton,
        ),
    ];

    Widget snackBar = Padding(
      padding: padding,
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      widget.padding == null
                          ? const EdgeInsets.symmetric(
                            vertical: _singleLineVerticalPadding,
                          )
                          : EdgeInsets.zero,
                  child: DefaultTextStyle(
                    style: contentTextStyle!,
                    child: GestureDetector(onTap: () {}, child: widget.content),
                  ),
                ),
              ),
              if (!willOverflowAction) ...maybeActionAndIcon,
              if (willOverflowAction) SizedBox(width: snackBarWidth * 0.4),
            ],
          ),
          if (willOverflowAction)
            Padding(
              padding: const EdgeInsets.only(
                bottom: _singleLineVerticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: maybeActionAndIcon,
              ),
            ),
        ],
      ),
    );

    if (!isFloatingSnackBar) {
      snackBar = Center(child: snackBar);
    }

    final double elevation =
        widget.elevation ?? snackBarTheme.elevation ?? defaults.elevation!;
    final Color backgroundColor =
        widget.backgroundColor ??
        snackBarTheme.backgroundColor ??
        defaults.backgroundColor!;
    final ShapeBorder? shape =
        widget.shape ??
        snackBarTheme.shape ??
        (isFloatingSnackBar ? defaults.shape : null);
    //todo: final DismissDirection dismissDirection = widget.dismissDirection ?? snackBarTheme.dismissDirection ?? DismissDirection.down;

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor.withValues(alpha: elevation / 10),
      clipBehavior: widget.clipBehavior,
      child: Theme(
        data: effectiveTheme,
        child:
            accessibleNavigation || theme.useMaterial3
                ? snackBar
                : FadeTransition(opacity: _fadeOutAnimation!, child: snackBar),
      ),
    );

    if (isFloatingSnackBar) {
      if (width != null) {
        snackBar = Padding(
          padding: margin,
          child: SizedBox(width: width, child: snackBar),
        );
      } else {
        snackBar = Padding(padding: margin, child: snackBar);
      }
      snackBar = SafeArea(top: false, bottom: false, child: snackBar);
    }

    snackBar = Padding(
      padding: margin,
      child: Semantics(
        container: true,
        liveRegion: true,
        onDismiss: () {
          ScaffoldMessenger.of(
            context,
          ).removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
        },
        child: snackBar,
      ),
    );

    final Widget snackBarTransition;
    if (accessibleNavigation) {
      snackBarTransition = snackBar;
    } else if (isFloatingSnackBar && !theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: _fadeInAnimation!,
        child: snackBar,
      );
    } else if (isFloatingSnackBar && theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: _fadeInM3Animation!,
        child: ValueListenableBuilder<double>(
          valueListenable: _heightM3Animation!,
          builder: (BuildContext context, double value, Widget? child) {
            return Align(
              alignment: Alignment.bottomLeft,
              heightFactor: value,
              child: child,
            );
          },
          child: snackBar,
        ),
      );
    } else {
      snackBarTransition = snackBar;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.dismissOnBack) {
          widget.hideCallback.call();
        }
      },
      child: GestureDetector(
        onTap: widget.dismissOnTapOutside ? widget.hideCallback : null,
        child: Hero(
          tag: '<SnackBar Hero tag - ${widget.content}>',
          transitionOnUserGestures: true,
          child: ClipRect(
            clipBehavior: widget.clipBehavior,
            child: snackBarTransition,
          ),
        ),
      ),
    );
  }
}

class _SnackBarDefaultsM2 extends SnackBarThemeData {
  _SnackBarDefaultsM2(BuildContext context)
    : _theme = Theme.of(context),
      _colors = Theme.of(context).colorScheme,
      super(elevation: 6.0);

  late final ThemeData _theme;
  late final ColorScheme _colors;

  @override
  Color get backgroundColor =>
      _theme.brightness == Brightness.light
          ? Color.alphaBlend(
            _colors.onSurface.withValues(alpha: 0.80),
            _colors.surface,
          )
          : _colors.onSurface;

  @override
  TextStyle? get contentTextStyle =>
      ThemeData(
        useMaterial3: _theme.useMaterial3,
        brightness:
            _theme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ).textTheme.titleMedium;

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  Color get actionTextColor => _colors.secondary;

  @override
  Color get disabledActionTextColor => _colors.onSurface.withValues(
    alpha: _theme.brightness == Brightness.light ? 0.38 : 0.3,
  );

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  );

  @override
  EdgeInsets get insetPadding =>
      const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color get closeIconColor => _colors.onSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}

class _SnackBarDefaultsM3 extends SnackBarThemeData {
  _SnackBarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => _colors.inverseSurface;

  @override
  Color get actionTextColor =>
      WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.inversePrimary;
        }
        return _colors.inversePrimary;
      });

  @override
  Color get disabledActionTextColor => _colors.inversePrimary;

  @override
  TextStyle get contentTextStyle => Theme.of(
    context,
  ).textTheme.bodyMedium!.copyWith(color: _colors.onInverseSurface);

  @override
  double get elevation => 6.0;

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  );

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  EdgeInsets get insetPadding =>
      const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color? get closeIconColor => _colors.onInverseSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}
