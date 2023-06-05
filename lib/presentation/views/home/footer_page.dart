import 'dart:math';

import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:yelwinoo/data/model/quote.dart';
import 'package:yelwinoo/presentation/configs/configs.dart';
import 'package:yelwinoo/presentation/utils/extensions/extensions.dart';
import 'package:yelwinoo/presentation/widgets/widgets.dart';

import 'widgets/footer_path.dart';

class FooterPage extends StatefulWidget {
  const FooterPage({Key? key}) : super(key: key);

  @override
  State<FooterPage> createState() => _FooterPageState();
}

class _FooterPageState extends State<FooterPage> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _labelController;
  late AnimationController _pathController;
  late Animation<double> _pathAnimation;
  final List<Interval> _itemSlideIntervals = [];
  int sectors = 5;
  double screenHeight = 0.0;
  double sectorHeight = 0.0;
  double quoteHeight = 0.0;
  double footerHeight = 0.0;
  double quotePadding = 0.0;
  Size quoteSize = Size.zero;
  Duration get staggeredDuration => duration100;
  Duration get itemSlideDuration => duration1000;
  Duration get labelDuration => duration1000;
  Duration get slideDuration =>
      staggeredDuration + (staggeredDuration * sectors) + itemSlideDuration;
  List<Color> get sectorColors => [
        _footerForegroundColor,
        _footerForegroundColor,
        _footerForegroundColor,
        kBlack,
        kBlack,
      ];
  Quote randomQuote = ksQuotes[Random().nextInt(ksQuotes.length)];
  String get quoteName => randomQuote.name.addDoubleQuote();
  int maxLines = 5;
  TextStyle? get quoteTextStyle =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          );
  final Color _footerForegroundColor = kSecondary;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    createStaggeredIntervals();
    screenHeight = context.screenHeight - context.percentHeight(s20);
    sectorHeight = screenHeight / sectors;
    quoteHeight = (context.screenHeight / sectors) * 3;
    quotePadding = context.screenWidth * 0.06;
    footerHeight = (context.screenHeight / sectors) * 2;
    _slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    )..forward();
    _labelController = AnimationController(
      duration: labelDuration,
      vsync: this,
    );
    _pathController = AnimationController(
      duration: duration2000,
      vsync: this,
    );
    _pathAnimation = CurvedAnimation(
      parent: _pathController,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _slideController.addListener(_slideControllerListener);
    quoteSize = quoteName.textSize(
      style: quoteTextStyle,
      maxWidth: context.screenWidth - quotePadding,
      maxLines: maxLines,
    );
  }

  void _slideControllerListener() {
    if (_slideController.isCompleted) {
      _labelController.forward();
      _pathController.forward();
    } else if (_slideController.isDismissed) {
      _labelController.reset();
      _pathController.reset();
    }
  }

  void createStaggeredIntervals() {
    for (int i = 0; i < sectors; i++) {
      final Duration start = staggeredDuration + (staggeredDuration * i);
      final Duration end = start + itemSlideDuration;
      _itemSlideIntervals.add(
        Interval(
          start.inMilliseconds / slideDuration.inMilliseconds,
          end.inMilliseconds / slideDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _labelController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Widget _sectorWidgets() {
    return <Widget>[
      ...List.generate(
        sectors,
        (index) => CustomSlider(
          width: context.screenWidth,
          height: sectorHeight,
          color: sectorColors[index],
          animation: _slideController.view,
          interval: _itemSlideIntervals[index],
        ).addExpanded(),
      ),
    ].addColumn(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _quoteSection() {
    return <Widget>[
      AnimatedTextSlideBoxTransition(
        controller: _labelController,
        coverColor: _footerForegroundColor,
        text: quoteName,
        width: context.screenWidth - quotePadding,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        textStyle: quoteTextStyle,
      ),
      verticalSpaceLarge,
      <Widget>[
        const Spacer(),
        AnimatedTextSlideBoxTransition(
          controller: _labelController,
          coverColor: _footerForegroundColor,
          width: quoteSize.width + s50,
          text: "— ${randomQuote.author}",
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
        ),
        horizontalSpaceEnormous,
      ].addRow(
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    ]
        .addColumn(
          mainAxisAlignment: MainAxisAlignment.center,
        )
        .addContainer(
          height: quoteHeight,
          width: context.screenWidth,
          margin: context.symmetricPadding(h: quotePadding / 2),
        );
  }

  Widget _footerWelcomePart() {
    return <Widget>[
      Text(
        ksLetsWork,
        style: context.titleLarge.copyWith(
          color: _footerForegroundColor,
        ),
      ),
      verticalSpaceMassive,
      Text(
        ksFreelanceAvailability,
        style: context.titleSmall.copyWith(
          color: _footerForegroundColor,
        ),
      ),
    ].addColumn(
      mainAxisSize: MainAxisSize.min,
    );
  }

  Widget _footerAnimatedPath() {
    return FooterPath(
      color: _footerForegroundColor,
      animation: _pathAnimation,
    )
        .addSizedBox(
          height: footerHeight,
        )
        .addPadding(
          edgeInsets: context.symmetricPadding(
            h: s20,
          ),
        )
        .addExpanded();
  }

  Widget _footerSocialAndCreditPart() {
    return <Widget>[
      const Spacer(),
      Text(
        ksContactInfo,
        style: context.bodyLarge.copyWith(
          color: _footerForegroundColor,
        ),
      ),
      <Widget>[
        Icon(
          Atlas.mailbox,
          color: _footerForegroundColor,
          size: s18,
        ),
        horizontalSpaceMedium,
        Text(
          ksWorkEmail,
          style: context.bodyMedium.copyWith(
            color: _footerForegroundColor,
          ),
        ),
      ].addRow().addInkWell(
            onTap: ksWorkEmail.launchEmail,
          ),
      <Widget>[
        Icon(
          Atlas.office_phone,
          color: _footerForegroundColor,
          size: s18,
        ),
        horizontalSpaceMedium,
        Text(
          ksWorkPhone,
          style: context.bodyMedium.copyWith(
            color: kSecondary,
          ),
        ),
      ].addRow(),
      verticalSpaceMedium,
      <Widget>[
        ...ksSocialMedia.map((media) {
          return IconButton(
            onPressed: media.link.launchWebsite,
            icon: media.icon,
          );
        }).toList()
      ].addRow(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      const Spacer(),
      Text(
        ksCreditTo,
        style: context.bodyMedium.copyWith(
          color: _footerForegroundColor,
        ),
      ),
      <Widget>[
        <Widget>[
          horizontalSpaceMassive,
          Icon(
            Atlas.star_trophy_achievement,
            color: _footerForegroundColor,
            size: s14,
          ),
          horizontalSpaceMedium,
          Text(
            ksDavidCobbina,
            style: context.bodyMedium.copyWith(
              color: _footerForegroundColor,
              decorationStyle: TextDecorationStyle.dotted,
              decoration: TextDecoration.underline,
              decorationColor: _footerForegroundColor,
              decorationThickness: s4,
            ),
          ),
        ].addRow().addInkWell(
              onTap: ksDavidCobbinaWebsite.launchWebsite,
            ),
        <Widget>[
          horizontalSpaceMassive,
          Icon(
            Atlas.star_trophy_achievement,
            color: _footerForegroundColor,
            size: s14,
          ),
          horizontalSpaceMedium,
          Text(
            ksJuliusG,
            style: context.bodyMedium.copyWith(
              color: _footerForegroundColor,
              decorationStyle: TextDecorationStyle.dotted,
              decoration: TextDecoration.underline,
              decorationColor: _footerForegroundColor,
              decorationThickness: s4,
            ),
          ),
        ].addRow().addInkWell(
              onTap: ksJuliusGWebsite.launchWebsite,
            ),
      ].addColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ].addColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _madeWithFlutterLabel() {
    return <Widget>[
      Text(
        ksBuildUsing,
        style: context.bodyMedium.copyWith(
          color: _footerForegroundColor,
        ),
      ),
      const FlutterLogo(size: 14),
      Text(
        ksWithMuch,
        style: context.bodyMedium.copyWith(
          color: _footerForegroundColor,
        ),
      ),
      const Icon(
        Atlas.heart_arrow_bold,
        color: kRed,
      ),
    ].addRow(
      mainAxisSize: MainAxisSize.min,
    );
  }

  Widget _ccLabel() {
    return Text(
      ksCC,
      style: context.bodyMedium.copyWith(
        color: _footerForegroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return <Widget>[
      _sectorWidgets(),
      <Widget>[
        _quoteSection(),
        <Widget>[
          <Widget>[
            _footerWelcomePart(),
            _footerAnimatedPath(),
            _footerSocialAndCreditPart(),
          ].addRow().addExpanded(),
          _madeWithFlutterLabel(),
          verticalSpaceMedium,
          _ccLabel(),
          verticalSpaceLarge,
        ].addColumn().addContainer(
              height: footerHeight,
              width: context.screenWidth,
              padding: context.symmetricPadding(h: s80),
            ),
      ].addColumn(),
    ].addStack().addSizedBox();
  }
}