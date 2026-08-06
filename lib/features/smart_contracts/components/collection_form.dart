import 'package:flutter/material.dart';
import 'sc_creator/common/file_selector.dart';
import '../../../l10n/generated/app_localizations.dart';

class CollectionForm extends StatelessWidget {
  const CollectionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(label: Text(l10n.scwCollectionName)),
              ),
            ),
            Expanded(
              child: FileSelector(
                transparentBackground: true,
                title: l10n.scwCollectionThumbnail,
                onChange: (val) {},
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: InputDecoration(
            label: Text(l10n.scwCollectionDescription),
          ),
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
    );
  }
}
