import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_folder.dart';
import '../state/library_controller.dart';
import '../state/settings_controller.dart';

Future<void> showSortSheet(BuildContext context) async {
  final settings = context.read<SettingsController>();
  final library = context.read<LibraryController>();
  final selected = await showModalBottomSheet<SongSortOption>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Consumer<SettingsController>(
          builder: (context, s, _) {
            return RadioGroup<SongSortOption>(
              groupValue: s.sortOption,
              onChanged: (value) {
                if (value != null) Navigator.of(sheetContext).pop(value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'SORT SONGS',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  for (final option in SongSortOption.all)
                    RadioListTile<SongSortOption>(
                      value: option,
                      title: Text(option.label),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (selected != null) {
    await settings.setSortOption(selected);
    library.setSortOption(selected);
  }
}
