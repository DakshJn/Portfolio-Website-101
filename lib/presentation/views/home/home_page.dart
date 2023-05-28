import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yelwinoo/presentation/utils/extensions/extensions.dart';
import 'package:yelwinoo/presentation/views/menu/menu_page.dart';
import 'package:yelwinoo/presentation/widgets/widgets.dart';

import '../../configs/configs.dart';
import 'introduction_page.dart';
import 'second_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scrollController = PageController();
  final _key = GlobalKey();
  int page = 0;
  final int pageLength = 2;
  late double _screenHeight;
  bool _isDrawerOpen = false;
  late AnimationController _animationController;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController = AnimationController(
      vsync: this,
      duration: duration1000,
    );
    _screenHeight = context.screenHeight;
  }

  void _handleScroll(Offset delta) {
    if (delta.dy > s50 && page < pageLength) {
      page++;
    } else {
      page--;
    }
    _animateToPage();
  }

  void _animateToPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(page * _screenHeight,
          duration: duration1000, curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onMenuTapped() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    if (_isDrawerOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Logo(),
        actions: [
          MenuButton(
            onPressed: onMenuTapped,
            hasMenuTapped: _isDrawerOpen,
          ),
        ],
      ),
      body: Stack(
        children: [
          Listener(
            onPointerSignal: (PointerSignalEvent event) {
              if (event is PointerScrollEvent) {
                _handleScroll(event.scrollDelta);
              }
            },
            child: PageView(
              key: _key,
              physics: const ClampingScrollPhysics(),
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              children: const [
                IntroductionPage(),
                SecondPage(),
                // CustomPageSlider()
              ],
            ),
          ),
          MenuPage(
            animation: _animationController.view,
          ),
        ],
      ),
    );
  }
}
