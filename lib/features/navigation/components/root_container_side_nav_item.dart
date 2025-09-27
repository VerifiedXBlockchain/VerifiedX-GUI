import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/pretty_icons.dart';
import '../root_container.dart';

class RootContainerSideNavItem extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isExpanded;
  final PrettyIconType iconType;
  final IconData? icon;
  final Color? textColorOverrideIdle;
  final Color? textColorOverrideActive;
  final Color? textColorOverrideHover;
  final Widget? customIconWidget;
  final bool isNew;
  const RootContainerSideNavItem({
    super.key,
    required this.title,
    required this.onPressed,
    required this.isActive,
    required this.isExpanded,
    required this.iconType,
    this.icon,
    this.textColorOverrideIdle,
    this.textColorOverrideActive,
    this.textColorOverrideHover,
    this.customIconWidget,
    this.isNew = false,
  });

  @override
  State<RootContainerSideNavItem> createState() =>
      _RootContainerSideNavItemState();
}

class _RootContainerSideNavItemState extends State<RootContainerSideNavItem> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: ROOT_CONTAINER_TRANSITION_DURATION,
          decoration: BoxDecoration(
              color: widget.isActive ? AppColors.getBlue() : Colors.white30),
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: AnimatedContainer(
              duration: ROOT_CONTAINER_TRANSITION_DURATION,
              decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.getGray(ColorShade.s50)
                      : isHovering
                          ? AppColors.getGray(ColorShade.s100)
                          : AppColors.getGray(ColorShade.s200),
                  border: Border(
                    top: BorderSide(
                      color: widget.isActive
                          ? AppColors.getBlue().withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    bottom: BorderSide(
                      color: widget.isActive
                          ? AppColors.getBlue().withOpacity(0.05)
                          : Colors.transparent,
                    ),
                  )),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: ROOT_CONTAINER_TRANSITION_DURATION,
                    decoration: BoxDecoration(
                      color: AppColors.getIndigo(),
                    ),
                    width: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 6),
                    child: Tooltip(
                        message: widget.isExpanded ? "" : widget.title,
                        child: PrettyIcon(
                          customIcon: widget.icon,
                          type: widget.iconType,
                          glow: isHovering || widget.isActive,
                          customIconWidget: widget.customIconWidget,
                        )),
                  ),
                  Flexible(
                    child: AnimatedOpacity(
                      duration: ROOT_CONTAINER_TRANSITION_DURATION,
                      opacity: widget.isExpanded ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 15,
                                color: widget.isActive
                                    ? widget.textColorOverrideActive ??
                                        AppColors.getBlue(ColorShade.s100)
                                    : isHovering
                                        ? widget.textColorOverrideHover ??
                                            AppColors.getWhite(ColorShade.s200)
                                        : widget.textColorOverrideIdle ??
                                            AppColors.getWhite(ColorShade.s400)
                                                .withOpacity(0.9),
                              ),
                            ),
                            if (widget.isNew)
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 4,
                                        )
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 1),
                                    child: Transform.translate(
                                      offset: Offset(0, 1),
                                      child: Text(
                                        "NEW",
                                        style: TextStyle(
                                          fontSize: 10,
                                          height: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
