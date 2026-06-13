import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SearchFilterSheet extends StatefulWidget {
  final List<String> options;
  final Set<String> initialSelected;
  final String title;
  final String fieldPlaceholder;
  final String sectionTitle;
  final String applyLabel;

  const SearchFilterSheet({
    super.key,
    this.options = const [
      '서울숲',
      '성수',
      '명동',
      '경복궁',
      '롯데월드',
      '남산타워',
      '한강공원',
      '북촌한옥마을',
      '동대문디자인플라자',
      '광화문광장',
    ],
    this.initialSelected = const {},
    this.title = 'Filter',
    this.fieldPlaceholder = '서울 관광지를 선택하세요',
    this.sectionTitle = 'Seoul Landmarks',
    this.applyLabel = 'Apply',
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late final Set<String> _selectedPlaces;

  @override
  void initState() {
    super.initState();
    _selectedPlaces = {...widget.initialSelected};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _buildPlaceField(),
          const SizedBox(height: 18),
          Text(widget.sectionTitle, style: AppTextStyles.title),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: widget.options.map(_buildPlaceChip).toList(),
          ),
          if (_selectedPlaces.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _selectedPlaces.join(', '),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearSelectedPlaces,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontFamily: 'Pretendard'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedPlaces),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    widget.applyLabel,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceField() {
    final hasSelectedPlaces = _selectedPlaces.isNotEmpty;
    final fieldText = hasSelectedPlaces
        ? _selectedPlaces.join(', ')
        : widget.fieldPlaceholder;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fieldText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: hasSelectedPlaces
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          if (hasSelectedPlaces)
            GestureDetector(
              onTap: _clearSelectedPlaces,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceChip(String place) {
    final selected = _selectedPlaces.contains(place);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _togglePlace(place),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE7DF) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.brandOrange : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check,
                size: 15,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              place,
              style: AppTextStyles.captionMedium.copyWith(
                color: selected ? AppColors.brandOrange : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlace(String place) {
    setState(() {
      if (_selectedPlaces.contains(place)) {
        _selectedPlaces.remove(place);
      } else {
        _selectedPlaces.add(place);
      }
    });
  }

  void _clearSelectedPlaces() {
    setState(() {
      _selectedPlaces.clear();
    });
  }
}
